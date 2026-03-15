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
        height: 40,
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xff388cff)),
          ),
        ),
      );
    } else if (status == SendOtpStatus.failure) {
      if (remainingSeconds > 0) {
        return SizedBox(
          height: 40,
          child: Center(
            child: MyTextWidget(
              '${LocaleKeys.you_must_wait_for_some_seconds_before_try_again.tr()} ${remainingSeconds}s',
              style: context.textTheme.titleMedium?.rq.copyWith(
                color: const Color(0xff5D5C5D),
              ),
            ),
          ),
        );
      } else {
        return SizedBox(
          height: 40,
          child: Center(
            child: InkWell(
              onTap: () {
                if (lastSelectedMethod != null) {
                  sendOtp(lastSelectedMethod!);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xff388cff),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: MyTextWidget(
                  LocaleKeys.resend_code.tr(),
                  style: context.textTheme.titleMedium?.rq.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
    // For init, success, or any other status, show empty space
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).unfocus();
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
        builder: (context, state) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: HWEdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  children: [
                    MyTextWidget(
                      widget.isFromLogin
                          ? LocaleKeys.sign_in_exclamation.tr()
                          : LocaleKeys.sign_up_exclamation.tr(),
                      textAlign: TextAlign.center,
                      style: context.textTheme.titleMedium?.bq.copyWith(
                        color: const Color(0xff1D1D1D),
                        height: 1.25,
                        fontSize: 20,
                      ),
                    ),
                    35.verticalSpace,
                    SvgPicture.asset(
                      AppAssets.phoneCallOutlinedSvg,
                      width: 25,
                      colorFilter: ColorFilter.mode(
                        Colors.grey,
                        BlendMode.srcIn,
                      ),
                    ),
                    35.verticalSpace,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                IgnorePointer(
                                  child: Icon(
                                    Icons.info_outline,
                                    color: Color.fromARGB(255, 179, 179, 179),
                                    size: 15,
                                  ),
                                ),
                                10.horizontalSpace,
                                MyTextWidget(
                                  LocaleKeys.we_will_send_code.tr(),
                                  style: context.textTheme.titleMedium?.rq
                                      .copyWith(
                                        color: const Color(0xff5D5C5D),
                                        height: 1.42,
                                      ),
                                ),
                              ],
                            ),
                            20.verticalSpace,
                            Row(
                              children: [
                                InkWell(
                                  onTap: widget.goBackToPhone,
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 4),
                                      SvgPicture.asset(
                                        AppAssets.editPenSvg,

                                        height: 15,
                                      ),
                                      const SizedBox(width: 10),
                                    ],
                                  ),
                                ),
                                5.horizontalSpace,
                                MyTextWidget(
                                  widget.phoneNumber,
                                  textAlign: TextAlign.center,
                                  style: context.textTheme.titleMedium?.bq
                                      .copyWith(
                                        color: const Color(0xff1D1D1D),
                                        height: 1.25,
                                        fontSize: 13,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100),
              buildLoadingOrTimer(state.sendOtpStatus),
              const SizedBox(height: 15),
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
                                    clickButton.value = -1;
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
                            return Opacity(
                              opacity: isDisabled ? 0.5 : 1.0,
                              child: DottedBorder(
                                padding: EdgeInsets.zero,
                                borderType: BorderType.RRect,
                                strokeCap: StrokeCap.round,

                                strokeWidth: 0.5,
                                dashPattern: const [3, 3],
                                radius: const Radius.circular(20.0),
                                color: const Color.fromARGB(255, 126, 126, 126),
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: index == 0
                                        ? const Color(0xffffffff)
                                        : const Color(0xffF5F5F5),
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        AppAssets.whatsappSvg,
                                        width: 20,
                                        height: 20,
                                      ),
                                      10.horizontalSpace,
                                      MyTextWidget(
                                        LocaleKeys.whatsApp.tr(),
                                        style: context.textTheme.titleLarge?.rq
                                            .copyWith(
                                              color: const Color(0xff5D5C5D),
                                              height: 1.42,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
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
                                    clickButton.value = -1;
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
                            return Opacity(
                              opacity: isDisabled ? 0.5 : 1.0,
                              child: DottedBorder(
                                padding: EdgeInsets.zero,
                                borderType: BorderType.RRect,
                                strokeCap: StrokeCap.round,
                                strokeWidth: 0.5,
                                dashPattern: const [3, 3],
                                radius: const Radius.circular(20.0),
                                color: const Color.fromARGB(255, 126, 126, 126),
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: index == 1
                                        ? const Color(0xffffffff)
                                        : const Color(0xffF5F5F5),
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IgnorePointer(
                                        child: Icon(
                                          Icons.messenger_outline,

                                          size: 20,
                                        ),
                                      ),
                                      10.horizontalSpace,
                                      MyTextWidget(
                                        LocaleKeys.sms.tr(),
                                        style: context.textTheme.titleLarge?.rq
                                            .copyWith(
                                              color: const Color(0xff5D5C5D),
                                              height: 1.42,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
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
