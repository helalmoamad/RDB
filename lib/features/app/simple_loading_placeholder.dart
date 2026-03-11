import 'package:flutter/material.dart';

/// ⚡ Loading placeholder بسيط ومحسن للسكرول السريع
/// يحل محل TrydosShimmerLoading الثقيل أثناء تحميل الصور
class SimpleLoadingPlaceholder extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final bool showIcon;

  // ignore: use_super_parameters
  const SimpleLoadingPlaceholder({
    Key? key,
    required this.width,
    required this.height,
    this.radius = 12,
    this.showIcon = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xffF5F5F5),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: showIcon
          ? const Center(
              child: Icon(
                Icons.image_outlined,
                color: Color(0xffE0E0E0),
                size: 20,
              ),
            )
          : null,
    );
  }
}

/// ⚡ Loading placeholder مع progress indicator للأجهزة القوية
class ProgressLoadingPlaceholder extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const ProgressLoadingPlaceholder({
    super.key,
    required this.width,
    required this.height,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xffF0F0F0),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: const Center(
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: Color(0xffff5f61),
          ),
        ),
      ),
    );
  }
}
