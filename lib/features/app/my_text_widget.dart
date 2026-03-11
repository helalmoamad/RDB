import 'package:flutter/material.dart';

class MyTextWidget extends StatelessWidget {
  const MyTextWidget(this.text,
      {this.style,
      this.textScaleFactor,
      this.maxLines,
      this.textDirection,
      this.textAlign,
      this.overflow,
      super.key});

  final String text;
  final TextStyle? style;
  final double? textScaleFactor;
  final int? maxLines;
  final TextDirection? textDirection;
  final TextAlign? textAlign;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return Text(
      key: ValueKey(text),
      text,
      style: style,
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: overflow,
      textDirection: textDirection,
      // ignore: deprecated_member_use
      textScaleFactor: textScaleFactor ?? 1.0,
    );
  }
}
