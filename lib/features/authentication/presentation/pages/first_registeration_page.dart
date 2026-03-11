import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:rdb/base_page.dart';
import 'package:rdb/common/test_utils/test_var.dart';
import 'package:rdb/core/utils/extensions/build_context.dart';
import 'package:rdb/features/authentication/presentation/widgets/create_account_section.dart';
import '../../../../common/test_utils/widgets_keys.dart';
import '../../../../common/helper/show_message.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../core/utils/responsive_padding.dart';
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
          context.go(GRouter.config.applicationRoutes.kBasePage);
        });
      },
      child: ValueListenableBuilder<int>(
        // ignore: sort_child_properties_last
        child: ValueListenableBuilder<bool>(
          // ignore: sort_child_properties_last
          child: Container(margin: const EdgeInsets.only(top: 20), child: logo),
          valueListenable: animate,
          builder: (context, yes, child) {
            return Directionality(
              textDirection: TextDirection.ltr,
              child: AnimatedPositioned(
                left: yes ? 40 : null,
                right: yes ? 40 : null,
                top: yes ? 50 : null,
                bottom: yes ? null : 465.h,
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
          } else if (index != 6) {
            focusNode.requestFocus();
          }
          return Scaffold(
            backgroundColor: index != 6
                ? context.colorScheme.surface
                : const Color(0xffF4FFF4),
            body: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                child!,
                Positioned(
                  top: 10,
                  right: 0,
                  child: ValueListenableBuilder<int>(
                    valueListenable: pageContent,
                    builder: (context, index, _) {
                      return index == 0
                          ? SizedBox.shrink()
                          : InkWell(
                              key: TestVariables.kTestMode
                                  ? const Key(WidgetsKeys.registerCancelKey)
                                  : null,
                              highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              onTap: () async {
                                if (widget.fromLogOut ?? false) {
                                  return;
                                }
                                Future.delayed(
                                  const Duration(milliseconds: 100),
                                  () {
                                    if (index == 2 || index == 1) {
                                      pageController.animateToPage(
                                        0,
                                        duration: const Duration(
                                          milliseconds: 500,
                                        ),
                                        curve: Curves.easeInOut,
                                      );
                                      pageContent.value = 0;
                                      return;
                                    }
                                    if (index >= 3 && index <= 5) {
                                      pageContent.value = 2;
                                      pageController.animateToPage(
                                        2,
                                        duration: const Duration(
                                          milliseconds: 500,
                                        ),
                                        curve: Curves.easeInOut,
                                      );
                                      return;
                                    }
                                  },
                                );
                                if (Navigator.canPop(context)) {
                                  Navigator.of(context).pop();
                                }
                                //////////////////////////
                              },
                              child: Padding(
                                padding: HWEdgeInsets.only(
                                  top: 60.0,
                                  right: 30,
                                  left: 30,
                                  bottom: 60,
                                ),
                                child: SvgPicture.asset(AppAssets.cancelSvg),
                              ),
                            );
                    },
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(height: 96.h),
                    SizedBox(
                      height: 1.sh / 2.5,
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
                                pageController.animateToPage(
                                  2,
                                  duration: const Duration(milliseconds: 100),
                                  curve: Curves.easeInOut,
                                );
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
                                    'you must wait for some seconds before try again',
                                  );
                                  return;
                                }
                                /*   authBloc.add(SendOtpEvent(
                                          phone: phoneNumber,
                                          isViaWhatsApp: 1));*/
                              },
                              goBackToPhone: () {
                                pageController.animateToPage(
                                  2,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                                pageContent.value = 2;
                              },
                              onChooseSms: () {
                                isVisWhatsApp = 0;
                                pageController.animateToPage(
                                  4,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                                pageContent.value = 5;
                                /*   authBloc.add(SendOtpEvent(
                                          phone: phoneNumber,
                                          isViaWhatsApp: 0));*/
                              },
                            ),
                            VerifyOtp(
                              fromProfile: false,
                              navigateToProfile: () {},
                              fromExpired: false,
                              isVisWhatsApp: isVisWhatsApp,
                              navigateToAddName: () {
                                debugPrint('fromLogin:  $fromLogin');
                                if (fromLogin) {
                                  context.go(
                                    GRouter.config.applicationRoutes.kBasePage,
                                  );
                                  return;
                                }
                                fromLogin = false;
                                context.go(
                                  GRouter.config.applicationRoutes.kBasePage,
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
                              return false;
                            }
                            await pageController.animateToPage(
                              PopScopeValue - 1,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
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
