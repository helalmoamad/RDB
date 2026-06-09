import 'dart:async';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rdb/features/authentication/presentation/pages/pin_code_verify_page.dart';
import 'package:rdb/features/authentication/presentation/pages/switch_between_web_app_page.dart';
import 'package:rdb/routes/router.dart';
import 'package:rdb/service/language_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:rdb/core/domin/repositories/prefs_repository.dart';
import 'package:rdb/core/utils/responsive_padding.dart';
import 'package:rdb/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trydos_wallet/trydos_wallet.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

late StreamSubscription walletEvents;
late StreamSubscription languageChangeEvent;
late StreamSubscription logoutEvent;
late StreamSubscription lockEvent;
late StreamSubscription switchEvent;

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  // 🛡️ حماية حالة الصفحة الرئيسية

  late AuthBloc authBloc;
  final ValueNotifier<bool> isPasscodeVerified = ValueNotifier(true);
  final ValueNotifier<bool> isShowSwitch = ValueNotifier(true);
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
            GetIt.I<PrefsRepository>().isTwoFactorEnabled ?? false,
        applicationVersion: "1.0.0",
        skipSplash: true,
        disableWalletOverscrollIndicator: true,
        // استخدم اللغة الحالية
        allowBadCertificate: true, // true للتطوير فقط عند خطأ SSL
      ),
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
      await GetIt.I<PrefsRepository>().setUserName("");

      // إلغاء الاشتراك مباشرة بعد تسجيل الخروج

      await walletEvents.cancel();
      await languageChangeEvent.cancel();
      await logoutEvent.cancel();
      await lockEvent.cancel();
      TrydosWallet.logout();
      authBloc.add(ResetAllData()); // إعادة تعيين كل البيانات في AuthBloc

      // تنظيف باقي الموارد

      GRouter.router.go(GRouter.config.kRootRoute);
    });
    switchEvent = switchEvents.listen((event) async {
      final prefs = GetIt.I<PrefsRepository>();
      // خزّن وقت ظهور switch لأول مرة فقط حتى يستمر العدّاد ولا يُصفَّر
      // عند تكرار الحدث أو العودة من الخلفية
      if (prefs.switchShownAtMs == null) {
        prefs.setSwitchShownAtMs(DateTime.now().millisecondsSinceEpoch);
      }
      prefs.setShouldShowSwitch(true);
      isShowSwitch.value = true;
    });
    lockEvent = lockEvents.listen((event) async {
      GetIt.I<PrefsRepository>().setShouldShowPin(true);
      isPasscodeVerified.value = false;
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
    super.initState();
  }

  @override
  void dispose() {
    walletEvents.cancel();
    languageChangeEvent.cancel();
    logoutEvent.cancel();
    lockEvent.cancel();
    switchEvent.cancel();

    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // تحديث حالة التحقق من رمز المرور عند العودة من الخلفية
      isPasscodeVerified.value =
          !(GetIt.I<PrefsRepository>().shouldShowPin ?? false);
      isShowSwitch.value = GetIt.I<PrefsRepository>().shouldShowSwitch ?? false;
      // قد ينتهي التوكن أثناء وجود التطبيق في الخلفية — حدّثه استباقيًا
      authBloc.add(const EnsureWalletTokenValidEvent());
    }
  }

  /// جلب البيانات عند السحب للتحديث (خارج build لتحسين الأداء)

  @override
  Widget build(BuildContext context) {
    isPasscodeVerified.value =
        !(GetIt.I<PrefsRepository>().shouldShowPin ?? false);
    isShowSwitch.value = GetIt.I<PrefsRepository>().shouldShowSwitch ?? false;
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

            (GetIt.I<PrefsRepository>().photo ?? '') == ''
                ? SizedBox.fromSize()
                : Positioned(
                    top: 120.h,
                    child: ValueListenableBuilder<bool>(
                      valueListenable: isShowSwitch,
                      builder: (context, isShowSwitch, _) {
                        return ValueListenableBuilder<bool>(
                          valueListenable: isPasscodeVerified,
                          builder: (context, passcodeVerified, _) {
                            if (passcodeVerified && (!isShowSwitch)) {
                              return const SizedBox.shrink();
                            }
                            return Container(
                              width: 200.w,
                              height: 200.h,
                              decoration: BoxDecoration(
                                color: Color(0xff1D1D1D),
                                borderRadius: BorderRadius.circular(15.r),
                              ),
                              child: Image.network(
                                GetIt.I<PrefsRepository>().photo ??
                                    '', // صورة افتراضية إذا لم تكن موجودة
                                width: 200.w,
                                loadingBuilder:
                                    (context, child, loadingProgress) =>
                                        loadingProgress == null
                                        ? child
                                        : Shimmer.fromColors(
                                            baseColor: Colors.grey[300]!,
                                            highlightColor: Colors.grey[100]!,
                                            child: Container(
                                              width: 200.w,
                                              height: 200.h,
                                              color: Colors.white,
                                            ),
                                          ),
                                height: 200.h,
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
            // شاشة القفل PinCodeVerifyPage فوق كل شيء مع ضبابية
            Positioned.fill(
              child: ValueListenableBuilder<bool>(
                valueListenable: isShowSwitch,
                builder: (context, isShowSwitched, _) {
                  return ValueListenableBuilder<bool>(
                    valueListenable: isPasscodeVerified,
                    builder: (context, passcodeVerified, _) {
                      if (passcodeVerified || isShowSwitched) {
                        return const SizedBox.shrink();
                      }
                      return BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                        // ignore: deprecated_member_use
                        child: SizedBox(
                          width: 1.sw,
                          height: 1.sh,
                          child: PinCodeVerifyPage(
                            onSuccess: () {
                              GetIt.I<PrefsRepository>().setShouldShowPin(
                                false,
                              );
                              isPasscodeVerified.value = true;
                            },
                          ),
                        ), // تقليل العتامة
                      );
                    },
                  );
                },
              ),
            ),
            Positioned.fill(
              child: ValueListenableBuilder<bool>(
                valueListenable: isShowSwitch,
                builder: (context, isShowSwitched, _) {
                  if (!isShowSwitched) return const SizedBox.shrink();
                  return BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                    // ignore: deprecated_member_use
                    child: SizedBox(
                      width: 1.sw,
                      height: 1.sh,
                      child: SwitchWepAppPage(
                        onSuccess: () {
                          final prefs = GetIt.I<PrefsRepository>();
                          prefs.setShouldShowSwitch(false);
                          // تصفير عدّاد الوقت عند إغلاق switch
                          prefs.setSwitchShownAtMs(null);
                          isShowSwitch.value = false;
                        },
                      ),
                    ), // تقليل العتامة
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
