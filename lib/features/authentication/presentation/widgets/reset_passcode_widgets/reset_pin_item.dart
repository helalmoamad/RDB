import 'dart:math';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rdb/common/constant/design/assets_provider.dart';
import 'package:rdb/core/utils/extensions/build_context.dart';
import 'package:rdb/core/utils/last_pages_tracker.dart';
import 'package:rdb/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:rdb/theme/typography.dart';

/// نسخة مستقلّة من خانة الـ OTP خاصّة بتدفّق إعادة تعيين رمز المرور.
/// تستخدم حالةً عامةً مستقلّة (بادئة reset*) حتى لا تتعارض مع خانات تسجيل الدخول
/// التي تشترك في focusNodes/otpInputLocked العامة.
List<FocusNode> resetFocusNodes = List.generate(
  6,
  (index) => FocusNode(debugLabel: 'reset_otp_$index'),
);
int resetCurrentToType = 0;
bool resetCheckingOtp = false;
bool resetOtpInputLocked = false;

/// البوابة الوحيدة لإظهار لوحة مفاتيح خانة الـ OTP في تدفّق إعادة التعيين.
void resetShowOtpKeyboard([int index = 0]) {
  if (resetOtpInputLocked) return;
  if (index < 0 || index > 5) return;
  final node = resetFocusNodes[index];
  if (node.context == null || !node.canRequestFocus) return;
  node.requestFocus();
}

/// قفل الخانات وإغلاق اللوحة قبل أي انتقال بعيداً عن صفحة الـ OTP.
void resetLockOtpKeyboard() {
  resetOtpInputLocked = true;
  resetCheckingOtp = false;
  for (final node in resetFocusNodes) {
    if (node.hasFocus) node.unfocus();
  }
  SystemChannels.textInput.invokeMethod('TextInput.hide');
  SystemChannels.textInput.invokeMethod('TextInput.clearClient');
}

/// فكّ القفل عند الدخول الفعلي لصفحة الـ OTP (لا يُظهر اللوحة بنفسه).
void resetUnlockOtpKeyboard() {
  resetOtpInputLocked = false;
}

/// إعادة ضبط حالة الخانات عند الدخول للشاشة دون طلب تركيز فوري.
void resetOtpFocusState() {
  resetCurrentToType = 0;
  resetCheckingOtp = false;
  resetOtpInputLocked = false;
  for (final node in resetFocusNodes) {
    if (node.hasFocus) {
      node.unfocus();
    }
  }
  SystemChannels.textInput.invokeMethod('TextInput.hide');
}

/// إظهار لوحة المفاتيح لخانة الـ OTP الأولى بعد استقرار الصفحة فعلياً.
void resetRequestOtpKeyboard() {
  resetCurrentToType = 0;
  resetCheckingOtp = false;
  resetOtpInputLocked = false;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    resetShowOtpKeyboard(0);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!resetOtpInputLocked && !resetFocusNodes[0].hasFocus) {
        resetShowOtpKeyboard(0);
      }
    });
  });
}

// ignore: must_be_immutable
class ResetPinItem extends StatefulWidget {
  final TextEditingController controller;
  bool isExpired;
  final bool autoFocus;
  bool wrongCode;
  final Color borderColor;
  final Color contentColor;
  final int index;
  final void Function()? checkOtp;
  final void Function() onChange;
  final void Function(String text)? pasteOtpCode;

  /// وضع رمز المرور: يُظهر نقطة (nBlock) بدل الرقم وألوان تعبئة مختلفة.
  final bool fromPasscose;

  /// نجاح التحقق: تعبئة خضراء (في وضع passcode).
  final bool verfySucessful;

  ResetPinItem({
    this.checkOtp,
    required this.contentColor,
    required this.isExpired,
    this.wrongCode = false,
    this.pasteOtpCode,
    required this.onChange,
    required this.borderColor,
    required this.index,
    required this.controller,
    required this.autoFocus,
    this.fromPasscose = false,
    this.verfySucessful = false,
    super.key,
  });

  @override
  State<ResetPinItem> createState() => _ResetPinItemState();
}

class _ResetPinItemState extends State<ResetPinItem>
    with TickerProviderStateMixin {
  bool withBorder = true;
  TextEditingValue zwspEditingValue = const TextEditingValue(
    text: '​',
    selection: TextSelection(baseOffset: 1, extentOffset: 1),
  );
  late final AnimationController animationController;
  late final AnimationController fadingController;

  @override
  void initState() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    fadingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    animationController.addStatusListener(_updateStatus);

    resetFocusNodes[widget.index].addListener(_handleFocusChange);

    if (widget.index == 0 && widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        resetShowOtpKeyboard(0);
        Future.delayed(const Duration(milliseconds: 350), () {
          if (mounted &&
              !resetOtpInputLocked &&
              !resetFocusNodes[0].hasFocus) {
            resetShowOtpKeyboard(0);
          }
        });
      });
    }
    widget.controller.value = zwspEditingValue;
    resetCurrentToType = 0;
    super.initState();
  }

  void _handleFocusChange() {
    if (resetOtpInputLocked) return;
    if (resetFocusNodes[widget.index].hasFocus) {
      if (widget.index != resetCurrentToType && !resetCheckingOtp) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted &&
              !resetOtpInputLocked &&
              resetFocusNodes[resetCurrentToType].context != null) {
            resetFocusNodes[resetCurrentToType].requestFocus();
          }
        });
      }
    }
  }

  @override
  void dispose() {
    resetFocusNodes[widget.index].removeListener(_handleFocusChange);
    animationController.dispose();
    fadingController.dispose();
    super.dispose();
  }

  void resetPins() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) resetShowOtpKeyboard(0);
    });
    resetCurrentToType = 0;
    resetCheckingOtp = false;
    withBorder = true;
    widget.controller.value = zwspEditingValue;
    widget.wrongCode = false;
    widget.isExpired = false;
    setState(() {});
  }

  void _updateStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      animationController.reset();
      resetPins();
    }
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    if (widget.wrongCode) {
      animationController.forward();
    }
    withBorder = widget.controller.text == '​';
    final hasValue = widget.controller.text != '​';
    return BlocConsumer<AuthBloc, AuthState>(
      buildWhen: (p, c) =>
          p.resetVerifyOtpStatus != c.resetVerifyOtpStatus,
      listener: (context, state) {
        if (state.resetVerifyOtpStatus == ResetVerifyOtpStatus.loading) {
          fadingController.repeat(reverse: true);
        } else {
          fadingController.reset();
        }
      },
      builder: (context, state) {
        final isVerifying =
            state.resetVerifyOtpStatus == ResetVerifyOtpStatus.loading ||
            state.resetVerifyOtpStatus == ResetVerifyOtpStatus.failure ||
            widget.isExpired;
        final isInputEnabled =
            state.resetVerifyOtpStatus != ResetVerifyOtpStatus.loading &&
            !resetOtpInputLocked &&
            !widget.isExpired;

        if (!isInputEnabled && resetFocusNodes[widget.index].hasFocus) {
          resetFocusNodes[widget.index].unfocus();
        }
        return AnimatedBuilder(
          animation: animationController,
          builder: (context, child) {
            final sineValue = sin(3 * 2 * pi * animationController.value);
            return Transform.translate(
              offset: Offset(sineValue * 5, 0),
              child: AnimatedBuilder(
                animation: fadingController,
                builder: (context, child) {
                  return SizedBox(
                    height: 58.h,
                    width: 58.w,
                    child: DottedBorder(
                      padding: EdgeInsets.zero,
                      borderType: BorderType.RRect,
                      borderPadding: EdgeInsets.zero,
                      strokeCap: StrokeCap.round,
                      strokeWidth: 1 - fadingController.value,
                      dashPattern: const [3, 3],
                      radius: Radius.circular(15.r),
                      color: widget.fromPasscose
                          ? withBorder
                                ? widget.borderColor
                                : const Color(0xffC3C3C3)
                          : hasValue || isVerifying
                          ? widget.borderColor
                          : !withBorder
                          ? widget.borderColor
                          : const Color(0xffC3C3C3),
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(18.r)),
                        child: SizedBox(
                          height: 65.h,
                          width: 60.w,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              TextFormField(
                                controller: widget.controller,
                                enabled: isInputEnabled,
                                focusNode: resetFocusNodes[widget.index],
                                onTap: () {
                                  if (!isInputEnabled || resetOtpInputLocked) {
                                    return;
                                  }
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    if (mounted) {
                                      resetShowOtpKeyboard(resetCurrentToType);
                                    }
                                  });
                                },
                                onChanged: (String? text) {
                                  if (!isInputEnabled) return;
                                  widget.onChange.call();
                                  if (widget.index == 0 &&
                                      (text?.length ?? 0) == 6) {
                                    widget.pasteOtpCode!.call(text!);
                                  }
                                  if ((text?.length ?? 0) > 1) {
                                    widget.controller.text = text![0];
                                    text = text[0];
                                  }
                                  setState(() {
                                    if ((text?.length ?? 0) == 1) {
                                      widget.onChange.call();
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                            if (mounted &&
                                                resetFocusNodes[min(
                                                          5,
                                                          widget.index + 1,
                                                        )]
                                                        .context !=
                                                    null) {
                                              resetFocusNodes[min(
                                                    5,
                                                    widget.index + 1,
                                                  )]
                                                  .requestFocus();
                                            }
                                          });
                                      resetCurrentToType = min(
                                        5,
                                        widget.index + 1,
                                      );
                                      withBorder = widget.index == 5;
                                      if (widget.index == 5) {
                                        resetCheckingOtp = true;
                                        widget.checkOtp!.call();
                                      }
                                    } else if (text?.isEmpty ?? true) {
                                      widget.onChange.call();
                                      resetCheckingOtp = false;
                                      widget.controller.value =
                                          zwspEditingValue;
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                            if (mounted &&
                                                resetFocusNodes[max(
                                                          0,
                                                          widget.index - 1,
                                                        )]
                                                        .context !=
                                                    null) {
                                              resetFocusNodes[max(
                                                    0,
                                                    widget.index - 1,
                                                  )]
                                                  .requestFocus();
                                            }
                                          });
                                      resetCurrentToType = max(
                                        0,
                                        widget.index - 1,
                                      );
                                      withBorder = true;
                                    }
                                  });
                                },
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                textDirection: TextDirection.ltr,
                                autocorrect: false,
                                cursorColor: const Color(0xff5D5C5D),
                                cursorHeight: 0,
                                enableInteractiveSelection: widget.index == 0,
                                cursorWidth: 0,
                                textAlignVertical: TextAlignVertical.center,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                style: context.textTheme.headlineSmall?.mq
                                    .copyWith(
                                      color: const Color(0xffFFFFFF),
                                      height: 0.6,
                                      fontSize: 0.sp,
                                      decoration: TextDecoration.none,
                                    ),
                                maxLines: 1,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  filled: true,
                                  fillColor: widget.fromPasscose
                                      ? widget.verfySucessful
                                            ? const Color(0xffE0FFEE)
                                            : withBorder
                                            ? const Color(0xffFFFFFF)
                                            : const Color(0xffFCFCFC)
                                      : !withBorder
                                      ? const Color(0xffFFFFFF)
                                      : const Color(0xffFCFCFC),
                                ),
                              ),
                              Positioned(
                                child: (widget.fromPasscose && hasValue)
                                    ? SvgPicture.asset(
                                        AppAssets.nBlock,
                                        width: 20.w,
                                      )
                                    : Text(
                                        widget.controller.value.text == '​'
                                            ? ""
                                            : widget.controller.value.text,
                                        style: context
                                            .textTheme
                                            .headlineSmall
                                            ?.mq
                                            .copyWith(
                                              color: const Color(0xff1D1D1D),
                                              height: 1.3,
                                              fontSize: 16.sp,
                                              decoration: TextDecoration.none,
                                            ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
