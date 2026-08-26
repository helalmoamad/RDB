import 'dart:async';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart' as trans;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:rdb/common/helper/helper_functions.dart';
import 'package:rdb/common/helper/show_message.dart';
import 'package:rdb/common/test_utils/test_var.dart';
import 'package:rdb/core/domin/repositories/prefs_repository.dart';
import 'package:rdb/core/utils/extensions/build_context.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:rdb/core/utils/form_utils.dart';
import 'package:rdb/core/utils/last_pages_tracker.dart';
import 'package:rdb/features/app/rdb_loading.dart';
import 'package:rdb/features/authentication/domain/entities/verify_otp_session_status.dart';
import 'package:rdb/features/authentication/presentation/widgets/pin_item.dart';
import 'package:rdb/generated/locale_keys.g.dart';
import 'package:rdb/main.dart';
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
    required this.goChangeNumber,
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
  final void Function() goChangeNumber;
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
  bool _isDisposed = false;

  PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  int endTime = (DateTime.now().millisecondsSinceEpoch + 1000 * 120);
  late final ValueNotifier<bool> enabledResendNotifier;
  late final ValueNotifier<int> checkOtp;

  int attempt = 1;

  static const TextEditingValue _emptyOtpValue = TextEditingValue(
    text: '\u200b',
    selection: TextSelection(baseOffset: 1, extentOffset: 1),
  );

  void onEnd() {
    if (!mounted || _isDisposed) {
      return;
    }

    prefsRepository.setTimerForOtpRunning(false);
    checkOtp.value = 0;
    enabledResendNotifier.value = true;
    for (final controller in form.controllers) {
      controller.value = _emptyOtpValue;
    }
    currentToType = 0;
    checkingOtp = false;
    FocusManager.instance.primaryFocus?.unfocus();
    ///////////////////////////
  }

  @override
  void initState() {
    // تنظيف أي تركيز/حالة عالقة من شاشة سابقة قبل بناء الخانات،
    // حتى تبدأ الخانة الأولى باتصال إدخال جديد وتظهر اللوحة بشكل موثوق.
    resetOtpFocusState();
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
            p.verifyOtpSignInStatus != c.verifyOtpSignInStatus,
        listener: (context, state) {
          if (state.verifyOtpSignInStatus == VerifyOtpSignInStatus.failure) {
            if (state.signInErrorMessage == 'User not found') {
              // قفل خانات الـ OTP قبل الانتقال إلى NumberNotRegistered حتى لا
              // يعيد أي مربع إظهار لوحة المفاتيح ويُحدث ومضة على الصفحة التالية.
              lockOtpKeyboard();
              Future.delayed(Duration(seconds: 2), () {
                FocusManager.instance.primaryFocus?.unfocus();
                // ignore: use_build_context_synchronously
                context.go(
                  '${GRouter.config.applicationRoutes.kNumberNotRegisteredPage}?phoneNumber=${widget.phoneNumber}',
                  extra: widget.onLoginFailed,
                );
              });
              GetIt.I<AuthBloc>().add(
                SaveErrorSigneInVerify(error: "ServerException"),
              );
              /////////////////////////////////////////////

              return;
            } else {}

            checkOtp.value = 2;
          } else if (state.verifyOtpSignInStatus ==
              VerifyOtpSignInStatus.success) {
            checkOtp.value = 1;

            // قفل خانات الـ OTP عند النجاح قبل الانتقال (LoginSuccessfully /
            // AlreadyExistAccount) حتى لا تعيد أي خانة إظهار اللوحة.
            lockOtpKeyboard();

            Future.delayed(const Duration(seconds: 1), () {
              // ضمان إضافي لحظة الانتقال الفعلي.
              lockOtpKeyboard();
              if (state.signInErrorMessage ==
                  VerifyOtpSessionStatus.requiresPasscode.value) {
                if (!widget.fromLogin) {
                  // ignore: use_build_context_synchronously
                  context.go(
                    '${GRouter.config.applicationRoutes.kUserExistPage}?phoneNumber=${widget.phoneNumber}',
                    extra: widget.onLoginFailed,
                  );
                  return;
                }
                widget.navigateToAddName.call();
                return;
                // ignore: use_build_context_synchronously
              } else {
                widget.navigateToAddName.call();
                widget.navigateTocartOrProfile.call();
              }
            });
            /////////////////////////////////
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          buildWhen: (p, c) =>
              p.verifyOtpSignInStatus != c.verifyOtpSignInStatus,
          builder: (context, state) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: HWEdgeInsets.symmetric(horizontal: 40.0.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyTextWidget(
                        widget.fromLogin
                            ? LocaleKeys.sign_in_exclamation.tr()
                            : LocaleKeys.sign_up_exclamation.tr(),
                        textAlign: TextAlign.center,
                        style: context.textTheme.titleMedium?.bq.copyWith(
                          color: const Color(0xff1D1D1D),
                          height: 1.25,
                          fontSize: 30.sp,
                        ),
                      ),

                      12.verticalSpace,
                      MyTextWidget(
                        LocaleKeys.enter_verification_code_whatsapp.tr(),
                        style: context.textTheme.titleMedium?.mq.copyWith(
                          color: const Color(0xff5D5C5D),
                          height: 1.42,
                          fontSize: 16.sp,
                        ),
                      ),
                      10.verticalSpace,

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            child: MyTextWidget(
                              LocaleKeys.we_have_sent_verification_code.tr(),
                              style: context.textTheme.titleMedium?.rq.copyWith(
                                color: const Color(0xff1D1D1D),
                                height: 1.42,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                          10.horizontalSpace,
                          SvgPicture.asset(
                            AppAssets.phoneOtpSvg,
                            width: 15.h,
                            height: 15.h,
                            // ignore: deprecated_member_use
                            color: const Color(0xff1D1D1D),
                          ),
                        ],
                      ),
                      10.verticalSpace,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          MyTextWidget(
                            "+ ${widget.phoneNumber}",
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: context.textTheme.titleMedium?.mq.copyWith(
                              color: const Color(0xff1D1D1D),
                              height: 1.42,
                              fontSize: 12.sp,
                            ),
                          ),
                          5.horizontalSpace,
                          ValueListenableBuilder<bool>(
                            valueListenable: enabledResendNotifier,
                            builder: (context, enabledResend, _) {
                              return (!enabledResend)
                                  ?
                                    // ignore: curly_braces_in_flow_control_structures
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        MyTextWidget(
                                          key: TestVariables.kTestMode
                                              ? const Key(
                                                  WidgetsKeys
                                                      .otpRemainingTimeKey,
                                                )
                                              : null,
                                          LocaleKeys.resend_after.tr(),
                                          style: context
                                              .textTheme
                                              .titleMedium
                                              ?.rq
                                              .copyWith(
                                                color: const Color(0xffC3C3C3),
                                                height: 1.25,
                                                fontSize: 12.sp,
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
                                                        WidgetsKeys
                                                            .otpRemainingTimeKey,
                                                      )
                                                    : null,
                                                '- 0${remainingTime?.min ?? '0'} : $seconds ',
                                                style: context
                                                    .textTheme
                                                    .titleMedium
                                                    ?.mq
                                                    .copyWith(
                                                      color: const Color(
                                                        0xff388CFF,
                                                      ),
                                                      height: 1.25,
                                                      fontSize: 12.sp,
                                                    ),
                                              );
                                            },
                                            controller:
                                                countdownTimerController,
                                            endWidget: const SizedBox(),
                                          ),
                                        ),
                                      ],
                                    )
                                  : MyTextWidget(
                                      LocaleKeys.didnt_receive_code_q.tr(),
                                      textAlign: TextAlign.start,

                                      maxLines: 1,
                                      style: context.textTheme.titleMedium?.rq
                                          .copyWith(
                                            color: const Color(0xffC3C3C3),
                                            height: 1.42,
                                            fontSize: 12.sp,
                                          ),
                                    );
                            },
                          ),

                          SizedBox(width: 5.w),
                          SvgPicture.asset(
                            AppAssets.grayQuestion,
                            width: 15.h,
                            height: 15.h,

                            // ignore: deprecated_member_use
                          ),
                        ],
                      ),

                      ValueListenableBuilder<bool>(
                        valueListenable: enabledResendNotifier,
                        builder: (context, enabledResend, _) {
                          return (enabledResend)
                              ? Padding(
                                  padding: EdgeInsets.only(top: 10.h),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      InkWell(
                                        onTap: _onResendSucceed,
                                        child: MyTextWidget(
                                          LocaleKeys.resend_code.tr(),
                                          textAlign: TextAlign.start,

                                          maxLines: 2,
                                          style: context
                                              .textTheme
                                              .titleMedium
                                              ?.mq
                                              .copyWith(
                                                color: const Color(0xff388CFF),
                                                height: 1.42,
                                                decoration:
                                                    TextDecoration.underline,
                                                decorationColor: const Color(
                                                  0xff388CFF,
                                                ),
                                                fontSize: 12.sp,
                                              ),
                                        ),
                                      ),
                                      5.horizontalSpace,
                                      MyTextWidget(
                                        LocaleKeys.or.tr(),
                                        textAlign: TextAlign.start,

                                        maxLines: 2,
                                        style: context.textTheme.titleMedium?.mq
                                            .copyWith(
                                              color: const Color(0xff1D1D1D),
                                              height: 1.42,

                                              fontSize: 12.sp,
                                            ),
                                      ),
                                      5.horizontalSpace,
                                      InkWell(
                                        onTap: widget.goChangeNumber,
                                        child: MyTextWidget(
                                          LocaleKeys.change_number.tr(),
                                          textAlign: TextAlign.start,

                                          maxLines: 2,
                                          style: context
                                              .textTheme
                                              .titleMedium
                                              ?.mq
                                              .copyWith(
                                                color: const Color(0xff388CFF),
                                                height: 1.42,
                                                decoration:
                                                    TextDecoration.underline,
                                                decorationColor: const Color(
                                                  0xff388CFF,
                                                ),
                                                fontSize: 12.sp,
                                              ),
                                        ),
                                      ),
                                      5.horizontalSpace,
                                      MyTextWidget(
                                        LocaleKeys.or.tr(),
                                        textAlign: TextAlign.start,

                                        maxLines: 2,
                                        style: context.textTheme.titleMedium?.mq
                                            .copyWith(
                                              color: const Color(0xff1D1D1D),
                                              height: 1.42,

                                              fontSize: 12.sp,
                                            ),
                                      ),
                                      5.horizontalSpace,
                                      InkWell(
                                        onTap: widget.goBack,
                                        child: MyTextWidget(
                                          LocaleKeys.method.tr(),
                                          textAlign: TextAlign.start,

                                          maxLines: 2,
                                          style: context
                                              .textTheme
                                              .titleMedium
                                              ?.mq
                                              .copyWith(
                                                color: const Color(0xff388CFF),
                                                height: 1.42,
                                                decoration:
                                                    TextDecoration.underline,
                                                decorationColor: const Color(
                                                  0xff388CFF,
                                                ),
                                                fontSize: 12.sp,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : SizedBox.shrink();
                        },
                      ),
                      10.verticalSpace,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          MyTextWidget(
                            LocaleKeys.your_privacy_safe.tr(),
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: context.textTheme.titleMedium?.rq.copyWith(
                              color: const Color(0xffC3C3C3),
                              height: 1.42,
                              fontSize: 11.sp,
                            ),
                          ),
                          10.horizontalSpace,
                          SvgPicture.asset(
                            AppAssets.privacySvg,
                            width: 15.h,
                            height: 15.h,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                45.verticalSpace,
                Padding(
                  padding: HWEdgeInsets.symmetric(horizontal: 20.0.w),
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
                                  SendOtpStatus.failure) {
                                return const _FailureWithTimerAndTryAgain();
                              }
                              // نُبقي خانات الـ OTP مُركّبة دائماً (حتى أثناء
                              // التحميل) حتى لا ينهار اتصال الإدخال فتنزل لوحة
                              // المفاتيح ثم تُعاد (وميض). مؤشّر التحميل طبقة فوقها.
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  Directionality(
                                  textDirection: ui.TextDirection.ltr,
                                  child: SizedBox(
                                    height: 60.w,
                                    width: 1.sw,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        PinItem(
                                          key: const Key('otp_item_1'),
                                          borderColor: codeStatus == 1
                                              ? const Color(0xff78D97F)
                                              : codeStatus == 2
                                              ? const Color(0xffFF5F61)
                                              : isExpired
                                              ? const Color(0xffFDCA57)
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
                                          // الإظهار يتم عبر requestOtpKeyboard()
                                          // عند استقرار صفحة الـ OTP في الـ PageView،
                                          // لا في initState (يقع أثناء الأنيميشن فيُهمَل).
                                          autoFocus: false,
                                        ),
                                        PinItem(
                                          key: const Key('otp_item_2'),
                                          borderColor: codeStatus == 1
                                              ? const Color(0xff78D97F)
                                              : codeStatus == 2
                                              ? const Color(0xffFF5F61)
                                              : isExpired
                                              ? const Color(0xffFDCA57)
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
                                              ? const Color(0xff78D97F)
                                              : codeStatus == 2
                                              ? const Color(0xffFF5F61)
                                              : isExpired
                                              ? const Color(0xffFDCA57)
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
                                              ? const Color(0xff78D97F)
                                              : codeStatus == 2
                                              ? const Color(0xffFF5F61)
                                              : isExpired
                                              ? const Color(0xffFDCA57)
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
                                              ? const Color(0xff78D97F)
                                              : codeStatus == 2
                                              ? const Color(0xffFF5F61)
                                              : isExpired
                                              ? const Color(0xffFDCA57)
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
                                              ? const Color(0xff78D97F)
                                              : codeStatus == 2
                                              ? const Color(0xffFF5F61)
                                              : isExpired
                                              ? const Color(0xffFDCA57)
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
                                          checkOtp: () async {
                                            // لا تُطبع sessionInfo — هي
                                            // verificationId الخاص بالـ OTP،
                                            // و debugPrint لا يُحذف في نسخة
                                            // الإصدار فتصل القيمة إلى logcat
                                            // وتقارير الأعطال.
                                            if (prefsRepository.sessionInfo !=
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

                                              authBloc.add(
                                                VerifyOtpSignInEvent(
                                                  sessionInfo: prefsRepository
                                                      .sessionInfo!,
                                                  otp: insertedCode,
                                                  phone: widget.phoneNumber,
                                                  action: widget.fromLogin
                                                      ? "signIn"
                                                      : "signUp",
                                                  // ignore: use_build_context_synchronously
                                                  msegatId: context
                                                      .read<AuthBloc>()
                                                      .state
                                                      .otpMsegatId,
                                                  // ignore: use_build_context_synchronously
                                                  provider: context
                                                      .read<AuthBloc>()
                                                      .state
                                                      .otpProvider,
                                                  platform:
                                                      "application", // or Platform.operatingSystem if imported
                                                  deviceId:
                                                      await HelperFunctions.getDeviceId(), // or another device id source
                                                  deviceInfo: {
                                                    "fcmToken": "",
                                                    'userAgent':
                                                        'device OS:${Platform.isAndroid ? 'Android' : 'IOS'} , application version: $applicationVersion',
                                                    // Add more device info if needed
                                                  },
                                                ),
                                              );
                                            } else {
                                              debugPrint(
                                                '/// verificationId is null //////',
                                              );
                                              showWarningMessage(
                                                context,
                                                LocaleKeys.please_wait_5_seconds
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
                                  ),
                                  if (state.sendOtpStatus ==
                                      SendOtpStatus.loading)
                                    Positioned.fill(
                                      child: ColoredBox(
                                        color: const Color(0xCCFFFFFF),
                                        child: Center(
                                          child: SizedBox(
                                            width: 20.w,
                                            height: 20.h,
                                            child: RDBLoader(size: 16.h),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
                10.verticalSpace,
                ValueListenableBuilder<int>(
                  valueListenable: checkOtp,
                  builder: (context, codeStatus, _) {
                    return codeStatus == 2
                        ? Center(
                            child: MyTextWidget(
                              LocaleKeys.enter_correct_code_phone.tr(),
                              style: context.textTheme.titleMedium?.mq.copyWith(
                                color: const Color(0xff1D1D1D),
                                height: 1.25,
                                fontSize: 11.sp,
                              ),
                            ),
                          )
                        : ValueListenableBuilder<bool>(
                            valueListenable: enabledResendNotifier,
                            builder: (context, enabledResend, _) {
                              return enabledResend
                                  ? Center(
                                      child: MyTextWidget(
                                        LocaleKeys.the_code_sent_has_expired
                                            .tr(),
                                        style: context.textTheme.titleMedium?.mq
                                            .copyWith(
                                              color: const Color(0xff1D1D1D),
                                              height: 1.25,
                                              fontSize: 11.sp,
                                            ),
                                      ),
                                    )
                                  : SizedBox.shrink();
                            },
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
    );
  }

  pasteOtpCode(String text) async {
    form.controllers[0].text = text[0];
    form.controllers[1].text = text[1];
    form.controllers[2].text = text[2];
    form.controllers[3].text = text[3];
    form.controllers[4].text = text[4];
    form.controllers[5].text = text[5];

    authBloc.add(
      VerifyOtpSignInEvent(
        sessionInfo: prefsRepository.sessionInfo!,
        otp: text,
        phone: widget.phoneNumber,
        action: widget.fromLogin ? "signIn" : "signUp",
        // ignore: use_build_context_synchronously
        msegatId: context.read<AuthBloc>().state.otpMsegatId,
        // ignore: use_build_context_synchronously
        provider: context.read<AuthBloc>().state.otpProvider,
        platform: "application", // or Platform.operatingSystem if imported
        deviceId:
            await HelperFunctions.getDeviceId(), // or another device id source
        deviceInfo: {
          "fcmToken": "",
          'userAgent':
              'device OS:${Platform.isAndroid ? 'Android' : 'IOS'} , application version: $applicationVersion',
          // Add more device info if needed
        }, // or use a real device info string
      ),
    );
  }

  void _onResendSucceed() {
    attempt = attempt + 1;

    endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 120;
    countdownTimerController?.disposeTimer();
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
  void dispose() {
    _isDisposed = true;
    countdownTimerController?.disposeTimer();
    enabledResendNotifier.dispose();
    checkOtp.dispose();
    super.dispose();
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
          fontSize: 12.sp,
          color: const Color(0xFF1D1D1D),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
