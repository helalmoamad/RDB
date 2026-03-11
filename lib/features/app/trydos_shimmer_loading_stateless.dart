import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rdb/common/constant/design/assets_provider.dart';

class TrydosShimmerLoadingStateless extends StatelessWidget {
  const TrydosShimmerLoadingStateless({
    super.key,
    required this.width,
    this.radius = 15,
    required this.logoTextWidth,
    required this.height,
    required this.logoTextHeight,
    this.circleDimensions,
  });

  final double width, logoTextWidth;
  final double height, logoTextHeight;
  final double? circleDimensions;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey("shimmer_stateless"),
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xffE6E6E6),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Container(
                  width: circleDimensions ?? 18,
                  height: circleDimensions ?? 18,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF6B6B),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 2.5),
                Transform.translate(
                  offset: const Offset(-2, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildStaticDot(3.0),
                      const SizedBox(width: 2),
                      _buildStaticDot(4.0),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: height / 10),
            SvgPicture.asset(
              AppAssets.trydosTextSvg,
              width: logoTextWidth,
              height: logoTextHeight,
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildStaticDot(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.black54,
        shape: BoxShape.circle,
      ),
    );
  }
}
