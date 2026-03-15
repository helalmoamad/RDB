import 'dart:async';
import 'package:easy_localization/easy_localization.dart' as trans;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:rdb/common/helper/show_message.dart';
import 'package:rdb/common/test_utils/test_var.dart';
import 'package:rdb/core/domin/repositories/prefs_repository.dart';
import 'package:rdb/core/utils/extensions/build_context.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:rdb/core/utils/form_utils.dart';
import 'package:rdb/core/utils/last_pages_tracker.dart';
import 'package:rdb/features/authentication/presentation/widgets/pin_item.dart';
import 'package:rdb/generated/locale_keys.g.dart';
import 'package:rdb/theme/typography.dart';
import '../../../../common/constant/design/assets_provider.dart';
import '../../../../common/test_utils/widgets_keys.dart';
import '../../../../core/utils/form_state_mixin.dart';
import '../../../../core/utils/responsive_padding.dart';
import '../../../../routes/router.dart';
import '../../../app/my_text_widget.dart';
import '../manager/auth_bloc.dart';
import 'dart:ui' as ui;

class VerifyOtp extends StatefulWidget {
  const VerifyOtp({
    super.key,
    required this.methodIcon,
    required this.fromLogin,
    required this.isVisWhatsApp,
    required this.navigateToAddName,
    required this.navigateTocartOrProfile,
    required this.onLoginFailed,
    required this.goBack,
    required this.navigateToProfile,
    required this.fromProfile,
    required this.fromExpired,
    required this.phoneNumber,
  });
  final String methodIcon;
  final bool fromLogin;
  final bool fromExpired;
  final bool fromProfile;
  final String phoneNumber;
  final void Function() onLoginFailed;
  final void Function() goBack;
  final void Function() navigateToAddName;
  final void Function() navigateTocartOrProfile;
  final void Function() navigateToProfile;
  final int isVisWhatsApp;
  @override
  State<VerifyOtp> createState() => _VerifyOtpState();
}

class _VerifyOtpState extends State<VerifyOtp> with FormStateMinxin {
  late AuthBloc authBloc;
  CountdownTimerController? countdownTimerController;

  PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  int endTime = (DateTime.now().millisecondsSinceEpoch + 1000 * 120);
  late final ValueNotifier<bool> enabledResendNotifier;
  late final ValueNotifier<int> checkOtp;

  int attempt = 1;

  void onEnd() {
    prefsRepository.setTimerForOtpRunning(false);
    checkOtp.value = 0;
    enabledResendNotifier.value = true;
    ///////////////////////////
  }

  @override
  void initState() {
    enabledResendNotifier = ValueNotifier<bool>(false);
    if (countdownTimerController == null) {
      countdownTimerController = CountdownTimerController(
        endTime: endTime,
        onEnd: onEnd,
      );
      prefsRepository.setTimerForOtpRunning(true);
    }
    checkOtp = ValueNotifier<int>(0);
    authBloc = BlocProvider.of<AuthBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (p, c) =>
          p.sendOtpStatus != c.sendOtpStatus &&
          c.sendOtpStatus == SendOtpStatus.failure,
      listener: (context, state) {
        //   showWarningMessage(context, state.sendOtpError.toString());
      },
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (p, c) =>
            p.verifyOtpFromGuestStatus != c.verifyOtpFromGuestStatus,
        listener: (context, state) {
          if (state.verifyOtpFromGuestStatus ==
              VerifyOtpFromGuestStatus.failure) {
            checkOtp.value = 2;
          } else if (state.verifyOtpFromGuestStatus ==
              VerifyOtpFromGuestStatus.success) {
            checkOtp.value = 1;
            widget.navigateTocartOrProfile.call();
            Future.delayed(const Duration(milliseconds: 700), () {
              widget.navigateToAddName.call();
            });
          }
        },
        child: BlocListener<AuthBloc, AuthState>(
          listenWhen: (p, c) =>
              p.verifyOtpSignInStatus != c.verifyOtpSignInStatus,
          listener: (context, state) {
            if (state.verifyOtpSignInStatus == VerifyOtpSignInStatus.failure) {
              if (!widget.fromExpired && !widget.fromProfile) {
                if (state.signInErrorMessage == 'auth-001') {
                  context.go(
                    '${GRouter.config.applicationRoutes.kNumberNotRegisteredPage}?phoneNumber=${widget.phoneNumber}',
                    extra: widget.onLoginFailed,
                  );
                  /////////////////////////////////////////////

                  return;
                } else {}
              }
              checkOtp.value = 2;
            } else if (state.verifyOtpSignInStatus ==
                VerifyOtpSignInStatus.success) {
              checkOtp.value = 1;

              Future.delayed(const Duration(milliseconds: 700), () {
                widget.navigateToAddName.call();
              });
              /////////////////////////////////
            }
          },
          child: BlocListener<AuthBloc, AuthState>(
            listenWhen: (p, c) =>
                p.verifyOtpSignUpStatus != c.verifyOtpSignUpStatus,
            listener: (context, state) {
              if (state.verifyOtpSignUpStatus ==
                  VerifyOtpSignUpStatus.failure) {
                if (state.signUpErrorMessage == 'auth-001') {
                  debugPrint('auth-00122');
                  context.go(
                    '${GRouter.config.applicationRoutes.kUserExistPage}?phoneNumber=${widget.phoneNumber}',
                  );
                  /////////////////////////

                  return;
                }

                checkOtp.value = 2;
              } else if (state.verifyOtpSignUpStatus ==
                  VerifyOtpSignUpStatus.success) {
                checkOtp.value = 1;

                Future.delayed(const Duration(milliseconds: 700), () {
                  widget.navigateToAddName.call();
                });
                /////////////////////////
              }
            },
            child: BlocBuilder<AuthBloc, AuthState>(
              buildWhen: (p, c) =>
                  p.verifyOtpSignInStatus != c.verifyOtpSignInStatus ||
                  p.verifyOtpSignUpStatus != c.verifyOtpSignUpStatus,
              builder: (context, state) {
                return Column(
                  mainAxisAlignment:
                      (state.verifyOtpFromGuestStatus !=
                              VerifyOtpFromGuestStatus.loading &&
                          state.verifyOtpFromGuestStatus !=
                              VerifyOtpFromGuestStatus.success &&
                          state.verifyOtpSignInStatus !=
                              VerifyOtpSignInStatus.loading &&
                          state.verifyOtpSignUpStatus !=
                              VerifyOtpSignUpStatus.loading &&
                          state.verifyOtpSignInStatus !=
                              VerifyOtpSignInStatus.success &&
                          state.verifyOtpSignUpStatus !=
                              VerifyOtpSignUpStatus.success)
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.start,
                  children: [
                    50.verticalSpace,
                    MyTextWidget(
                      LocaleKeys.verify_your_account.tr(),
                      textAlign: TextAlign.center,
                      style: context.textTheme.titleMedium?.bq.copyWith(
                        color: const Color(0xff1D1D1D),
                        height: 1.25,
                        fontSize: 20,
                      ),
                    ),
                    30.verticalSpace,
                    SvgPicture.asset(
                      AppAssets.phoneCallOutlinedSvg,
                      width: 25,
                      colorFilter: ColorFilter.mode(
                        Colors.grey,
                        BlendMode.srcIn,
                      ),
                    ),
                    30.verticalSpace,

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IgnorePointer(
                          child: Icon(
                            Icons.info_outline,
                            color: Color.fromARGB(255, 179, 179, 179),
                            size: 15,
                          ),
                        ),
                        6.horizontalSpace,
                        MyTextWidget(
                          '${LocaleKeys.please_enter_the_verification_cod.tr()} ${widget.methodIcon == AppAssets.whatsappSvg ? LocaleKeys.whatsApp.tr() : LocaleKeys.sms.tr()}',
                          style: context.textTheme.titleMedium?.rq.copyWith(
                            color: const Color(0xff8e8e8e),
                            height: 1.25,
                          ),
                        ),
                        6.horizontalSpace,
                        InkWell(
                          onTap: () {
                            widget.goBack();
                          },
                          child: IgnorePointer(
                            child: Icon(
                              Icons.swap_horiz_outlined,
                              color: Color(0xff4D84FF),
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    15.verticalSpace,
                    MyTextWidget(
                      "+${widget.phoneNumber}",
                      style: context.textTheme.titleMedium?.bq.copyWith(
                        color: const Color(0xff1D1D1D),
                        height: 1.25,
                        fontSize: 13,
                      ),
                    ),
                    15.verticalSpace,

                    /*   ValueListenableBuilder<bool>(
                      valueListenable: enabledResendNotifier,
                      builder: (context, resend, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SvgPicture.asset(
                                  AppAssets.registerInfoSvg,
                                  width: 10,
                                  height: 10,
                                ),

                                4.horizontalSpace,
                              ],
                            ),
                             resend
                                ? Padding(
                                    padding: HWEdgeInsets.only(left: 15.0),
                                    child: InkWell(
                                      onTap: widget.goBack,
                                      child: MyTextWidget(
                                        LocaleKeys.the_method_of_receiving.tr(),
                                        maxLines: 2,
                                        style: context.textTheme.titleMedium?.rq
                                            .copyWith(
                                              color: const Color(0xff4D84FF),
                                              height: 1.25,
                                            ),
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ],
                        );
                      },
                    ),*/
                    25.verticalSpace,
                    Padding(
                      padding: HWEdgeInsets.symmetric(horizontal: 20.0),
                      child: ValueListenableBuilder<bool>(
                        valueListenable: enabledResendNotifier,
                        builder: (context, isExpired, _) {
                          return ValueListenableBuilder<int>(
                            valueListenable: checkOtp,
                            builder: (context, codeStatus, _) {
                              return BlocBuilder<AuthBloc, AuthState>(
                                buildWhen: (p, c) =>
                                    p.sendOtpStatus != c.sendOtpStatus,
                                builder: (context, state) {
                                  if (state.sendOtpStatus ==
                                      SendOtpStatus.loading) {
                                    return const Center(
                                      child: SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    );
                                  } else if (state.sendOtpStatus ==
                                      SendOtpStatus.failure) {
                                    return const _FailureWithTimerAndTryAgain();
                                  } else {
                                    // success أو الحالة الافتراضية: الحقول كما هي الآن
                                    return Directionality(
                                      textDirection: ui.TextDirection.ltr,
                                      child: SizedBox(
                                        height: 60.w,
                                        width: 1.sw - 70.w,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            PinItem(
                                              key: const Key('otp_item_1'),
                                              borderColor: codeStatus == 1
                                                  ? const Color(0xff35CE3F)
                                                  : codeStatus == 2
                                                  ? const Color(0xffFF5F61)
                                                  : isExpired
                                                  ? const Color(0xffFFBC26)
                                                  : const Color(0xff4D84FF),
                                              isExpired: isExpired,
                                              contentColor: codeStatus == 1
                                                  ? const Color(0xffF4FFF4)
                                                  : codeStatus == 2
                                                  ? const Color(0xffFDF5F5)
                                                  : const Color(0xffFAFAFA),
                                              controller: form.controllers[0],
                                              wrongCode: codeStatus == 2,
                                              index: 0,
                                              pasteOtpCode: pasteOtpCode,
                                              onChange: () {
                                                checkOtp.value = 0;
                                              },
                                              autoFocus: true,
                                            ),
                                            PinItem(
                                              key: const Key('otp_item_2'),
                                              borderColor: codeStatus == 1
                                                  ? const Color(0xff35CE3F)
                                                  : codeStatus == 2
                                                  ? const Color(0xffFF5F61)
                                                  : isExpired
                                                  ? const Color(0xffFFBC26)
                                                  : const Color(0xff4D84FF),
                                              contentColor: codeStatus == 1
                                                  ? const Color(0xffF4FFF4)
                                                  : codeStatus == 2
                                                  ? const Color(0xffFDF5F5)
                                                  : const Color(0xffFAFAFA),
                                              isExpired: isExpired,
                                              controller: form.controllers[1],
                                              wrongCode: codeStatus == 2,
                                              index: 1,
                                              onChange: () {
                                                checkOtp.value = 0;
                                              },
                                              autoFocus: false,
                                            ),
                                            PinItem(
                                              key: const Key('otp_item_3'),
                                              borderColor: codeStatus == 1
                                                  ? const Color(0xff35CE3F)
                                                  : codeStatus == 2
                                                  ? const Color(0xffFF5F61)
                                                  : isExpired
                                                  ? const Color(0xffFFBC26)
                                                  : const Color(0xff4D84FF),
                                              isExpired: isExpired,
                                              contentColor: codeStatus == 1
                                                  ? const Color(0xffF4FFF4)
                                                  : codeStatus == 2
                                                  ? const Color(0xffFDF5F5)
                                                  : const Color(0xffFAFAFA),
                                              index: 2,
                                              wrongCode: codeStatus == 2,
                                              onChange: () {
                                                checkOtp.value = 0;
                                              },
                                              controller: form.controllers[2],
                                              autoFocus: false,
                                            ),
                                            PinItem(
                                              key: const Key('otp_item_4'),
                                              borderColor: codeStatus == 1
                                                  ? const Color(0xff35CE3F)
                                                  : codeStatus == 2
                                                  ? const Color(0xffFF5F61)
                                                  : isExpired
                                                  ? const Color(0xffFFBC26)
                                                  : const Color(0xff4D84FF),
                                              isExpired: isExpired,
                                              contentColor: codeStatus == 1
                                                  ? const Color(0xffF4FFF4)
                                                  : codeStatus == 2
                                                  ? const Color(0xffFDF5F5)
                                                  : const Color(0xffFAFAFA),
                                              index: 3,
                                              wrongCode: codeStatus == 2,
                                              onChange: () {
                                                checkOtp.value = 0;
                                              },
                                              controller: form.controllers[3],
                                              autoFocus: false,
                                            ),
                                            PinItem(
                                              key: const Key('otp_item_5'),
                                              borderColor: codeStatus == 1
                                                  ? const Color(0xff35CE3F)
                                                  : codeStatus == 2
                                                  ? const Color(0xffFF5F61)
                                                  : isExpired
                                                  ? const Color(0xffFFBC26)
                                                  : const Color(0xff4D84FF),
                                              contentColor: codeStatus == 1
                                                  ? const Color(0xffF4FFF4)
                                                  : codeStatus == 2
                                                  ? const Color(0xffFDF5F5)
                                                  : const Color(0xffFAFAFA),
                                              isExpired: isExpired,
                                              index: 4,
                                              wrongCode: codeStatus == 2,
                                              onChange: () {
                                                checkOtp.value = 0;
                                              },
                                              controller: form.controllers[4],
                                              autoFocus: false,
                                            ),
                                            PinItem(
                                              key: const Key('otp_item_6'),
                                              borderColor: codeStatus == 1
                                                  ? const Color(0xff35CE3F)
                                                  : codeStatus == 2
                                                  ? const Color(0xffFF5F61)
                                                  : isExpired
                                                  ? const Color(0xffFFBC26)
                                                  : const Color(0xff4D84FF),
                                              isExpired: isExpired,
                                              contentColor: codeStatus == 1
                                                  ? const Color(0xffF4FFF4)
                                                  : codeStatus == 2
                                                  ? const Color(0xffFDF5F5)
                                                  : const Color(0xffFAFAFA),
                                              index: 5,
                                              wrongCode: codeStatus == 2,
                                              onChange: () {
                                                checkOtp.value = 0;
                                              },
                                              checkOtp: () {
                                                debugPrint(
                                                  '/// checkOtp //////',
                                                );
                                                debugPrint(
                                                  prefsRepository.sessionInfo,
                                                );
                                                if (prefsRepository
                                                        .sessionInfo !=
                                                    null) {
                                                  debugPrint(
                                                    '/// verificationId not null //////',
                                                  );
                                                  String insertedCode =
                                                      form.controllers[0].text +
                                                      form.controllers[1].text +
                                                      form.controllers[2].text +
                                                      form.controllers[3].text +
                                                      form.controllers[4].text +
                                                      form.controllers[5].text;
                                                  if (widget.fromLogin) {
                                                    debugPrint(
                                                      '/// fromLogin //////',
                                                    );

                                                    authBloc.add(
                                                      VerifyOtpSignInEvent(
                                                        sessionInfo:
                                                            prefsRepository
                                                                .sessionInfo!,
                                                        otp: insertedCode,
                                                        phone:
                                                            widget.phoneNumber,
                                                      ),
                                                    );

                                                    /////////////////////////////////////
                                                  } else {
                                                    authBloc.add(
                                                      VerifyOtpSignUpEvent(
                                                        sessionInfo:
                                                            prefsRepository
                                                                .sessionInfo!,
                                                        otp: insertedCode,
                                                        phone:
                                                            widget.phoneNumber,
                                                      ),
                                                    );

                                                    /////////////////////////////////////
                                                  }
                                                } else {
                                                  debugPrint(
                                                    '/// verificationId is null //////',
                                                  );
                                                  showWarningMessage(
                                                    context,
                                                    LocaleKeys
                                                        .please_wait_5_seconds
                                                        .tr(),
                                                  );
                                                  pasteOtpCode('');
                                                  //widget.checkOtp.value = 2;
                                                  /////////////////////////////////////
                                                }
                                              },
                                              controller: form.controllers[5],
                                              autoFocus: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                    10.verticalSpace,
                    ValueListenableBuilder<bool>(
                      valueListenable: enabledResendNotifier,
                      builder: (context, enabledResend, _) {
                        if (!enabledResend)
                          // ignore: curly_braces_in_flow_control_structures
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              MyTextWidget(
                                key: TestVariables.kTestMode
                                    ? const Key(WidgetsKeys.otpRemainingTimeKey)
                                    : null,
                                '${LocaleKeys.resend_code.tr()}  ',
                                style: context.textTheme.titleMedium?.rq
                                    .copyWith(
                                      color: enabledResend
                                          ? const Color(0xff4D84FF)
                                          : const Color.fromARGB(
                                              255,
                                              187,
                                              187,
                                              187,
                                            ),
                                      height: 1.25,
                                    ),
                              ),
                              Directionality(
                                textDirection: ui.TextDirection.ltr,
                                child: CountdownTimer(
                                  widgetBuilder: (_, remainingTime) {
                                    String seconds =
                                        (remainingTime?.sec ?? 0) < 10
                                        ? '0${remainingTime?.sec}'
                                        : '${remainingTime?.sec}';
                                    return MyTextWidget(
                                      key: TestVariables.kTestMode
                                          ? const Key(
                                              WidgetsKeys.otpRemainingTimeKey,
                                            )
                                          : null,
                                      '0${remainingTime?.min ?? '0'} : $seconds ',
                                      style: context.textTheme.titleMedium?.rq
                                          .copyWith(
                                            color: const Color(0xff4D84FF),
                                            height: 1.25,
                                          ),
                                    );
                                  },
                                  controller: countdownTimerController,
                                  endWidget: const SizedBox(),
                                ),
                              ),
                            ],
                          );
                        return InkWell(
                          onTap: enabledResend ? _onResendSucceed : null,
                          child: MyTextWidget(
                            key: TestVariables.kTestMode
                                ? const Key(WidgetsKeys.resendCodeButtonKey)
                                : null,
                            "${LocaleKeys.resend_code.tr()} ",
                            style: context.textTheme.titleMedium?.rq.copyWith(
                              color: const Color(0xff4D84FF),
                              height: 1.25,
                            ),
                          ),
                        );
                      },
                    ),
                    40.verticalSpace,
                    /* (checkOtp.value == 2 || enabledResendNotifier.value)
                        ? 20.verticalSpace
                        : 120.verticalSpace,
                    ValueListenableBuilder<int>(
                      valueListenable: checkOtp,
                      builder: (context, codeStatus, _) {
                        return ValueListenableBuilder<bool>(
                          valueListenable: enabledResendNotifier,
                          builder: (context, isExpired, _) {
                            return codeStatus == 2 || isExpired
                                ? Column(
                                    children: [
                                      MyTextWidget(
                                        codeStatus == 2
                                            ? LocaleKeys
                                                  .please_correct_code_sent_to_your_phone
                                                  .tr()
                                            : LocaleKeys
                                                  .the_code_sent_has_expired
                                                  .tr(),
                                        style: context.textTheme.titleMedium?.rq
                                            .copyWith(
                                              color: const Color(0xff5D5C5D),
                                              height: 1.25,
                                            ),
                                      ),
                                      100.verticalSpace,
                                    ],
                                  )
                                : const SizedBox.shrink();
                          },
                        );
                      },
                    ),*/
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  pasteOtpCode(String text) {
    form.controllers[0].text = text[0];
    form.controllers[1].text = text[1];
    form.controllers[2].text = text[2];
    form.controllers[3].text = text[3];
    form.controllers[4].text = text[4];
    form.controllers[5].text = text[5];
    if (widget.fromLogin) {
      authBloc.add(
        VerifyOtpSignInEvent(
          sessionInfo: prefsRepository.sessionInfo!,
          otp: text,
          phone: widget.phoneNumber,
        ),
      );
    } else {
      authBloc.add(
        VerifyOtpSignUpEvent(
          sessionInfo: prefsRepository.sessionInfo!,
          otp: text,
          phone: widget.phoneNumber,
        ),
      );
    }
  }

  void _onResendSucceed() {
    attempt = attempt + 1;

    endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 120;
    countdownTimerController = CountdownTimerController(
      endTime: endTime,
      onEnd: onEnd,
    );
    enabledResendNotifier.value = false;
    checkOtp.value = 0;
    authBloc.add(
      SendOtpEvent(
        isResend: true,
        isSignUp: !widget.fromLogin,
        phone: widget.phoneNumber,
        isViaWhatsApp: widget.isVisWhatsApp,
      ),
    );
    ////////////////////
  }

  @override
  int get numberOfFields => 6;
}

class _FailureWithTimerAndTryAgain extends StatelessWidget {
  const _FailureWithTimerAndTryAgain();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: MyTextWidget(
        LocaleKeys.otp_error_try_again_later.tr(),
        style: Theme.of(context).textTheme.bodySmall?.rq.copyWith(
          fontSize: 12,
          color: const Color(0xFF1D1D1D),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
