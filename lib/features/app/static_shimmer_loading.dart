import 'package:flutter/material.dart';

/// Shimmer ثابت محسن للأداء - بدون animation معقدة
class StaticShimmerLoading extends StatelessWidget {
  final double? width;
  final double? height;
  final bool showTrydosLogo;
  final Color baseColor;
  final Color highlightColor;

  const StaticShimmerLoading({
    super.key,
    this.width,
    this.height,
    this.showTrydosLogo = true,
    this.baseColor = const Color(0xFFF0F0F0),
    this.highlightColor = const Color(0xFFE0E0E0),
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: width ?? 200,
        height: height ?? 200,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: highlightColor),
        ),
        child: showTrydosLogo ? _buildTrydosContent() : null,
      ),
    );
  }

  /// محتوى trydos ثابت بدون animation
  Widget _buildTrydosContent() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // الخلفية الرمادية
        Container(
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        // محتوى trydos ثابت
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // الدائرة الحمراء ثابتة
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFFF6B6B), // أحمر trydos
                shape: BoxShape.circle,
              ),
              child: Stack(
                children: [
                  // النقاط السوداء الثابتة
                  Positioned(
                    left: 12,
                    top: 15,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 12,
                    top: 15,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // نص trydos ثابت
            _buildStaticTrydosText(),
          ],
        ),
      ],
    );
  }

  /// نص trydos ثابت
  Widget _buildStaticTrydosText() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'trydos',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF333333),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

/// Shimmer بسيط جداً للاستخدام العام
class SimpleStaticShimmer extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const SimpleStaticShimmer({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 100,
      height: height ?? 100,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 0.5),
      ),
    );
  }
}

/// Shimmer للنصوص
class TextStaticShimmer extends StatelessWidget {
  final double? width;
  final double height;
  final int lines;

  const TextStaticShimmer({
    super.key,
    this.width,
    this.height = 16,
    this.lines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        lines,
        (index) => Container(
          width: width ?? (index == lines - 1 ? 100 : 150),
          height: height,
          margin: EdgeInsets.only(bottom: lines > 1 ? 8 : 0),
          decoration: BoxDecoration(
            color: const Color(0xFFE8E8E8),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

/// Shimmer للبطاقات
class CardStaticShimmer extends StatelessWidget {
  final double? width;
  final double? height;

  const CardStaticShimmer({super.key, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 200,
      height: height ?? 280,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // صورة المنتج
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFEEEEEE),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: const Center(
                child: Icon(
                  Icons.image_outlined,
                  size: 40,
                  color: Color(0xFFCCCCCC),
                ),
              ),
            ),
          ),

          // معلومات المنتج
          const Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // اسم المنتج
                  TextStaticShimmer(height: 14, lines: 2),
                  SizedBox(height: 8),
                  // السعر
                  TextStaticShimmer(width: 80),
                  SizedBox(height: 4),
                  // تقييم
                  TextStaticShimmer(width: 60, height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
