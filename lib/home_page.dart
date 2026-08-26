import 'dart:async';
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rdb/core/utils/app_lock_overlay.dart';
import 'package:rdb/routes/router.dart';
import 'package:rdb/service/language_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:rdb/core/domin/repositories/prefs_repository.dart';
import 'package:rdb/core/utils/responsive_padding.dart';
import 'package:rdb/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:rdb/service/analytics_service.dart';
import 'package:trydos_wallet/trydos_wallet.dart';
import 'package:rdb/service/notification_service/notification_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

late StreamSubscription walletEvents;
late StreamSubscription languageChangeEvent;
late StreamSubscription logoutEvent;
late StreamSubscription lockEvent;
late StreamSubscription errorSubscription;
late StreamSubscription switchEvent;

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  // 🛡️ حماية حالة الصفحة الرئيسية

  late AuthBloc authBloc;
  // حالة القفل/التبديل يديرها AppLockController كـ route فوق الـ root navigator
  // (HomePage يبقى يتحكّم بها عبر showLock/showSwitch/syncFromPrefs). هذان
  // الـ getter يبقيان لعرض/إخفاء صورة الخلفية في HomePage خلف القفل.
  ValueNotifier<bool> get isPasscodeVerified =>
      AppLockController.instance.isPasscodeVerified;
  ValueNotifier<bool> get isShowSwitch =>
      AppLockController.instance.isShowSwitch;
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    if (kDebugMode) {
      print("walletToken: ${GetIt.I<PrefsRepository>().walletToken}###");
    }

    authBloc = BlocProvider.of<AuthBloc>(context);
    final memberSince = DateTime.tryParse(
      GetIt.I<PrefsRepository>().memberSince ?? '',
    );

    // تهيئة المحفظة
    TrydosWallet.init(
      TrydosWalletConfig(
        baseUrl: dotenv.env['WALLET_URL'] ?? '', // رابط الـ API
        kycBaseUrl: dotenv.env['KYC_URL'] ?? '', // رابط KYC
        token: GetIt.I<PrefsRepository>().walletToken, // استخدم القيمة الفعلية
        languageCode: LanguageService.languageCode,
        refreshToken: GetIt.I<PrefsRepository>().walletRefreshToken,
        clientIp: authBloc.state.getUserCountryResponseModel?.ip ?? '',

        email: GetIt.I<PrefsRepository>().email ?? '',
        firstName: (GetIt.I<PrefsRepository>().userName ?? '').split(" ").first,
        lastName:
            (GetIt.I<PrefsRepository>().userName ?? '').split(" ").length > 1
            ? (GetIt.I<PrefsRepository>().userName ?? '').split(" ").last
            : "",
        userSubtitle: (GetIt.I<PrefsRepository>().isVerifiedPhone ?? false)
            ? "Registered"
            : "Guest",
        profileImageUrl: GetIt.I<PrefsRepository>().photo ?? "",
        isAccountActive: GetIt.I<PrefsRepository>().isAccountActive ?? false,
        isPhoneVerified: GetIt.I<PrefsRepository>().isVerifiedPhone ?? false,
        memberSince: memberSince,
        phoneNumber: GetIt.I<PrefsRepository>().myPhoneNumber,
        isKurdish: LanguageService.languageCode == "ku",
        isTwoFactorEnabled:
            GetIt.I<PrefsRepository>().isKycVerification ?? false,
        applicationVersion: "1.0.0",
        skipSplash: true,
        isVerified: GetIt.I<PrefsRepository>().isKycVerification ?? false,
        disableWalletOverscrollIndicator: true,
        // استخدم اللغة الحالية
        // ⚠️ مؤقّت: تعارض اسم المضيف في WALLET_URL (شُرَط سفلية في
        // trydos_wallet_develop.ramaaz.dev). يُعاد إلى kDebugMode فور إضافة
        // سجل DNS بشُرَط عادية. الشرح الكامل في di_container.dart.
        allowBadCertificate: true,
      ),
    );

    // ربط جلسة PostHog بالمستخدم الحالي ليُنسب التسجيل/الأحداث إليه (يشمل
    // شاشات المحفظة لأنها ضمن نفس الجلسة).
    final analyticsUserId =
        GetIt.I<PrefsRepository>().myPhoneNumber ??
        GetIt.I<PrefsRepository>().email ??
        '';
    AnalyticsService.instance.identify(
      userId: analyticsUserId,
      properties: {
        'is_verified': GetIt.I<PrefsRepository>().isKycVerification ?? false,
        'is_phone_verified':
            GetIt.I<PrefsRepository>().isVerifiedPhone ?? false,
        'language': LanguageService.languageCode,
      },
    );

    // الاستماع لأحداث تسجيل الخروج
    logoutEvent = logoutEvents.listen((event) async {
      if (kDebugMode) {
        print('User logged out from wallet. Clearing verification status.');
      }
      await GetIt.I<PrefsRepository>().setPasscode("");
      await GetIt.I<PrefsRepository>().setVerifiedPhone(false);
      await GetIt.I<PrefsRepository>().setWalletToken("");
      await GetIt.I<PrefsRepository>().setVerifiedPhonePeforeExpiredToken(
        false,
      );
      await GetIt.I<PrefsRepository>().setIsAccountActive(false);
      await GetIt.I<PrefsRepository>().setIsTwoFactorEnabled(false);
      await GetIt.I<PrefsRepository>().setIsKycVerification(false);
      await GetIt.I<PrefsRepository>().setUserName("");

      // إلغاء الاشتراك مباشرة بعد تسجيل الخروج

      await walletEvents.cancel();
      await errorSubscription.cancel();
      await languageChangeEvent.cancel();
      await logoutEvent.cancel();
      await lockEvent.cancel();
      TrydosWallet.logout();

      AnalyticsService.instance.reset(); // فصل جلسة PostHog عن المستخدم
      // إبطال توكن FCM ومسحه (دون حجب تسجيل الخروج) حتى لا تصل إشعارات للمستخدم
      // السابق ويبدأ التالي نظيفاً.
      AppNotificationService.instance.onLogout();
      AppLockController.instance.reset(); // إزالة القفل وتصفير حالته عند الخروج
      authBloc.add(ResetAllData()); // إعادة تعيين كل البيانات في AuthBloc

      // تنظيف باقي الموارد

      GRouter.router.go(GRouter.config.kRootRoute);
    });

    errorSubscription = errorEvents.listen((event) {
      // ignore: use_build_context_synchronously
      showMessage(event.message, context: context, type: MessageType.error);
      debugPrint(
        '[App] API error event: ${event.message} (status: ${event.statusCode})',
      );
    });
    switchEvent = switchEvents.listen((event) async {
      final prefs = GetIt.I<PrefsRepository>();
      // خزّن وقت ظهور switch لأول مرة فقط حتى يستمر العدّاد ولا يُصفَّر
      // عند تكرار الحدث أو العودة من الخلفية
      if (prefs.switchShownAtMs == null) {
        prefs.setSwitchShownAtMs(DateTime.now().millisecondsSinceEpoch);
      }
      prefs.setShouldShowSwitch(true);
      AppLockController.instance.showSwitch();
    });
    lockEvent = lockEvents.listen((event) async {
      GetIt.I<PrefsRepository>().setShouldShowPin(true);
      AppLockController.instance.showLock();
    });
    // الاستماع لأحداث تغيير اللغة
    languageChangeEvent = languageChangeEvents.listen((event) async {
      final languageCode = event.languageCode.trim().toLowerCase();
      final locale = mpaLanguageCodeToLocale[languageCode];
      if (locale == null || !mounted) {
        return;
      }

      await context.setLocale(locale);
      await GetIt.I<PrefsRepository>().setLanguage(languageCode);
      GRouter.router.go(GRouter.config.kRootRoute);
    });

    walletEvents = authEvents.listen((evt) async {
      if ((GetIt.I<PrefsRepository>().passcode ?? "").isEmpty) {
        return;
      }
      if (kDebugMode) {
        print('User logged out from wallet. Clearing verification status.');
      }
      if (evt.toString() == 'AuthEvent.unauthenticated') {
        // انتهت صلاحية التوكن — حدّث accessToken بواسطة الـ refresh token المخزّن
        authBloc.add(const RefreshTokenEvent());
      }
    });
    // طلب إذن الإشعارات مرتبط بحالة القفل: عند فك القفل (إدخال passcode صحيح)
    // يصبح isPasscodeVerified=true فيُطلق المستمع الطلب. أمّا إن لم يكن هناك
    // قفل (verified=true أصلاً) فيُطلب مباشرةً في الـ post-frame أدناه.
    AppLockController.instance.isPasscodeVerified.addListener(_onHomeUnlocked);
    // مزامنة أولية لحالة القفل/التبديل من التخزين بعد أول إطار. يغطّي حالة
    // الإقلاع البارد وهو مقفول (splash يضبط shouldShowPin=true).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppLockController.instance.syncFromPrefs();
      // بعد المزامنة: إن لم يكن هناك passcode (verified=true) نفّذ مهام الجهوز.
      _onHomeUnlocked();
    });
    super.initState();
  }

  /// مهام تُنفَّذ عند جهوز الـ HomePage وكونها مفكوكة القفل (verified=true):
  /// طلب إذن الإشعارات + تنفيذ أي طلب موافقة جلسة معلّق وصل خارج foreground.
  /// تُستدعى بعد إدخال الـ passcode الصحيح أو فوراً إن لم يكن هناك passcode،
  /// وعند كل استئناف للتطبيق.
  void _onHomeUnlocked() {
    if (!AppLockController.instance.isPasscodeVerified.value) return;
    AppNotificationService.instance.ensureNotificationPermission();
    _consumePendingApproval();
  }

  /// تنفيذ طلب موافقة الجلسة المعلّق (المخزّن من خلفية/فتح من إشعار) ثم مسحه.
  Future<void> _consumePendingApproval() async {
    final prefs = GetIt.I<PrefsRepository>();
    // التقط ما كتبه isolate الخلفية (قد تكون النسخة في الذاكرة قديمة).
    await prefs.reloadPreferences();
    if (!prefs.pendingApprovalRequest) return;
    final raw = prefs.pendingApprovalRequestData;
    // امسح الحقول دائماً (من أجل المرّة القادمة).
    await prefs.clearPendingApprovalRequest();
    if (raw == null || raw.isEmpty) return;
    try {
      final data = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      TrydosWallet.handleSessionApprovalRequest(data);
    } catch (e) {
      if (kDebugMode) debugPrint('consume approval failed: $e');
    }
  }

  @override
  void dispose() {
    walletEvents.cancel();
    languageChangeEvent.cancel();
    logoutEvent.cancel();
    lockEvent.cancel();
    errorSubscription.cancel();
    switchEvent.cancel();
    AppLockController.instance.isPasscodeVerified.removeListener(
      _onHomeUnlocked,
    );

    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // تحديث حالة القفل/التبديل عند العودة من الخلفية (يدفع/يُزيل route القفل).
      AppLockController.instance.syncFromPrefs();
      // عند كل فتح للتطبيق: مهام الجهوز (إذن الإشعارات + طلب موافقة معلّق) إن كان
      // مفكوك القفل؛ وإلا تنتظر فك القفل عبر المستمع.
      _onHomeUnlocked();
      // قد ينتهي التوكن أثناء وجود التطبيق في الخلفية — حدّثه استباقيًا
      authBloc.add(const EnsureWalletTokenValidEvent());
    }
  }

  /// جلب البيانات عند السحب للتحديث (خارج build لتحسين الأداء)

  @override
  Widget build(BuildContext context) {
    // ملاحظة: لا نضبط حالة القفل هنا. المزامنة تتم خارج build عبر
    // AppLockController (initState post-frame + didChangeAppLifecycleState +
    // مستمعو الأحداث) حتى يُدفع/يُزال route القفل بشكل موثوق.
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: isPasscodeVerified.value != true ? false : true,
      body: Padding(
        padding: HWEdgeInsets.symmetric(horizontal: 0.w),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ScrollConfiguration(
              behavior: const MaterialScrollBehavior().copyWith(
                overscroll: false,
              ),
              child: TrydosWalletWelcomeScreen(),
            ),

            // ملاحظة: طبقتا القفل (PinCodeVerifyPage) والتبديل (SwitchWepAppPage)
            // أصبحتا route يدفعه AppLockController فوق الـ root navigator، فتغطّيان
            // جميع المسارات (بما فيها صفحات KYC/تفاصيل الحساب الداخلية). هنا نبقي
            // فقط على إدارة حالتهما عبر الأحداث.
          ],
        ),
      ),
    );
  }
}
