import 'dart:async';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rdb/core/utils/extensions/build_context.dart';
import 'package:rdb/theme/typography.dart';
import '../../../../common/constant/countries.dart';
import '../../../../core/utils/responsive_padding.dart';

double offset = 0;

// ignore: must_be_immutable
class PhoneFormField extends StatelessWidget {
  PhoneFormField({
    super.key,
    this.controller,
    this.onTap,
    this.onEditingComplete,
    this.onChange,
    this.onFieldSubmitted,
    this.onSaved,
    this.maxLines,
    this.minLines,
    this.maxLength,
    this.enabled,
    this.textInputType,
    this.textInputAction,
    this.textDirection,
    this.validator,
    this.maxLengthEnforcement,
    this.autoValidateMode,
    this.scrollPhysics,
    this.scrollController,
    this.initialValue,
    this.keyboardAppearance,
    this.textAlignVertical,
    this.toolbarOptions,
    this.obscuringCharacter = "•",
    this.expands = false,
    this.readOnly = false,
    this.autocorrect = true,
    this.showLength = false,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.textAlign = TextAlign.start,
    this.textCapitalization = TextCapitalization.none,
    this.titleField,
    this.obscure = false,
    this.prefixIcon,
    this.ready = false,
    this.icon,
    this.hintTextStyle,
    this.textStyle,
    this.suffixIcon,
    this.suffix,
    this.hintText,
    this.labelText,
    this.inputFormatters,
    this.autoFocus,
    this.contentPadding,
    this.filledColor,
    this.bordersColor,
    this.focusNode,
  });

  final TextEditingController? controller;
  final void Function()? onTap;
  final void Function()? onEditingComplete;
  final bool Function(String val)? onChange;
  final void Function(String val)? onFieldSubmitted;
  final void Function(String? val)? onSaved;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool? enabled;
  final TextInputType? textInputType;
  final TextInputAction? textInputAction;
  final TextDirection? textDirection;
  final FormFieldValidator<String?>? validator;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final AutovalidateMode? autoValidateMode;
  final ScrollPhysics? scrollPhysics;
  final ScrollController? scrollController;
  final String? initialValue;
  final Brightness? keyboardAppearance;
  final TextAlignVertical? textAlignVertical;
  // ignore: deprecated_member_use
  final ToolbarOptions? toolbarOptions;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;
  final EdgeInsets scrollPadding;
  final bool expands;
  final FocusNode? focusNode;
  final bool readOnly;
  final bool autocorrect;
  final String obscuringCharacter;
  final String? titleField;
  final bool showLength;
  final bool obscure;
  final bool? autoFocus;
  final Widget? prefixIcon;
  final Widget? icon;
  final Widget? suffixIcon;
  final Widget? suffix;
  final String? hintText;
  final TextStyle? hintTextStyle;
  final TextStyle? textStyle;
  final String? labelText;
  final List<TextInputFormatter>? inputFormatters;
  final EdgeInsetsGeometry? contentPadding;
  final Color? filledColor;
  final Color? bordersColor;
  bool ready = false;

  final ValueNotifier<bool> rebuildCursor = ValueNotifier(false);

  final ValueNotifier<bool> showCursor = ValueNotifier(true);

  late Timer timer;

  @override
  Widget build(BuildContext context) {
    timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      showCursor.value = !showCursor.value;
    });
    if (controller?.text.isEmpty ?? true) {
      offset = 0;
    }
    return SizedBox(
      height: 60.h,
      width: 1.sw,
      child: DottedBorder(
        padding: EdgeInsets.zero,
        borderType: BorderType.RRect,
        strokeCap: StrokeCap.round,
        strokeWidth: 0.5,
        dashPattern: const [3, 3],
        radius: Radius.circular(20.r),
        color: ready ? const Color(0xff388CFF) : const Color(0xff8D8D8D),
        child: SizedBox(
          height: 60.h,
          width: 1.sw,
          child: Stack(
            alignment: Alignment.bottomLeft,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: TextFormField(
                    controller: controller,
                    onTap: onTap,
                    onChanged: (String? text) {
                      if (text != null) {
                        onChange?.call(text) ?? false;
                        offset = (controller!.text.length * 12.sp);
                        rebuildCursor.value = !rebuildCursor.value;
                      }
                    },
                    onFieldSubmitted: onFieldSubmitted,
                    onEditingComplete: onEditingComplete,
                    onSaved: onSaved,
                    validator: validator,
                    maxLines: maxLines,
                    minLines: minLines,
                    maxLength: maxLength,
                    enabled: enabled,
                    keyboardType: TextInputType.phone,
                    textInputAction: textInputAction,
                    textDirection: TextDirection.ltr,

                    expands: expands,
                    maxLengthEnforcement: maxLengthEnforcement,
                    focusNode: focusNode,
                    obscureText: obscure,
                    obscuringCharacter: obscuringCharacter,
                    autovalidateMode: autoValidateMode,
                    readOnly: readOnly,
                    scrollPhysics: scrollPhysics,
                    scrollController: scrollController,
                    autocorrect: false,
                    autofocus: autoFocus ?? false,
                    cursorColor: const Color(0xff5D5C5D),
                    cursorHeight: 0,
                    cursorWidth: 0.w,
                    initialValue: initialValue,
                    keyboardAppearance: keyboardAppearance,
                    textAlignVertical: TextAlignVertical.top,

                    textCapitalization: textCapitalization,
                    // ignore: deprecated_member_use
                    toolbarOptions: toolbarOptions,
                    inputFormatters: [PhoneNumberFormatter()],
                    style: context.textTheme.headlineSmall?.mq.copyWith(
                      color: const Color(0xff1D1D1D),
                      height: 0.6.h,
                      decoration: TextDecoration.none,
                      fontSize: 16.sp,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,

                      prefix: prefixIcon,

                      suffixIcon: suffixIcon,
                      counterText: '',
                      hintText: hintText?.tr(),
                      hintStyle: context.textTheme.displayMedium?.rq.copyWith(
                        color: const Color(0xffC3C3C3),
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                ),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: showCursor,
                builder: (context, show, _) {
                  return show
                      ? ValueListenableBuilder<bool>(
                          valueListenable: rebuildCursor,
                          builder: (context, rebuild, _) {
                            return Container(
                              margin: HWEdgeInsets.only(
                                left: 120.w + offset,
                                bottom: 25.h,
                              ),
                              width: 10.w,
                              height: 1,
                              color: const Color(0xff5D5C5D),
                            );
                          },
                        )
                      : const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PhoneNumberFormatter extends TextInputFormatter {
  final validationRegex = RegExp(r'[ 0-9]');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String result = getFormattedText(oldValue.text, newValue.text);
    return newValue.copyWith(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }

  String getFormattedText(String oldText, String newText) {
    if (newText.length < oldText.length) {
      if (oldText[oldText.length - 1] == ' ') {
        return newText.substring(0, newText.length - 1);
      }
      return newText;
    }
    newText = newText.replaceAll(' ', '');
    oldText = oldText.replaceAll(' ', '');
    if (!validationRegex.hasMatch(newText)) {
      return oldText;
    }
    Country country = countries.firstWhere(
      (element) => '+${newText.toLowerCase()}'.startsWith(
        element.dialCode.toLowerCase(),
      ),
      orElse: () => countries.firstWhere(
        (element) => '+${oldText.toLowerCase()}'.startsWith(
          element.dialCode.toLowerCase(),
        ),
        orElse: () => const Country(
          name: '',
          flag: '',
          code: '',
          dialCode: '',
          minLength: 100,
          maxLength: 100,
        ),
      ),
    );
    String needEdit = newText;
    if (newText.length > (country.dialCode.length + country.maxLength + 1) &&
        country.name != '') {
      needEdit = oldText;
    }
    if ((oldText.length + 1) == country.dialCode.length &&
        newText[newText.length - 1] == '0') {
      needEdit = oldText;
    }
    if (country.name == '') return needEdit;
    String result = '${needEdit.substring(0, country.dialCode.length - 1)} ';
    for (int i = country.dialCode.length - 1; i < needEdit.length; i++) {
      result += needEdit[i];
      if ((i - country.dialCode.length + 2) % 3 == 0) {
        result += ' ';
      }
    }
    return result;
  }
}
