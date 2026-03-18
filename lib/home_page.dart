import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rdb/common/constant/design/assets_provider.dart';
import 'package:rdb/common/helper/show_message.dart';
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
import 'package:trydos_wallet/trydos_wallet.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

late StreamSubscription walletEvents;

class _HomePageState extends State<HomePage> {
  // 🛡️ حماية حالة الصفحة الرئيسية

  late AuthBloc authBloc;

  final PageController pageController = PageController();
  final FocusNode focusNode = FocusNode();
  String phoneNumber = '';
  int isVisWhatsApp = 0;
  final ValueNotifier<bool> isVerified = ValueNotifier(true);
  @override
  void initState() {
    if (kDebugMode) {
      print("walletToken: ${GetIt.I<PrefsRepository>().walletToken}###");
    }
    authBloc = BlocProvider.of<AuthBloc>(context);
    // تهيئة المحفظة
    TrydosWallet.init(
      TrydosWalletConfig(
        baseUrl: dotenv.env['WALLET_URL'] ?? '', // رابط الـ API
        token: GetIt.I<PrefsRepository>().walletToken, // استخدم القيمة الفعلية
        languageCode: "en",
        skipSplash: true,
        onLogout: () {},

        //LanguageService.languageCode,
        // استخدم اللغة الحالية
        allowBadCertificate: true, // true للتطوير فقط عند خطأ SSL
      ),
    );
    errorEvents.listen((event) {
      debugPrint('❌ API Error: ${event.message} (${event.statusCode})');
    });
    errorEvents.listen((event) {
      debugPrint('❌ API Error: ${event.message} (${event.statusCode})');
    });

    // الاستماع لأحداث تسجيل الخروج
    logoutEvents.listen((event) {
      if (kDebugMode) {
        print('User logged out from wallet. Clearing verification status.');
      }
      GetIt.I<PrefsRepository>().setVerifiedPhone(false);
      GetIt.I<PrefsRepository>().setVerifiedPhonePeforeExpiredToken(false);
      GRouter.config.applicationRoutes.kRegistrationPage;
    });

    // الاستماع لأحداث تغيير اللغة
    languageChangeEvents.listen((event) {});

    walletEvents = authEvents.listen((evt) async {
      if (kDebugMode) {
        print('User logged out from wallet. Clearing verification status.');
      }
      if (evt.toString() == 'AuthEvent.unauthenticated') {
        GetIt.I<PrefsRepository>().setVerifiedPhone(false);
        GetIt.I<PrefsRepository>().setVerifiedPhonePeforeExpiredToken(true);
        await Future.delayed(const Duration(seconds: 1));

        // استخدم SchedulerBinding لتأخير العملية بعد انتهاء البناء

        await Future.delayed(const Duration(seconds: 1));
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
    });
    super.initState();
  }

  @override
  void dispose() {
    walletEvents.cancel();

    // تنظيف موارد الم

    // تنظيف باقي الموارد
    pageController.dispose();
    focusNode.dispose();
    isVerified.dispose();

    super.dispose();
  }

  /// جلب البيانات عند السحب للتحديث (خارج build لتحسين الأداء)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: HWEdgeInsets.symmetric(horizontal: 0.w),
        child: Stack(
          children: [
            TrydosWalletWelcomeScreen(),
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
                        fromProfile: false,
                        navigateToProfile: () {},
                        fromExpired: true,
                        isVisWhatsApp: 1,
                        navigateToAddName: () {},
                        navigateTocartOrProfile: () {
                          isVerified.value = true;
                        },
                        fromLogin: false,
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
                        fromProfile: false,
                        navigateToProfile: () {},
                        fromExpired: true,
                        isVisWhatsApp: isVisWhatsApp,
                        navigateToAddName: () {},
                        navigateTocartOrProfile: () {
                          isVerified.value = true;
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
