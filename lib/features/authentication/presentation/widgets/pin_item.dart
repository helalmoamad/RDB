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

/// المرجع الوحيد لحالة لوحة مفاتيح الـ OTP.
///
/// عندما يكون `true` تُعتبر صفحة الـ OTP "مغادَرة" (نجاح، رقم غير مسجّل، أو
/// رقم مسجّل مسبقاً)، فيُهمَل أي طلب إظهار للوحة وتُرفض كل عمليات `requestFocus`.
/// هذا هو ما يضمن عدم ظهور أي ومضة على الصفحات الثلاث التالية. يُعاد ضبطه إلى
/// `false` فقط عند الدخول الفعلي لصفحة الـ OTP عبر [unlockOtpKeyboard].
bool otpInputLocked = false;

/// البوابة **الوحيدة** لإظهار لوحة مفاتيح الـ OTP. كل المسارات (الفتح التلقائي،
/// الانتقال بين الخانات، النقر، المحاولات المؤجّلة) يجب أن تمر من هنا.
///
/// تُهمَل فوراً إن كانت الخانات مقفلة — وهذا ما يُلغي مفعول المحاولات المؤجّلة
/// (300/350ms) إذا غادر المستخدم الصفحة قبل إطلاقها، فلا تُفتح اللوحة على صفحة
/// أخرى ثم تُغلق (الومضة).
void showOtpKeyboard([int index = 0]) {
  if (otpInputLocked) return;
  if (index < 0 || index > 5) return;
  final node = focusNodes[index];
  if (node.context == null || !node.canRequestFocus) return;
  // نكتفي بـ requestFocus دون TextInput.show اليدوي: الإطار يُظهر اللوحة
  // تلقائياً فقط إذا كان الحقل في المسار النشط (top route). الاستدعاء اليدوي
  // كان يفرض اللوحة حتى لحقلٍ في مسار مُعلّق (خانة الـ OTP أسفل صفحة النجاح)
  // فتومض. اعتماد requestFocus وحده يضمن ظهورها على صفحة الـ OTP/الـ passcode
  // النشطة فقط، وعدم ظهورها على صفحات النجاح/الخطأ.
  node.requestFocus();
}

/// قفل خانات الـ OTP وإغلاق اللوحة نهائياً قبل أي انتقال بعيداً عن صفحتها.
///
/// يُستدعى من `verify_otp` لحظة اتخاذ قرار الانتقال (نجاح أو فشل "رقم غير
/// مسجّل")، فيمنع أي إظهار لاحق للوحة ويفصل عميل الإدخال على مستوى المحرّك.
void lockOtpKeyboard() {
  otpInputLocked = true;
  checkingOtp = false;
  for (final node in focusNodes) {
    if (node.hasFocus) node.unfocus();
  }
  SystemChannels.textInput.invokeMethod('TextInput.hide');
  // فصل عميل الإدخال على مستوى المحرّك حتى لا يعيد النظام إظهار اللوحة تلقائياً.
  SystemChannels.textInput.invokeMethod('TextInput.clearClient');
}

/// فكّ القفل عند الدخول الفعلي لصفحة الـ OTP (لا يُظهر اللوحة بنفسه).
void unlockOtpKeyboard() {
  otpInputLocked = false;
}

void resetPinGlobalState() {
  currentToType = 0;
  checkingOtp = false;
  otpInputLocked = false;
  WidgetsBinding.instance.addPostFrameCallback((_) => showOtpKeyboard(0));
}

/// إعادة ضبط حالة خانات الـ OTP عند الدخول للشاشة دون طلب تركيز فوري.
///
/// تُزيل أي تركيز عالق من شاشة سابقة وتعيد العدّادات للصفر، وتفكّ القفل حتى
/// تعمل اللوحة من جديد على صفحة الـ OTP.
void resetOtpFocusState() {
  currentToType = 0;
  checkingOtp = false;
  otpInputLocked = false;
  for (final node in focusNodes) {
    if (node.hasFocus) {
      node.unfocus();
    }
  }
  // إخفاء اللوحة فوراً؛ ستُرفع لاحقاً عند استقرار صفحة الـ OTP.
  SystemChannels.textInput.invokeMethod('TextInput.hide');
}

/// إظهار لوحة المفاتيح لخانة الـ OTP الأولى بعد استقرار الصفحة فعلياً.
///
/// تُستدعى من الصفحة الأب عبر `onPageChanged` عند وصول الـ PageView لصفحة
/// الـ OTP — وهو التوقيت الموثوق، بخلاف `initState` الذي يعمل أثناء الأنيميشن
/// (والصفحة شبه خارج الشاشة) فيُهمَل طلب اللوحة ويظهر لاحقاً في صفحة أخرى.
void requestOtpKeyboard() {
  currentToType = 0;
  checkingOtp = false;
  // الوصول لصفحة الـ OTP يعني فكّ القفل وإتاحة اللوحة من جديد.
  otpInputLocked = false;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    showOtpKeyboard(0);
    // محاولة احتياطية في حال لم يكن اتصال الإدخال جاهزاً عند أول إطار.
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!otpInputLocked && !focusNodes[0].hasFocus) {
        showOtpKeyboard(0);
      }
    });
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

    if (widget.index == 0 && widget.autoFocus) {
      // الإظهار يمر عبر البوابة الوحيدة showOtpKeyboard التي تحترم القفل،
      // فلا تُفتح اللوحة إن غادر المستخدم الصفحة قبل إطلاق المحاولة المؤجّلة.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showOtpKeyboard(0);
        Future.delayed(const Duration(milliseconds: 350), () {
          if (mounted && !otpInputLocked && !focusNodes[0].hasFocus) {
            showOtpKeyboard(0);
          }
        });
      });
    }
    widget.controller.value = zwspEditingValue;
    currentToType = 0;
    super.initState();
  }

  void _handleFocusChange() {
    // إذا كانت الخانات مقفلة (نغادر الصفحة) فلا نعيد توجيه أي تركيز.
    if (otpInputLocked) return;
    if (focusNodes[widget.index].hasFocus) {
      // إذا حصل هذا المربع على التركيز ولكنه ليس المربع الذي يجب الكتابة فيه حالياً
      if (widget.index != currentToType && !checkingOtp) {
        // إعادة توجيه التركيز للمربع الصحيح
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !otpInputLocked && focusNodes[currentToType].context != null) {
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
      if (mounted) showOtpKeyboard(0);
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
        // ملاحظة: لا نُعطّل الحقل عند success. إغلاق لوحة الـ OTP عند النجاح
        // يتكفّل به lockOtpKeyboard() (عبر القفل). تعطيله بـ success كان يُبقي
        // خانة الـ OTP الحيّة أسفل الصفحات التالية تضبط canRequestFocus=false
        // على focusNodes المشتركة، فيمنع لوحة صفحة الـ passcode.
        final isInputEnabled =
            state.verifyOtpSignInStatus != VerifyOtpSignInStatus.loading &&
            state.verifyOtpFromGuestStatus !=
                VerifyOtpFromGuestStatus.loading &&
            state.verifyPasscodeStatus != VerifyPasscodeStatus.loading &&
            !otpInputLocked &&
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
                                  if (!isInputEnabled || otpInputLocked) return;
                                  // الإظهار وإعادة التوجيه عبر البوابة الوحيدة.
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    if (mounted) showOtpKeyboard(currentToType);
                                  });
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
                                // الرقم المُدخَل يُرسَم في Positioned أدناه، لذا
                                // نُخفي نص الحقل نفسه. لا تستخدم fontSize: 0 —
                                // EditableText يشتق StrutStyle.fromTextStyle من
                                // هذا النمط، و StrutStyle يؤكّد fontSize > 0.
                                style: context.textTheme.headlineSmall?.mq
                                    .copyWith(
                                      color: Colors.transparent,

                                      height: 0.6,
                                      fontSize: 1,
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
