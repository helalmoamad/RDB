import 'dart:async';
import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:rdb/common/test_utils/test_var.dart';
import 'package:rdb/core/utils/extensions/build_context.dart';
import 'package:rdb/features/app/rdb_loading.dart';
import 'package:rdb/generated/locale_keys.g.dart';
import 'package:rdb/theme/typography.dart';

import '../../../../common/constant/design/assets_provider.dart';
import '../../../../common/test_utils/widgets_keys.dart';
import '../../../../core/utils/responsive_padding.dart';
import '../../../app/my_text_widget.dart';
import '../manager/auth_bloc.dart';
import 'package:rdb/core/utils/last_pages_tracker.dart';

class VerificationMethods extends StatefulWidget {
  const VerificationMethods({
    super.key,
    required this.phoneNumber,
    required this.goBackToPhone,
    required this.onChooseWhatsapp,
    required this.onChooseSms,
    required this.isFromLogin,
  });
  final String phoneNumber;
  final void Function() onChooseWhatsapp;
  final void Function() onChooseSms;
  final void Function() goBackToPhone;
  final bool isFromLogin;

  @override
  State<VerificationMethods> createState() => _VerificationMethodsState();
}

class _VerificationMethodsState extends State<VerificationMethods> {
  final ValueNotifier<int> clickButton = ValueNotifier(-1);

  Timer? retryTimer;
  int remainingSeconds = 60;
  String? lastSelectedMethod;

  late AuthBloc authBloc;

  @override
  void initState() {
    super.initState();
    authBloc = GetIt.I<AuthBloc>();

    // Reset the SendOTP status when initializing the page
    // This ensures clean state when returning to this page
    if (authBloc.state.sendOtpStatus == SendOtpStatus.failure ||
        authBloc.state.sendOtpStatus == SendOtpStatus.success) {
      // Reset to initial state
      // ignore: invalid_use_of_visible_for_testing_member
      authBloc.emit(authBloc.state.copyWith(sendOtpStatus: SendOtpStatus.init));
    }

    // Reset local timer state
    remainingSeconds = 60;
    retryTimer?.cancel();
    lastSelectedMethod = null;
  }

  @override
  void didChangeDependencies() async {
    // Additional safety check when dependencies change (like when returning to page)
    // Reset timer state if it's still running from previous session
    if (remainingSeconds < 60 && remainingSeconds > 0) {
      remainingSeconds = 60;
      retryTimer?.cancel();
    }

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // Cancel timer to prevent memory leaks
    retryTimer?.cancel();

    // Optionally reset the SendOTP status when leaving the page
    // This ensures clean state for next time
    if (authBloc.state.sendOtpStatus == SendOtpStatus.failure) {
      // ignore: invalid_use_of_visible_for_testing_member
      authBloc.emit(authBloc.state.copyWith(sendOtpStatus: SendOtpStatus.init));
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
    int isViaWhatsApp = method == 'whatsapp' ? 1 : 0;

    authBloc.add(
      SendOtpEvent(
        phone: widget.phoneNumber,
        isResend: false,
        isSignUp: !widget.isFromLogin,
        isViaWhatsApp: isViaWhatsApp,
      ),
    );
  }

  Widget buildLoadingOrTimer(SendOtpStatus status) {
    if (status == SendOtpStatus.loading) {
      return SizedBox(
        height: 30.h,
        child: Center(child: RDBLoader(size: 16.h)),
      );
    } else if (status == SendOtpStatus.failure) {
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
    // For init, success, or any other status, show empty space
    return SizedBox(height: 30.h);
  }

  @override
  Widget build(BuildContext context) {
    // ملاحظة: لا نستدعي FocusScope.unfocus() هنا. صفحة الطرق تبقى حيّة داخل
    // الـ PageView وتتشارك FocusScope مع صفحة الـ OTP، فاستدعاء unfocus في
    // build كان يُلغي تركيز خانة الـ OTP عند كل إعادة بناء فتومض اللوحة.
    // إغلاق اللوحة عند الوصول لهذه الصفحة يتم مرة واحدة عبر onPageChanged.
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return BlocListener<AuthBloc, AuthState>(
      bloc: authBloc,
      listener: (context, state) {
        if (state.sendOtpStatus == SendOtpStatus.success) {
          // Cancel any running timer before navigation
          retryTimer?.cancel();
          remainingSeconds = 60;

          // Navigate based on the selected method
          if (lastSelectedMethod == 'whatsapp') {
            widget.onChooseWhatsapp();
          } else if (lastSelectedMethod == 'sms') {
            widget.onChooseSms();
          }
        } else if (state.sendOtpStatus == SendOtpStatus.failure) {
          // Only start timer if it's not already running
          if (retryTimer?.isActive != true) {
            startRetryTimer();
          }
        } else if (state.sendOtpStatus == SendOtpStatus.init) {
          // Reset timer when status is reset to init
          retryTimer?.cancel();
          remainingSeconds = 60;
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        bloc: authBloc,
        buildWhen: (previous, current) =>
            previous.sendOtpStatus != current.sendOtpStatus,
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
                      widget.isFromLogin
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
              buildLoadingOrTimer(state.sendOtpStatus),
              SizedBox(height: 10.h),
              Padding(
                padding: HWEdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        key: TestVariables.kTestMode
                            ? const Key(WidgetsKeys.chooseWhatsappButtonKey)
                            : null,
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap:
                            (state.sendOtpStatus == SendOtpStatus.loading ||
                                (state.sendOtpStatus == SendOtpStatus.failure &&
                                    remainingSeconds > 0))
                            ? null
                            : () {
                                clickButton.value = 0;
                                Future.delayed(
                                  const Duration(milliseconds: 100),
                                  () {
                                    sendOtp('whatsapp');
                                  },
                                );
                                ////////////////
                              },
                        child: ValueListenableBuilder<int>(
                          valueListenable: clickButton,
                          builder: (context, index, _) {
                            bool isDisabled =
                                state.sendOtpStatus == SendOtpStatus.loading ||
                                (state.sendOtpStatus == SendOtpStatus.failure &&
                                    remainingSeconds > 0);
                            return SizedBox(
                              height: 70.h,
                              child: Stack(
                                alignment: AlignmentGeometry.bottomCenter,
                                children: [
                                  Opacity(
                                    opacity: isDisabled ? 0.5 : 1.0,
                                    child: DottedBorder(
                                      padding: EdgeInsets.all(0.5),
                                      borderType: BorderType.RRect,
                                      strokeCap: StrokeCap.round,

                                      strokeWidth: 0.5,
                                      dashPattern: const [3, 3],
                                      radius: Radius.circular(20.r),
                                      color: index == 0
                                          ? Color(0xff388CFF)
                                          : Color(0xffC3C3C3),
                                      child: Container(
                                        height: 60.h,
                                        decoration: BoxDecoration(
                                          color: index == 0
                                              ? const Color(0xffffffff)
                                              : const Color(0xffFCFCFC),
                                          borderRadius: BorderRadius.circular(
                                            20.r,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            MyTextWidget(
                                              LocaleKeys.whatsApp.tr(),
                                              style: context
                                                  .textTheme
                                                  .titleLarge
                                                  ?.rq
                                                  .copyWith(
                                                    color: const Color(
                                                      0xff1D1D1D,
                                                    ),
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
                                      AppAssets.whatsappSvg,
                                      width: 20.w,
                                      height: 20.h,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    10.horizontalSpace,
                    Expanded(
                      child: InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap:
                            (state.sendOtpStatus == SendOtpStatus.loading ||
                                (state.sendOtpStatus == SendOtpStatus.failure &&
                                    remainingSeconds > 0))
                            ? null
                            : () {
                                clickButton.value = 1;
                                Future.delayed(
                                  const Duration(milliseconds: 100),
                                  () {
                                    sendOtp('sms');
                                  },
                                );
                                ///////////////////
                              },
                        child: ValueListenableBuilder<int>(
                          valueListenable: clickButton,
                          builder: (context, index, _) {
                            bool isDisabled =
                                state.sendOtpStatus == SendOtpStatus.loading ||
                                (state.sendOtpStatus == SendOtpStatus.failure &&
                                    remainingSeconds > 0);
                            return SizedBox(
                              height: 70.h,
                              child: Stack(
                                alignment: AlignmentGeometry.bottomCenter,

                                children: [
                                  Opacity(
                                    opacity: isDisabled ? 0.5 : 1.0,
                                    child: DottedBorder(
                                      padding: EdgeInsets.all(0.5),
                                      borderType: BorderType.RRect,
                                      strokeCap: StrokeCap.round,

                                      strokeWidth: 0.5,
                                      dashPattern: const [3, 3],
                                      radius: Radius.circular(20.r),
                                      color: index == 1
                                          ? Color(0xff388CFF)
                                          : Color(0xffC3C3C3),
                                      child: Container(
                                        height: 60.h,
                                        decoration: BoxDecoration(
                                          color: index == 1
                                              ? const Color(0xffffffff)
                                              : const Color(0xffFCFCFC),
                                          borderRadius: BorderRadius.circular(
                                            20.r,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            MyTextWidget(
                                              LocaleKeys.sms.tr(),
                                              style: context
                                                  .textTheme
                                                  .titleLarge
                                                  ?.rq
                                                  .copyWith(
                                                    color: const Color(
                                                      0xff1D1D1D,
                                                    ),
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
                                      AppAssets.smsSvg,
                                      width: 20.w,
                                      height: 20.h,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
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
