import 'package:cupertino_back_gesture/cupertino_back_gesture.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:rdb/common/constant/design/constant_design.dart';
import 'package:rdb/core/domin/repositories/prefs_repository.dart';
import 'package:rdb/core/utils/app_lifecycle_manager.dart';
import 'package:rdb/core/utils/app_lock_overlay.dart';
import 'package:rdb/core/utils/extensions/state_ext.dart';
import 'package:rdb/core/utils/idle_lock_timer.dart';
import 'package:rdb/features/security/presentation/root_security_issue_page.dart';
import 'package:rdb/routes/router.dart';
import 'package:rdb/service/ku_fallback_localizations.dart';
import 'package:rdb/service/analytics_service.dart';
import 'package:rdb/service/notification_service/notification_service.dart';
import 'package:rdb/service/app_deep_link_service.dart';
import 'package:rdb/service/language_service.dart';
import 'package:rdb/service/localization_service.dart';
import 'package:rdb/service/screen_service.dart';
import 'package:rdb/service/service_provider.dart';
import 'package:rdb/theme/app_theme.dart';
import 'package:rdb/theme/my_color_scheme.dart';
import 'package:rdb/widgets/connectivity_gate.dart';
import 'package:bot_toast/bot_toast.dart';

class TrydosApplication extends StatefulWidget {
  const TrydosApplication({
    super.key,
    required this.navKey,
    required this.isSecurityIssueFound,
  });
  final GlobalKey<NavigatorState> navKey;
  final bool isSecurityIssueFound;

  @override
  State<TrydosApplication> createState() => _TrydosApplicationState();
}

final ValueNotifier<bool> denySlidingBackForSlidingUpPanels = ValueNotifier(
  false,
);

class _TrydosApplicationState extends State<TrydosApplication>
    with WidgetsBindingObserver {
  final AppDeepLinkService _deepLinkService = AppDeepLinkService();

  @override
  void didChangeDependencies() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: colorScheme.white,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    super.didChangeDependencies();
  }

  final botToastBuilder = BotToastInit();
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    // كشف الاتصال ومراقبته يملكهما ConnectivityGate (داخل builder الخاص بـ
    // MaterialApp) — فهو يستدعي initialize() ويستمع لـ isOnline ويعرض شاشة
    // NoInternetScreen كطبقة تغطي التطبيق بدل أي رسالة/توست.
    /////////////////////
    // FirebaseAnalyticsService.startAnalyticsSession();
    /////////////////////
    super.initState();
    if (!widget.isSecurityIssueFound) {
      _deepLinkService.init();
      // ⏱️ قفل تلقائي بعد دقيقة من عدم التفاعل مع الشاشة (جلسة قائمة + رمز
      // مرور مضبوط فقط). التفاعل يصل عبر الـ Listener في build.
      IdleLockTimer.instance.start();
    }
    // FirebasePresence.sendUserStatus("online");
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _deepLinkService.dispose();
    IdleLockTimer.instance.stop();

    super.dispose();
  }

  @override
  void didChangeMetrics() {
    // لا نستدعي setState هنا: MediaQuery يُحدّث المعتمدين عليه تلقائياً عند
    // تغيّر الأبعاد. إعادة بناء جذر التطبيق في كل إطار من حركة لوحة المفاتيح
    // كانت تُسقط التركيز/اتصال الإدخال ثم تُعيده → وميض ظهور/اختفاء اللوحة.
    super.didChangeMetrics();
  }

  /// 🔄 معالجة حالة التطبيق
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // لا تنفذ أي منطق حماية أو إخفاء محتوى عند الحالة inactive (يتم ذلك فقط في SecurityService)
    AppLifecycleManager().handleLifecycleChange(state);
    // أوقِف عدّاد الخمول في الخلفية واستأنفه عند العودة — القفل عند العودة من
    // الخلفية يتكفّل به AppLifecycleManager أصلاً.
    IdleLockTimer.instance.handleLifecycleChange(state);
    if (state == AppLifecycleState.resumed) {
      _handleAppResumed();
      // عند فتح/استئناف التطبيق (سواء من إشعار أو عادي): أفرِغ شريط الإشعارات.
      AppNotificationService.instance.clearAll();
    }
    // عند انتقال التطبيق للخلفية، ادفع أحداث/لقطات PostHog فوراً لتقليل فقدان
    // آخر اللقطات إذا قتل المستخدم التطبيق بعدها.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      AnalyticsService.instance.flush();
    }
  }

  /// 🔒 عند عودة الإنترنت: لا نُحدّث أي بيانات — نكتفي بإظهار شاشة إدخال رمز
  /// المرور إن كان للمستخدم رمز مضبوط وجلسة قائمة (نفس آلية القفل المستخدمة في
  /// [HomePage]). بدون رمز مضبوط لا يحدث شيء.
  void _lockWithPasscodeIfSet() {
    try {
      final prefs = GetIt.I<PrefsRepository>();
      final hasPasscode = (prefs.passcode ?? '').isNotEmpty;
      final hasSession = (prefs.walletToken ?? '').isNotEmpty;
      if (!hasPasscode || !hasSession) return;

      prefs.setShouldShowPin(true);
      AppLockController.instance.showLock();
    } catch (e) {
      // سجلّ تشخيصي للتطوير فقط: debugPrint لا يُحذف في نسخة الإصدار.
      if (kDebugMode) {
        debugPrint('❌ Error showing passcode lock after reconnect: $e');
      }
    }
  }

  /// ✅ معالجة عودة التطبيق من الخلفية
  void _handleAppResumed() {
    try {
      // إعادة تعيين حالة الواجهة
      if (mounted) {
        setState(() {
          // تحديث الواجهة
        });
      }

      // إعادة تعيين شريط الحالة
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: colorScheme.white,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
        ),
      );

      debugPrint('✅ App state restored successfully');
    } catch (e) {
      debugPrint('❌ Error restoring app state: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: kDesignSize,
      minTextAdapt: true,
      builder: (context, child) {
        return LocalizationService(
          child: SafeArea(
            top: false,
            child: ServiceProvider(
              child: Builder(
                builder: (context) {
                  return ValueListenableBuilder<bool>(
                    valueListenable: denySlidingBackForSlidingUpPanels,
                    child: widget.isSecurityIssueFound
                        ? MaterialApp(
                            debugShowCheckedModeBanner: false,
                            // خلفية بيضاء أثناء تحميل الـ localizations في أول
                            // بناء (وإلا يظهر إطار داكن/أسود لحظياً قبل الواجهة).
                            color: const Color(0xFFFFFFFF),
                            locale: context.locale,
                            theme: AppTheme.light,

                            // 👇 التعديل الأول: حماية ثيم حالة الحماية والأمان
                            darkTheme: AppTheme.light,
                            themeMode: ThemeMode.light,
                            supportedLocales: context.supportedLocales,
                            localizationsDelegates: [
                              ...context.localizationDelegates,
                              const KuMaterialLocalizationsDelegate(),
                              const KuWidgetsLocalizationsDelegate(),
                              const KuCupertinoLocalizationsDelegate(),
                            ],
                            home: const RootSecurityIssuePage(),
                            builder: (context, child) => ConnectivityGate(
                              languageCode: context.locale.languageCode,
                              child: child ?? const SizedBox.shrink(),
                            ),
                          )
                        : MaterialApp.router(
                            debugShowCheckedModeBanner: false,
                            // خلفية بيضاء أثناء تحميل الـ localizations في أول
                            // بناء — يمنع الإطار الأسود بين الصفحة البيضاء وسبلاش
                            // التطبيق.
                            color: const Color(0xFFFFFFFF),
                            locale: context.locale,
                            routerConfig: GRouter.router,
                            theme: AppTheme.light,

                            // 👇 التعديل الأول: حماية ثيم حالة الحماية والأمان
                            darkTheme: AppTheme.light,
                            themeMode: ThemeMode.light,
                            supportedLocales: context.supportedLocales,
                            localizationsDelegates: [
                              ...context.localizationDelegates,
                              const KuMaterialLocalizationsDelegate(),
                              const KuWidgetsLocalizationsDelegate(),
                              const KuCupertinoLocalizationsDelegate(),
                            ],

                            builder: (context, child) {
                              LanguageService(context);
                              ScreenService(context);

                              // ConnectivityGate يغطّي كل شيء (بما فيه الـ
                              // toasts والحوارات) بشاشة "لا يوجد اتصال" عند
                              // انقطاع الإنترنت الفعلي.
                              //
                              // ⏱️ الـ Listener هنا يلفّ الـ Navigator كاملاً
                              // فيرى كل لمسة/سحب في التطبيق (بما فيها شاشات
                              // مكتبة المحفظة). لا يستهلك الأحداث ولا يمنع
                              // وصولها للودجت أسفله — يسجّل وقت آخر تفاعل فقط.
                              return Listener(
                                behavior: HitTestBehavior.translucent,
                                onPointerDown: (_) =>
                                    IdleLockTimer.instance.reportActivity(),
                                onPointerMove: (_) =>
                                    IdleLockTimer.instance.reportActivity(),
                                child: ConnectivityGate(
                                  languageCode: context.locale.languageCode,
                                  onReconnected: _lockWithPasscodeIfSet,
                                  child: botToastBuilder(context, child),
                                ),
                              );
                            },
                          ),
                    builder: (context, deny, child) {
                      return BackGestureWidthTheme(
                        backGestureWidth: BackGestureWidth.fraction(
                          deny ? 0 : 1,
                        ),
                        child: child!,
                      );
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
