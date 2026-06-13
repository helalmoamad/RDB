import 'dart:async';
import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:rdb/common/constant/design/assets_provider.dart';
import 'package:rdb/core/utils/extensions/build_context.dart';
import 'package:rdb/core/utils/last_pages_tracker.dart';
import 'package:rdb/core/utils/responsive_padding.dart';
import 'package:rdb/features/app/my_text_widget.dart';
import 'package:rdb/features/authentication/presentation/manager/auth_bloc.dart';
import 'reset_shimmer.dart';
import 'package:rdb/generated/locale_keys.g.dart';
import 'package:rdb/theme/typography.dart';

/// نسخة مستقلّة من صفحة اختيار طريقة الإرسال خاصّة بتدفّق إعادة تعيين رمز المرور.
/// تستخدم نفس الـ API (SendOtpEvent) بسلوك "تسجيل دخول" (isSignUp: false).
class ResetVerificationMethods extends StatefulWidget {
  const ResetVerificationMethods({
    super.key,
    required this.phoneNumber,
    required this.goBackToPhone,
    required this.onChooseWhatsapp,
    required this.onChooseSms,
  });

  final String phoneNumber;
  final void Function() onChooseWhatsapp;
  final void Function() onChooseSms;
  final void Function() goBackToPhone;

  @override
  State<ResetVerificationMethods> createState() =>
      _ResetVerificationMethodsState();
}

class _ResetVerificationMethodsState extends State<ResetVerificationMethods> {
  final ValueNotifier<int> clickButton = ValueNotifier(-1);

  Timer? retryTimer;
  int remainingSeconds = 60;
  String? lastSelectedMethod;

  late AuthBloc authBloc;

  @override
  void initState() {
    super.initState();
    authBloc = GetIt.I<AuthBloc>();

    if (authBloc.state.resetSendOtpStatus == ResetSendOtpStatus.failure ||
        authBloc.state.resetSendOtpStatus == ResetSendOtpStatus.success) {
      // ignore: invalid_use_of_visible_for_testing_member
      authBloc.emit(authBloc.state.copyWith(resetSendOtpStatus: ResetSendOtpStatus.init));
    }

    remainingSeconds = 60;
    retryTimer?.cancel();
    lastSelectedMethod = null;
  }

  @override
  void dispose() {
    retryTimer?.cancel();
    if (authBloc.state.resetSendOtpStatus == ResetSendOtpStatus.failure) {
      // ignore: invalid_use_of_visible_for_testing_member
      authBloc.emit(authBloc.state.copyWith(resetSendOtpStatus: ResetSendOtpStatus.init));
    }
    super.dispose();
  }

  void startRetryTimer() {
    remainingSeconds = 60;
    retryTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void sendOtp(String method) {
    lastSelectedMethod = method;
    // endpoint إعادة التعيين الخاص (idle-lock) — channel: whatsapp | sms.
    authBloc.add(
      ResetSendOtpEvent(
        phoneNumber: '+${widget.phoneNumber}',
        channel: method,
      ),
    );
  }

  Widget buildLoadingOrTimer(ResetSendOtpStatus status) {
    if (status == ResetSendOtpStatus.loading) {
      // التحميل يظهر كـ shimmer على الزرّ المضغوط نفسه.
      return SizedBox(height: 30.h);
    } else if (status == ResetSendOtpStatus.failure) {
      if (remainingSeconds > 0) {
        return SizedBox(
          height: 30.h,
          child: Center(
            child: MyTextWidget(
              '${LocaleKeys.you_must_wait_for_some_seconds_before_try_again.tr()} ${remainingSeconds}s',
              style: context.textTheme.titleMedium?.rq.copyWith(
                color: const Color(0xff5D5C5D),
                fontSize: 13.sp,
              ),
            ),
          ),
        );
      } else {
        return SizedBox(
          height: 30.h,
          child: Center(
            child: InkWell(
              onTap: () {
                if (lastSelectedMethod != null) {
                  sendOtp(lastSelectedMethod!);
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: const Color(0xff388cff),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: MyTextWidget(
                  LocaleKeys.resend_code.tr(),
                  style: context.textTheme.titleMedium?.rq.copyWith(
                    color: Colors.white,
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
    return SizedBox(height: 30.h);
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return BlocListener<AuthBloc, AuthState>(
      bloc: authBloc,
      listener: (context, state) {
        if (state.resetSendOtpStatus == ResetSendOtpStatus.success) {
          retryTimer?.cancel();
          remainingSeconds = 60;
          if (lastSelectedMethod == 'whatsapp') {
            widget.onChooseWhatsapp();
          } else if (lastSelectedMethod == 'sms') {
            widget.onChooseSms();
          }
        } else if (state.resetSendOtpStatus == ResetSendOtpStatus.failure) {
          if (retryTimer?.isActive != true) {
            startRetryTimer();
          }
        } else if (state.resetSendOtpStatus == ResetSendOtpStatus.init) {
          retryTimer?.cancel();
          remainingSeconds = 60;
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        bloc: authBloc,
        buildWhen: (previous, current) =>
            previous.resetSendOtpStatus != current.resetSendOtpStatus,
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
                      LocaleKeys.choose_verification_method.tr(),
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
                            LocaleKeys.we_will_send_code.tr(),
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
                        InkWell(
                          onTap: widget.goBackToPhone,
                          child: MyTextWidget(
                            LocaleKeys.edit.tr(),
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: context.textTheme.titleMedium?.mq.copyWith(
                              color: const Color(0xff388CFF),
                              height: 1.42,
                              decoration: TextDecoration.underline,
                              decorationColor: const Color(0xff388CFF),
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      ],
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
              SizedBox(height: 28.h),
              buildLoadingOrTimer(state.resetSendOtpStatus),
              SizedBox(height: 10.h),
              Padding(
                padding: HWEdgeInsets.symmetric(horizontal: 20.0),
                child: Builder(
                  builder: (context) {
                    final sending =
                        state.resetSendOtpStatus == ResetSendOtpStatus.loading;
                    final disabled =
                        sending ||
                        (state.resetSendOtpStatus ==
                                ResetSendOtpStatus.failure &&
                            remainingSeconds > 0);
                    // الزرّ المضغوط (clickButton.value) يصبح shimmer أثناء الإرسال.
                    Widget buildBtn(int idx, String label, String icon,
                        String method) {
                      if (sending && clickButton.value == idx) {
                        return SizedBox(
                          height: 70.h,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: ResetButtonShimmer(
                              height: 60.h,
                              radius: 20.r,
                            ),
                          ),
                        );
                      }
                      return _MethodButton(
                        label: label,
                        iconAsset: icon,
                        selectedIndex: idx,
                        clickButton: clickButton,
                        disabled: disabled,
                        onTap: () {
                          clickButton.value = idx;
                          Future.delayed(
                            const Duration(milliseconds: 100),
                            () => sendOtp(method),
                          );
                        },
                      );
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: buildBtn(
                            0,
                            LocaleKeys.whatsApp.tr(),
                            AppAssets.whatsappSvg,
                            'whatsapp',
                          ),
                        ),
                        10.horizontalSpace,
                        Expanded(
                          child: buildBtn(
                            1,
                            LocaleKeys.sms.tr(),
                            AppAssets.smsSvg,
                            'sms',
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              10.verticalSpace,
            ],
          );
        },
      ),
    );
  }
}

/// زرّ اختيار طريقة (واتساب/رسالة) بنفس شكل تسجيل الدخول.
class _MethodButton extends StatelessWidget {
  const _MethodButton({
    required this.label,
    required this.iconAsset,
    required this.selectedIndex,
    required this.clickButton,
    required this.disabled,
    required this.onTap,
  });

  final String label;
  final String iconAsset;
  final int selectedIndex;
  final ValueNotifier<int> clickButton;
  final bool disabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: disabled ? null : onTap,
      child: ValueListenableBuilder<int>(
        valueListenable: clickButton,
        builder: (context, index, _) {
          return SizedBox(
            height: 70.h,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Opacity(
                  opacity: disabled ? 0.5 : 1.0,
                  child: DottedBorder(
                    padding: const EdgeInsets.all(0.5),
                    borderType: BorderType.RRect,
                    strokeCap: StrokeCap.round,
                    strokeWidth: 0.5,
                    dashPattern: const [3, 3],
                    radius: Radius.circular(20.r),
                    color: index == selectedIndex
                        ? const Color(0xff388CFF)
                        : const Color(0xffC3C3C3),
                    child: Container(
                      height: 60.h,
                      decoration: BoxDecoration(
                        color: index == selectedIndex
                            ? const Color(0xffffffff)
                            : const Color(0xffFCFCFC),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MyTextWidget(
                            label,
                            style: context.textTheme.titleLarge?.rq.copyWith(
                              color: const Color(0xff1D1D1D),
                              height: 1.42,
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                PositionedDirectional(
                  top: 0,
                  start: 10.w,
                  child: SvgPicture.asset(
                    iconAsset,
                    width: 20.w,
                    height: 20.h,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
