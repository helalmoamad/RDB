import 'dart:math';
import 'package:rdb/core/utils/last_pages_tracker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rdb/core/utils/extensions/build_context.dart';
import 'package:rdb/theme/typography.dart';
import 'package:rdb/common/constant/design/assets_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../manager/auth_bloc.dart';

List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());
int currentToType = 0;
bool checkingOtp = false;

void resetPinGlobalState() {
  currentToType = 0;
  checkingOtp = false;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (focusNodes[0].context != null) {
      focusNodes[0].requestFocus();
    }
  });
}

// ignore: must_be_immutable
class PinItem extends StatefulWidget {
  final TextEditingController controller;
  bool isExpired;
  final bool autoFocus;
  bool fromPasscose;
  bool verfySucessful;
  bool wrongCode;
  final Color borderColor;
  final Color contentColor;
  final int index;
  final void Function()? checkOtp;
  final void Function() onChange;
  final void Function(String text)? pasteOtpCode;

  PinItem({
    this.checkOtp,
    this.fromPasscose = false,
    this.verfySucessful = false,
    required this.contentColor,
    required this.isExpired,
    this.wrongCode = false,
    this.pasteOtpCode,
    required this.onChange,
    required this.borderColor,
    required this.index,
    required this.controller,
    required this.autoFocus,
    super.key,
  });

  @override
  State<PinItem> createState() => _PinItemState();
}

class _PinItemState extends State<PinItem> with TickerProviderStateMixin {
  bool withBorder = true;
  TextEditingValue zwspEditingValue = const TextEditingValue(
    text: '\u200b',
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

    // إضافة مستمع لتغيير التركيز لضمان أن التركيز دائماً في المربع الصحيح
    focusNodes[widget.index].addListener(_handleFocusChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && focusNodes[0].context != null) {
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted && focusNodes[0].context != null) {
            focusNodes[0].requestFocus();
          }
        });
      }
    });
    widget.controller.value = zwspEditingValue;
    currentToType = 0;
    super.initState();
  }

  void _handleFocusChange() {
    if (focusNodes[widget.index].hasFocus) {
      // إذا حصل هذا المربع على التركيز ولكنه ليس المربع الذي يجب الكتابة فيه حالياً
      if (widget.index != currentToType && !checkingOtp) {
        // إعادة توجيه التركيز للمربع الصحيح
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && focusNodes[currentToType].context != null) {
            focusNodes[currentToType].requestFocus();
          }
        });
      }
    }
  }

  @override
  void dispose() {
    focusNodes[widget.index].removeListener(_handleFocusChange);
    animationController.dispose();
    fadingController.dispose();
    super.dispose();
  }

  void resetPins() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && focusNodes[0].context != null) {
        focusNodes[0].requestFocus();
      }
    });
    currentToType = 0;
    checkingOtp = false;
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
    withBorder = widget.controller.text == '\u200b';
    final hasValue = widget.controller.text != '\u200b';
    return BlocConsumer<AuthBloc, AuthState>(
      buildWhen: (p, c) =>
          p.verifyOtpSignInStatus != c.verifyOtpSignInStatus ||
          p.verifyOtpFromGuestStatus != c.verifyOtpFromGuestStatus ||
          p.verifyPasscodeStatus != c.verifyPasscodeStatus,
      listener: (context, state) {
        if (state.verifyOtpSignInStatus == VerifyOtpSignInStatus.loading ||
            state.verifyOtpFromGuestStatus ==
                VerifyOtpFromGuestStatus.loading ||
            state.verifyPasscodeStatus == VerifyPasscodeStatus.loading) {
          fadingController.repeat(reverse: true);
        } else {
          fadingController.reset();
        }
      },
      builder: (context, state) {
        final isVerifying =
            state.verifyOtpSignInStatus == VerifyOtpSignInStatus.loading ||
            state.verifyOtpFromGuestStatus ==
                VerifyOtpFromGuestStatus.loading ||
            state.verifyPasscodeStatus == VerifyPasscodeStatus.loading ||
            state.verifyOtpSignInStatus == VerifyOtpSignInStatus.failure ||
            state.verifyOtpFromGuestStatus ==
                VerifyOtpFromGuestStatus.failure ||
            state.verifyPasscodeStatus == VerifyPasscodeStatus.failure ||
            widget.isExpired;
        final isInputEnabled =
            state.verifyOtpSignInStatus != VerifyOtpSignInStatus.loading &&
            state.verifyOtpFromGuestStatus !=
                VerifyOtpFromGuestStatus.loading &&
            state.verifyPasscodeStatus != VerifyPasscodeStatus.loading &&
            !widget.isExpired;

        if (!isInputEnabled && focusNodes[widget.index].hasFocus) {
          focusNodes[widget.index].unfocus();
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
                                focusNode: focusNodes[widget.index],
                                onTap: () {
                                  if (!isInputEnabled) return;
                                  if (widget.index != currentToType) {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                          if (mounted &&
                                              focusNodes[currentToType]
                                                      .context !=
                                                  null) {
                                            focusNodes[currentToType]
                                                .requestFocus();
                                          }
                                        });
                                  }
                                },
                                onChanged: (String? text) {
                                  if (!isInputEnabled) return;
                                  debugPrint(widget.index.toString());
                                  debugPrint(text);
                                  debugPrint(widget.index.toString());
                                  debugPrint(text?.length.toString());
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
                                                focusNodes[min(
                                                          5,
                                                          widget.index + 1,
                                                        )]
                                                        .context !=
                                                    null) {
                                              focusNodes[min(
                                                    5,
                                                    widget.index + 1,
                                                  )]
                                                  .requestFocus();
                                            }
                                          });
                                      currentToType = min(5, widget.index + 1);
                                      withBorder = widget.index == 5;
                                      if (widget.index == 5) {
                                        checkingOtp = true;
                                        widget.checkOtp!.call();
                                      }
                                    } else if (text?.isEmpty ?? true) {
                                      widget.onChange.call();
                                      checkingOtp = false;
                                      widget.controller.value =
                                          zwspEditingValue;
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                            if (mounted &&
                                                focusNodes[max(
                                                          0,
                                                          widget.index - 1,
                                                        )]
                                                        .context !=
                                                    null) {
                                              focusNodes[max(
                                                    0,
                                                    widget.index - 1,
                                                  )]
                                                  .requestFocus();
                                            }
                                          });
                                      currentToType = max(0, widget.index - 1);
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
                                        widget.controller.value.text == '\u200b'
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
