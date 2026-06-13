import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:rdb/common/constant/design/assets_provider.dart';
import 'package:rdb/core/domin/repositories/prefs_repository.dart';
import 'package:rdb/core/utils/extensions/build_context.dart';
import 'package:rdb/core/utils/form_state_mixin.dart';
import 'package:rdb/core/utils/form_utils.dart';
import 'package:rdb/core/utils/last_pages_tracker.dart';
import 'package:rdb/core/utils/responsive_padding.dart';
import 'package:rdb/features/app/my_text_widget.dart';
import 'package:rdb/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:rdb/generated/locale_keys.g.dart';
import 'package:rdb/theme/typography.dart';
import 'reset_pin_item.dart';

/// نسخة مستقلّة من صفحة التحقق من OTP خاصّة بتدفّق إعادة تعيين رمز المرور.
/// تستخدم نفس الـ API (VerifyOtpSignInEvent بـ action "signIn"). نتوقّف عند
/// نجاح التحقق (نستدعي onVerified)؛ بقية خطوات إعادة التعيين تُبنى لاحقاً.
class ResetVerifyOtp extends StatefulWidget {
  const ResetVerifyOtp({
    super.key,
    required this.phoneNumber,
    required this.isViaWhatsApp,
    required this.onVerified,
    required this.goBack,
  });

  final String phoneNumber;
  final int isViaWhatsApp;
  final void Function() onVerified;
  final void Function() goBack;

  @override
  State<ResetVerifyOtp> createState() => _ResetVerifyOtpState();
}

class _ResetVerifyOtpState extends State<ResetVerifyOtp> with FormStateMinxin {
  late AuthBloc authBloc;
  CountdownTimerController? countdownTimerController;
  bool _isDisposed = false;

  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  int endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 120;
  late final ValueNotifier<bool> enabledResendNotifier;

  /// 0: محايد، 1: نجاح، 2: رمز خاطئ.
  late final ValueNotifier<int> checkOtp;

  static const TextEditingValue _emptyOtpValue = TextEditingValue(
    text: '​',
    selection: TextSelection(baseOffset: 1, extentOffset: 1),
  );

  void onEnd() {
    if (!mounted || _isDisposed) return;
    prefsRepository.setTimerForOtpRunning(false);
    checkOtp.value = 0;
    enabledResendNotifier.value = true;
    for (final controller in form.controllers) {
      controller.value = _emptyOtpValue;
    }
    resetCurrentToType = 0;
    resetCheckingOtp = false;
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  void initState() {
    resetOtpFocusState();
    enabledResendNotifier = ValueNotifier<bool>(false);
    countdownTimerController = CountdownTimerController(
      endTime: endTime,
      onEnd: onEnd,
    );
    prefsRepository.setTimerForOtpRunning(true);
    checkOtp = ValueNotifier<int>(0);
    authBloc = GetIt.I<AuthBloc>();
    super.initState();
  }

  @override
  void dispose() {
    _isDisposed = true;
    countdownTimerController?.disposeTimer();
    enabledResendNotifier.dispose();
    checkOtp.dispose();
    super.dispose();
  }

  void _verify(String otp) {
    // endpoint إعادة التعيين: يأخذ phoneNumber + otpCode فقط (بلا sessionInfo).
    authBloc.add(
      ResetVerifyOtpEvent(phoneNumber: '+${widget.phoneNumber}', otpCode: otp),
    );
  }

  void _onResend() {
    endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 120;
    countdownTimerController?.disposeTimer();
    countdownTimerController = CountdownTimerController(
      endTime: endTime,
      onEnd: onEnd,
    );
    enabledResendNotifier.value = false;
    checkOtp.value = 0;
    authBloc.add(
      ResetSendOtpEvent(
        phoneNumber: '+${widget.phoneNumber}',
        channel: widget.isViaWhatsApp == 1 ? 'whatsapp' : 'sms',
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return BlocListener<AuthBloc, AuthState>(
      bloc: authBloc,
      listenWhen: (p, c) =>
          p.resetVerifyOtpStatus != c.resetVerifyOtpStatus,
      listener: (context, state) {
        if (state.resetVerifyOtpStatus == ResetVerifyOtpStatus.success) {
          checkOtp.value = 1;
          resetLockOtpKeyboard();
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) widget.onVerified();
          });
        } else if (state.resetVerifyOtpStatus ==
            ResetVerifyOtpStatus.failure) {
          checkOtp.value = 2;
        }
      },
      child: ValueListenableBuilder<int>(
        valueListenable: checkOtp,
        builder: (context, codeStatus, _) {
          return ValueListenableBuilder<bool>(
            valueListenable: enabledResendNotifier,
            builder: (context, isExpired, _) {
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
                          LocaleKeys.reset_passcode_title.tr(),
                          textAlign: TextAlign.start,
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
                          children: [
                            MyTextWidget(
                              LocaleKeys.we_have_sent_verification_code.tr(),
                              style: context.textTheme.titleMedium?.rq.copyWith(
                                color: const Color(0xff1D1D1D),
                                height: 1.42,
                                fontSize: 12.sp,
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
                          children: [
                            MyTextWidget(
                              "+ ${widget.phoneNumber}",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: context.textTheme.titleMedium?.mq.copyWith(
                                color: const Color(0xff1D1D1D),
                                height: 1.42,
                                fontSize: 12.sp,
                              ),
                            ),
                            5.horizontalSpace,
                            if (!isExpired)
                              Directionality(
                                textDirection: ui.TextDirection.ltr,
                                child: Row(
                                  children: [
                                    MyTextWidget(
                                      "${LocaleKeys.resend_after.tr()} ",
                                      style: context.textTheme.titleMedium?.rq
                                          .copyWith(
                                            color: const Color(0xffC3C3C3),
                                            height: 1.25,
                                            fontSize: 12.sp,
                                          ),
                                    ),
                                    CountdownTimer(
                                      controller: countdownTimerController,
                                      endWidget: const SizedBox(),
                                      widgetBuilder: (_, remainingTime) {
                                        final sec = (remainingTime?.sec ?? 0) < 10
                                            ? '0${remainingTime?.sec ?? 0}'
                                            : '${remainingTime?.sec}';
                                        return MyTextWidget(
                                          '0${remainingTime?.min ?? 0} : $sec',
                                          style: context
                                              .textTheme
                                              .titleMedium
                                              ?.mq
                                              .copyWith(
                                                color: const Color(0xff388CFF),
                                                height: 1.25,
                                                fontSize: 12.sp,
                                              ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              )
                            else
                              InkWell(
                                onTap: _onResend,
                                child: MyTextWidget(
                                  LocaleKeys.resend_code.tr(),
                                  style: context.textTheme.titleMedium?.mq
                                      .copyWith(
                                        color: const Color(0xff388CFF),
                                        height: 1.42,
                                        decoration: TextDecoration.underline,
                                        decorationColor: const Color(
                                          0xff388CFF,
                                        ),
                                        fontSize: 12.sp,
                                      ),
                                ),
                              ),
                          ],
                        ),
                        10.verticalSpace,
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            MyTextWidget(
                              LocaleKeys.your_privacy_safe.tr(),
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
                    child: Directionality(
                      textDirection: ui.TextDirection.ltr,
                      child: SizedBox(
                        height: 60.w,
                        width: 1.sw,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, (i) {
                            return ResetPinItem(
                              key: Key('reset_otp_item_${i + 1}'),
                              index: i,
                              isExpired: isExpired,
                              wrongCode: codeStatus == 2,
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
                              controller: form.controllers[i],
                              onChange: () => checkOtp.value = 0,
                              pasteOtpCode: i == 0
                                  ? (text) => _verify(text)
                                  : null,
                              checkOtp: i == 5
                                  ? () {
                                      final code = form.controllers
                                          .map((c) => c.text)
                                          .join();
                                      _verify(code);
                                    }
                                  : null,
                              autoFocus: false,
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                  10.verticalSpace,
                  if (codeStatus == 2)
                    Center(
                      child: MyTextWidget(
                        LocaleKeys.enter_correct_code_phone.tr(),
                        style: context.textTheme.titleMedium?.mq.copyWith(
                          color: const Color(0xff1D1D1D),
                          height: 1.25,
                          fontSize: 11.sp,
                        ),
                      ),
                    )
                  else if (isExpired)
                    Center(
                      child: MyTextWidget(
                        LocaleKeys.the_code_sent_has_expired.tr(),
                        style: context.textTheme.titleMedium?.mq.copyWith(
                          color: const Color(0xff1D1D1D),
                          height: 1.25,
                          fontSize: 11.sp,
                        ),
                      ),
                    ),
                  40.verticalSpace,
                ],
              );
            },
          );
        },
      ),
    );
  }

  @override
  int get numberOfFields => 6;
}
