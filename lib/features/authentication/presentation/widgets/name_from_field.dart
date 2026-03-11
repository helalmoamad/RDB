import 'dart:ui' as ui;
import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rdb/core/utils/extensions/build_context.dart';
import 'package:rdb/generated/locale_keys.g.dart';
import 'package:rdb/core/utils/last_pages_tracker.dart';
import 'package:rdb/theme/my_color_scheme.dart';
import 'package:rdb/theme/typography.dart';
import '../../../../core/utils/responsive_padding.dart';
import '../../../app/my_text_widget.dart';

// ignore: must_be_immutable
class NameFormField extends StatefulWidget {
  NameFormField({
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
    this.focusNode,
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
    this.ready = false,
    this.prefixIcon,
    this.icon,
    this.hintTextStyle,
    this.textStyle,
    this.suffixIcon,
    this.suffix,
    this.hintText,
    this.labelText,
    this.inputFormatters,
    this.autoFocus = true,
    this.contentPadding,
    this.filledColor,
    this.bordersColor,
  });

  final TextEditingController? controller;
  final void Function()? onTap;
  final void Function()? onEditingComplete;
  final void Function(String val)? onChange;
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
  final FocusNode? focusNode;
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
  final bool readOnly;
  final bool autocorrect;
  final String obscuringCharacter;
  final String? titleField;
  final bool showLength;
  final bool obscure;
  final bool autoFocus;
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

  @override
  State<NameFormField> createState() => _NameFormFieldState();
}

class _NameFormFieldState extends State<NameFormField> {
  final ValueNotifier<bool> showHint = ValueNotifier(true);

  @override
  void initState() {
    widget.controller!.addListener(() {
      showHint.value = widget.controller!.text.isEmpty;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: context.colorScheme.white,
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        SizedBox(
          height: 60,
          child: DottedBorder(
            padding: EdgeInsets.zero,
            borderType: BorderType.RRect,
            strokeCap: StrokeCap.round,
            strokeWidth: 0.5,
            dashPattern: const [3, 3],
            radius: const Radius.circular(20.0),
            color: widget.ready
                ? const Color(0xff388CFF)
                : const Color(0xff5D5C5D),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Directionality(
                textDirection: ui.TextDirection.ltr,
                child: TextFormField(
                  controller: widget.controller,
                  onTap: widget.onTap,
                  onChanged: widget.onChange,
                  onFieldSubmitted: widget.onFieldSubmitted,
                  onEditingComplete: widget.onEditingComplete,
                  onSaved: widget.onSaved,
                  validator: widget.validator,
                  maxLines: widget.maxLines,
                  minLines: widget.minLines,
                  maxLength: widget.maxLength,
                  enabled: widget.enabled,
                  keyboardType: TextInputType.name,
                  textInputAction: widget.textInputAction,
                  scrollPadding: widget.scrollPadding,
                  expands: widget.expands,
                  maxLengthEnforcement: widget.maxLengthEnforcement,
                  focusNode: !widget.autoFocus
                      ? (FocusNode()..requestFocus())
                      : FocusNode(),
                  obscureText: widget.obscure,
                  obscuringCharacter: widget.obscuringCharacter,
                  autovalidateMode: widget.autoValidateMode,
                  readOnly: widget.readOnly,
                  scrollPhysics: widget.scrollPhysics,
                  scrollController: widget.scrollController,
                  autocorrect: false,
                  autofocus: widget.autoFocus,
                  cursorColor: const Color(0xff5D5C5D),
                  initialValue: widget.initialValue,
                  keyboardAppearance: widget.keyboardAppearance,
                  textAlignVertical: TextAlignVertical.center,
                  textCapitalization: widget.textCapitalization,
                  cursorHeight: 0,
                  // ignore: deprecated_member_use
                  toolbarOptions: widget.toolbarOptions,
                  style: context.textTheme.displayMedium?.rq.copyWith(
                    color: const Color(0xff5D5C5D),
                    letterSpacing: 0.16,
                    height: 3,
                    decoration: TextDecoration.none,
                  ),
                  decoration: InputDecoration(
                    errorMaxLines: 1,
                    errorStyle: const TextStyle(fontSize: 11, height: 1),
                    errorBorder: OutlineInputBorder(
                      gapPadding: 2,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: HWEdgeInsets.only(left: 30, right: 30),
                    prefixIcon: widget.prefixIcon,
                    suffixIcon: Padding(
                      padding: HWEdgeInsets.only(bottom: 10),
                      child: widget.suffixIcon,
                    ),
                    counterText: '',
                  ),
                ),
              ),
            ),
          ),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: showHint,
          builder: (context, show, _) {
            return show
                ? MyTextWidget(
                    LocaleKeys.enter_your_name.tr(),
                    style: context.textTheme.displayMedium?.rq.copyWith(
                      color: const Color(0xffC4C2C2),
                    ),
                  )
                : const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
