import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:rdb/base_page.dart';
import 'package:rdb/core/utils/extensions/build_context.dart';
import 'package:rdb/core/utils/responsive_padding.dart';
import 'package:rdb/features/authentication/presentation/widgets/create_account_section.dart';
import 'package:rdb/generated/locale_keys.g.dart';
import '../../../../common/helper/show_message.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../routes/router.dart';
import '../manager/auth_bloc.dart';
import '../widgets/welcome_section.dart';
import 'package:rdb/features/authentication/presentation/widgets/insert_phone_tab.dart';
import 'package:rdb/features/authentication/presentation/widgets/verify_otp.dart';
import '../../../../common/constant/design/assets_provider.dart';
import '../widgets/verification_methods.dart';
import 'package:rdb/core/utils/last_pages_tracker.dart';

class RegistrationPage extends StatefulWidget {
  final bool? fromLogOut;

  const RegistrationPage({this.fromLogOut = false, super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage>
    with SingleTickerProviderStateMixin {
  PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  final ValueNotifier<int> pageContent = ValueNotifier(0);
  final ValueNotifier<bool> animate = ValueNotifier(false);
  final PageController pageController = PageController();
  bool fromLogin = false;

  String phoneNumber = '';
  String verificationId = '';
  String otp = '';
  Duration animationDuration = const Duration(milliseconds: 500);
  final FocusNode focusNode = FocusNode();
  late AuthBloc authBloc;
  int isVisWhatsApp = 0;
  // ignore: non_constant_identifier_names
  int PopScopeValue = 0;
  @override
  void initState() {
    LastPagesTracker.push('RegistrationPage');
    /* if (widget.fromExpiredToken ?? false) {
      Future.delayed(
        Duration(microseconds: 50),
        () {
          fromLogin = true;
          animationDuration = Duration(milliseconds: 500);
          animate.value = true;
          pageContent.value = 2;
          pageController.animateToPage(2,
              duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
        },
      );
    }*/

    authBloc = BlocProvider.of<AuthBloc>(context);
    super.initState();
  }

  @override
  void dispose() {
    focusNode.dispose(); // التخلص من FocusNode بشكل صحيح
    prefsRepository.setTimerForOtpRunning(false);
    super.dispose();
  }

  @override
  void didChangeDependencies() async {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xffFFFFFF),
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return PopScope(
      canPop: (widget.fromLogOut ?? false) ? false : true,
      onPopInvokedWithResult: (didPop, result) {
        if (widget.fromLogOut ?? false) {}
        Future.delayed(const Duration(milliseconds: 100), () {
          if (pageController.page == 2 || pageController.page == 1) {
            pageController.animateToPage(
              0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
            pageContent.value = 0;
            return;
          }
          if ((pageController.page ?? 0) >= 3 &&
              (pageController.page ?? 0) < 5) {
            pageContent.value = 2;
            pageController.animateToPage(
              2,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
            return;
          }
          // ignore: use_build_context_synchronously
          //context.go(GRouter.config.applicationRoutes.kBasePage);
        });
      },
      child: ValueListenableBuilder<int>(
        // ignore: sort_child_properties_last
        child: ValueListenableBuilder<bool>(
          // ignore: sort_child_properties_last
          child: logo,
          valueListenable: animate,
          builder: (context, yes, child) {
            return yes && pageContent.value > 1
                ? Padding(
                    padding: EdgeInsets.only(
                      left: 40.w,
                      right: 40.w,
                      top: 270.h,
                    ),
                    child: SizedBox(height: 375.h),
                  )
                : Directionality(
                    textDirection: TextDirection.ltr,
                    child: AnimatedPositioned(
                      left: yes ? 40.w : null,
                      right: yes ? 40.w : null,
                      top: 270.h,
                      bottom: yes ? null : 375.h,
                      duration: animationDuration,
                      child: child!,
                    ),
                  );
          },
        ),
        valueListenable: pageContent,
        builder: (ctx, index, child) {
          if (index < 2) {
            FocusScope.of(context).unfocus();
          } else if (index < 4) {
            Future.delayed(const Duration(seconds: 1), () {
              focusNode.requestFocus();
            });
          }
          return Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: index != 6
                ? context.colorScheme.surface
                : const Color(0xffF4FFF4),
            body: Stack(
              alignment: Alignment.topCenter,
              children: [
                child!,
                PositionedDirectional(
                  top: 60.h,
                  end: 30.h,
                  child: ValueListenableBuilder<int>(
                    valueListenable: pageContent,
                    builder: (context, index, _) {
                      return index < 2
                          ? SizedBox.shrink()
                          : InkWell(
                              highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              onTap: () async {
                                Future.delayed(
                                  const Duration(milliseconds: 100),
                                  () {
                                    /* if (index == 2 || index == 1) {
                                      pageController.animateToPage(
                                        0,
                                        duration: const Duration(
                                          milliseconds: 500,
                                        ),
                                        curve: Curves.easeInOut,
                                      );
                                      pageContent.value = 0;
                                      return;
                                    }*/

                                    if (index == 2) {
                                      if (fromLogin) {
                                        pageContent.value = 0;
                                        pageController.animateToPage(
                                          0,
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          curve: Curves.easeInOut,
                                        );
                                      } else {
                                        pageContent.value = 1;
                                        pageController.animateToPage(
                                          1,
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          curve: Curves.easeInOut,
                                        );
                                      }
                                    }
                                    if (index >= 3) {
                                      pageContent.value = index - 1;
                                      pageController.animateToPage(
                                        index - 1,
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        curve: Curves.easeInOut,
                                      );
                                      return;
                                    }
                                  },
                                );

                                //////////////////////////
                              },
                              child: Padding(
                                padding: HWEdgeInsets.only(
                                  top: 60.h,
                                  right: 30.w,
                                  left: 30.w,
                                  bottom: 60.h,
                                ),
                                child: SvgPicture.asset(
                                  AppAssets.cancelSvg,
                                  height: 15.h,
                                ),
                              ),
                            );
                    },
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height:
                          pageContent.value == 2 ||
                              pageContent.value == 3 ||
                              pageContent.value == 4
                          ? 640.h
                          : 385.h,
                      width: 1.sw,
                      // ignore: deprecated_member_use
                      child: WillPopScope(
                        child: PageView(
                          physics: const NeverScrollableScrollPhysics(),
                          onPageChanged: (value) => setState(() {
                            PopScopeValue = value;
                          }),
                          controller: pageController,
                          children: [
                            WelcomeSection(
                              goToLoginSection: () {
                                fromLogin = true;
                                animationDuration = const Duration(seconds: 1);
                                animate.value = true;
                                pageContent.value = 2;
                                pageController.jumpToPage(2);
                              },
                              goToCreateAccount: () {
                                fromLogin = false;
                                animate.value = true;
                                pageContent.value = 1;
                                pageController.animateToPage(
                                  1,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                                //_animationController.forward();
                              },
                            ),
                            CreateAccountSection(
                              moveToNextStep: () {
                                animationDuration = const Duration(seconds: 1);
                                pageContent.value = 2;
                                pageController.animateToPage(
                                  2,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                              },
                            ),
                            InsertPhoneTab(
                              fromLogin: fromLogin,
                              focusNode: focusNode,
                              moveToNextStep: (String phoneNumber) {
                                this.phoneNumber = phoneNumber.replaceAll(
                                  ' ',
                                  '',
                                );

                                pageContent.value = 3;

                                pageController.animateToPage(
                                  3,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                              },
                            ),
                            VerificationMethods(
                              phoneNumber: phoneNumber,
                              isFromLogin: fromLogin,
                              onChooseWhatsapp: () {
                                isVisWhatsApp = 1;
                                pageContent.value = 4;
                                pageController.animateToPage(
                                  4,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );

                                if (prefsRepository.isTimerForOtpRunning ??
                                    false) {
                                  showWarningMessage(
                                    context,
                                    LocaleKeys
                                        .you_must_wait_for_some_seconds_before_try_again
                                        .tr(),
                                  );
                                  return;
                                }
                                /*   authBloc.add(SendOtpEvent(
                                          phone: phoneNumber,
                                          isViaWhatsApp: 1));*/
                              },
                              goBackToPhone: () {
                                pageContent.value = 2;
                                pageController.animateToPage(
                                  2,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                              },
                              onChooseSms: () {
                                isVisWhatsApp = 0;
                                pageContent.value = 5;
                                pageController.animateToPage(
                                  4,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );

                                /*   authBloc.add(SendOtpEvent(
                                          phone: phoneNumber,
                                          isViaWhatsApp: 0));*/
                              },
                            ),
                            VerifyOtp(
                              goChangeNumber: () {
                                pageController.animateToPage(
                                  2,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                                pageContent.value = 3;
                              },
                              fromProfile: false,
                              navigateToProfile: () {},
                              fromExpired: false,
                              isVisWhatsApp: isVisWhatsApp,
                              navigateToAddName: () {
                                debugPrint('fromLogin:  $fromLogin');
                                if (fromLogin) {
                                  context.go(
                                    '${GRouter.config.applicationRoutes.kLoginSuccessfullyPagePath}?phoneNumber=${Uri.encodeQueryComponent(phoneNumber)}&fromLogin=true',
                                  );
                                  return;
                                }
                                fromLogin = false;
                                context.go(
                                  '${GRouter.config.applicationRoutes.kLoginSuccessfullyPagePath}?phoneNumber=${Uri.encodeQueryComponent(phoneNumber)}&fromLogin=false',
                                );

                                /*pageController.animateToPage(
                                  5,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                                pageContent.value = 6;*/
                              },
                              navigateTocartOrProfile: () {},
                              fromLogin: fromLogin,
                              onLoginFailed: () {
                                fromLogin = true;
                                pageController.animateToPage(
                                  5,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                                pageContent.value = 6;
                              },
                              goBack: () {
                                pageController.animateToPage(
                                  3,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                                pageContent.value = 3;
                              },
                              methodIcon: index == 4
                                  ? AppAssets.whatsappSvg
                                  : AppAssets.smsSvg,
                              phoneNumber: phoneNumber,
                            ),
                          ],
                        ),
                        onWillPop: () async {
                          if (pageController.page == 5.0) {
                            prefsRepository.setUserName("");
                            context.go(
                              '${GRouter.config.applicationRoutes.kRegistrationCompletedPage}?userName=',
                            );
                            return false;
                          }

                          if (PopScopeValue > 0) {
                            if (PopScopeValue == 2 && fromLogin) {
                              await pageController.animateToPage(
                                PopScopeValue - 2,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              );
                              pageContent.value = PopScopeValue - 2;
                              return false;
                            }
                            await pageController.animateToPage(
                              PopScopeValue - 1,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );

                            Future.delayed(
                              const Duration(milliseconds: 50),
                              () {
                                pageContent.value = PopScopeValue;
                              },
                            );

                            return false;
                          }

                          return true;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
