import 'package:cupertino_back_gesture/cupertino_back_gesture.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rdb/common/constant/design/constant_design.dart';
import 'package:rdb/core/utils/app_lifecycle_manager.dart';
import 'package:rdb/core/utils/extensions/state_ext.dart';
import 'package:rdb/features/security/presentation/root_security_issue_page.dart';
import 'package:rdb/routes/router.dart';
import 'package:rdb/service/ku_fallback_localizations.dart';
import 'package:rdb/service/app_deep_link_service.dart';
import 'package:rdb/service/language_service.dart';
import 'package:rdb/service/localization_service.dart';
import 'package:rdb/service/screen_service.dart';
import 'package:rdb/service/service_provider.dart';
import 'package:rdb/theme/app_theme.dart';
import 'package:rdb/theme/my_color_scheme.dart';
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
    /////////////////////
    // FirebaseAnalyticsService.startAnalyticsSession();
    /////////////////////
    super.initState();
    if (!widget.isSecurityIssueFound) {
      _deepLinkService.init();
    }
    // FirebasePresence.sendUserStatus("online");
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _deepLinkService.dispose();

    super.dispose();
  }

  @override
  void didChangeMetrics() {
    setState(() {});
    super.didChangeMetrics();
  }

  /// 🔄 معالجة حالة التطبيق لمنع الشاشة السوداء عند العودة من الخلفية
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // استخدام AppLifecycleManager لمعالجة الحالة
    AppLifecycleManager().handleLifecycleChange(state);

    // معالجة إضافية خاصة بالتطبيق
    if (state == AppLifecycleState.resumed) {
      _handleAppResumed();
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
                            locale: context.locale,
                            theme: AppTheme.light,
                            supportedLocales: context.supportedLocales,
                            localizationsDelegates: [
                              ...context.localizationDelegates,
                              const KuMaterialLocalizationsDelegate(),
                              const KuWidgetsLocalizationsDelegate(),
                              const KuCupertinoLocalizationsDelegate(),
                            ],
                            home: const RootSecurityIssuePage(),
                          )
                        : MaterialApp.router(
                            debugShowCheckedModeBanner: false,
                            locale: context.locale,
                            routerConfig: GRouter.router,
                            theme: AppTheme.light,
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

                              return botToastBuilder(context, child);
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
