import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DefaultContainer extends StatelessWidget {
  const DefaultContainer({
    super.key,
    this.width,
    this.height,
    this.backColor,
    this.borderColor,
    this.childWidget,
    this.borderWidth,
    // this.backGroundImageUrl,
    this.radius,
    this.withoutRadius,
  });

  final double? width;
  final double? borderWidth;
  final double? height;
  final Color? backColor;
  final Color? borderColor;
  final Widget? childWidget;

  // final String? backGroundImageUrl;
  final bool? withoutRadius;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      // padding: EdgeInsets.all(0.0),
      decoration: BoxDecoration(
        color: backColor,
        borderRadius: BorderRadius.circular(
          withoutRadius != null ? 0.0 : radius ?? 2.0.sp,
        ),
        border: Border.all(
          width: borderWidth ?? 1.0,
          color: borderColor ?? Colors.black,
        ),
      ),
      child: childWidget,
    );
  }
}
