import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

/// عنصر shimmer بحجم الزرّ: يحلّ محلّ الزرّ المضغوط أثناء تنفيذ طلبه، فلا نعرض
/// shimmer لصفحة كاملة. عند نجاح الطلب ننتقل للصفحة التالية.
class ResetButtonShimmer extends StatelessWidget {
  const ResetButtonShimmer({
    this.width = double.infinity,
    required this.height,
    this.radius,
    super.key,
  });

  final double width;
  final double height;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius ?? 20.r),
        ),
      ),
    );
  }
}
