import 'dart:async';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rdb/common/constant/design/assets_provider.dart';
import 'package:rdb/common/helper/show_message.dart';
import 'package:rdb/features/authentication/presentation/pages/pin_code_verify_page.dart';
import 'package:rdb/features/authentication/presentation/widgets/insert_phone_tab.dart';
import 'package:rdb/features/authentication/presentation/widgets/verification_methods.dart';
import 'package:rdb/features/authentication/presentation/widgets/verify_otp.dart';
import 'package:rdb/generated/locale_keys.g.dart';
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

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  // 🛡️ حماية حالة الصفحة الرئيسية

  late AuthBloc authBloc;

  final PageController pageController = PageController();
  final FocusNode focusNode = FocusNode();
  String phoneNumber = '';
  int isVisWhatsApp = 0;
  final ValueNotifier<bool> isVerified = ValueNotifier(true);
  final ValueNotifier<bool> isPasscodeVerified = ValueNotifier(true);
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
      TrydosWallet.logout();
      authBloc.add(ResetAllData()); // إعادة تعيين كل البيانات في AuthBloc

      // تنظيف باقي الموارد

      GRouter.router.go(GRouter.config.kRootRoute);
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
        GetIt.I<PrefsRepository>().setVerifiedPhone(false);
        GetIt.I<PrefsRepository>().setVerifiedPhonePeforeExpiredToken(true);
        await Future.delayed(const Duration(seconds: 1));

        // استخدم SchedulerBinding لتأخير العملية بعد انتهاء البناء

        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          isVerified.value = false;
          authBloc.add(
            SendOtpEvent(
              phone: GetIt.I<PrefsRepository>().myPhoneNumber!,
              isViaWhatsApp: 1,
              isSignUp: false,
              isResend: false,
            ),
          );
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    walletEvents.cancel();
    languageChangeEvent.cancel();
    logoutEvent.cancel();

    // تنظيف باقي الموارد
    pageController.dispose();
    focusNode.dispose();
    isVerified.dispose();
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
    }
  }

  /// جلب البيانات عند السحب للتحديث (خارج build لتحسين الأداء)

  @override
  Widget build(BuildContext context) {
    isPasscodeVerified.value =
        !(GetIt.I<PrefsRepository>().shouldShowPin ?? false);
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
            ValueListenableBuilder<bool>(
              valueListenable: isVerified,
              builder: (context, isverified, _) {
                return isverified
                    ? const SizedBox.shrink()
                    : Container(
                        width: 1.sw,
                        height: 1.sh,
                        color: const Color.fromRGBO(0, 0, 0, 0.5),
                      );
              },
            ),
            Positioned(
              bottom: 0,
              child: ValueListenableBuilder<bool>(
                valueListenable: isVerified,
                builder: (context, isverified, _) {
                  return isverified ? const SizedBox.shrink() : _veryfiedOtp();
                },
              ),
            ),
            (GetIt.I<PrefsRepository>().photo ?? '') == ''
                ? SizedBox.fromSize()
                : Positioned(
                    top: 120.h,
                    child: ValueListenableBuilder<bool>(
                      valueListenable: isPasscodeVerified,
                      builder: (context, passcodeVerified, _) {
                        if (passcodeVerified) return const SizedBox.shrink();
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
                            loadingBuilder: (context, child, loadingProgress) =>
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
                    ),
                  ),
            // شاشة القفل PinCodeVerifyPage فوق كل شيء مع ضبابية
            Positioned.fill(
              child: ValueListenableBuilder<bool>(
                valueListenable: isPasscodeVerified,
                builder: (context, passcodeVerified, _) {
                  if (passcodeVerified) return const SizedBox.shrink();
                  return BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                    // ignore: deprecated_member_use
                    child: SizedBox(
                      width: 1.sw,
                      height: 1.sh,
                      child: PinCodeVerifyPage(
                        onSuccess: () {
                          GetIt.I<PrefsRepository>().setShouldShowPin(false);
                          isPasscodeVerified.value = true;
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

  Widget _veryfiedOtp() {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: 0),
      child: Container(
        color: Colors.white,
        height: 400,
        width: 1.sw,
        child: Stack(
          children: [
            PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: pageController,
              children:
                  (GetIt.I<PrefsRepository>()
                          .isVerifiedPhonePeforeExpiredToken ??
                      false)
                  ? [
                      VerifyOtp(
                        goChangeNumber: () {},
                        fromProfile: false,
                        navigateToProfile: () {
                          isVerified.value = true;
                          Future.delayed(Duration(seconds: 1), () {
                            GRouter.router.go(GRouter.config.kRootRoute);
                          });
                        },
                        fromExpired: true,
                        isVisWhatsApp: 1,
                        navigateToAddName: () {
                          isVerified.value = true;
                          Future.delayed(Duration(seconds: 1), () {
                            GRouter.router.go(GRouter.config.kRootRoute);
                          });
                        },
                        navigateTocartOrProfile: () {
                          isVerified.value = true;
                          Future.delayed(Duration(seconds: 1), () {
                            GRouter.router.go(GRouter.config.kRootRoute);
                          });
                        },
                        fromLogin: true,
                        onLoginFailed: () {
                          //   pageController.animateToPage(3, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
                        },
                        goBack: () {
                          // pageController.animateToPage(1, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
                        },
                        methodIcon: AppAssets.whatsappSvg,
                        phoneNumber: GetIt.I<PrefsRepository>().myPhoneNumber!,
                      ),
                    ]
                  : [
                      InsertPhoneTab(
                        focusNode: focusNode,
                        moveToNextStep: (String phoneNumber) {
                          this.phoneNumber = phoneNumber.replaceAll(' ', '');
                          pageController.animateToPage(
                            1,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                          setState(() {});
                        },
                      ),
                      VerificationMethods(
                        isFromLogin: false,
                        phoneNumber: phoneNumber,
                        onChooseWhatsapp: () {
                          isVisWhatsApp = 1;

                          pageController.animateToPage(
                            2,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );

                          if (GetIt.I<PrefsRepository>().isTimerForOtpRunning ??
                              false) {
                            showWarningMessage(
                              context,
                              ' ${LocaleKeys.you_must_wait_for_some_seconds_before_try_again.tr()}',
                            );
                            return;
                          }
                          /*   authBloc.add(
                              SendOtpEvent(phone: phoneNumber, isViaWhatsApp: 1));*/
                        },
                        goBackToPhone: () {
                          pageController.animateToPage(
                            0,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        },
                        onChooseSms: () {
                          isVisWhatsApp = 0;
                          pageController.animateToPage(
                            3,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                          /* authBloc.add(
                              SendOtpEvent(phone: phoneNumber, isViaWhatsApp: 0));*/
                        },
                      ),
                      VerifyOtp(
                        goChangeNumber: () {},
                        fromProfile: false,
                        navigateToProfile: () {
                          isVerified.value = true;
                          Future.delayed(Duration(seconds: 1), () {
                            GRouter.router.go(GRouter.config.kRootRoute);
                          });
                        },
                        fromExpired: true,
                        isVisWhatsApp: isVisWhatsApp,
                        navigateToAddName: () {
                          isVerified.value = true;
                          Future.delayed(Duration(seconds: 1), () {
                            GRouter.router.go(GRouter.config.kRootRoute);
                          });
                        },
                        navigateTocartOrProfile: () {
                          isVerified.value = true;
                          Future.delayed(Duration(seconds: 1), () {
                            GRouter.router.go(GRouter.config.kRootRoute);
                          });
                        },
                        fromLogin: false,
                        onLoginFailed: () {
                          pageController.animateToPage(
                            3,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        },
                        goBack: () {
                          pageController.animateToPage(
                            1,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        },
                        methodIcon: isVisWhatsApp == 1
                            ? AppAssets.whatsappSvg
                            : AppAssets.smsSvg,
                        phoneNumber: phoneNumber,
                      ),
                    ],
            ),
            Positioned(
              top: 0,
              left: LanguageService.languageCode != "ar" ? null : 0,
              right: LanguageService.languageCode != "ar" ? 0 : null,
              child: Container(
                margin: const EdgeInsets.all(10),
                height: 20,
                width: 40,
                child: InkWell(
                  onTap: () => isVerified.value = true,
                  child: SvgPicture.asset(
                    AppAssets.cancelSvg,
                    height: 15,
                    width: 30,
                    // ignore: deprecated_member_use
                    color: const Color(0xffFF5F61),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
