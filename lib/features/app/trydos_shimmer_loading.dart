import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rdb/common/constant/design/assets_provider.dart';

class TrydosShimmerLoading extends StatefulWidget {
  const TrydosShimmerLoading({
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
  State<TrydosShimmerLoading> createState() => _TrydosShimmerLoadingState();
}

class _TrydosShimmerLoadingState extends State<TrydosShimmerLoading>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _opacityAnimation;
  bool _isDisposed = false;
  bool _useStaticMode = false;
  static int _shimmerCount = 0;

  @override
  void initState() {
    super.initState();
    _shimmerCount++;

    // 🔍 مراقبة بداية عرض الشيمر

    _determineRenderingMode();

    if (!_useStaticMode) {
      _initializeAnimation();
    }
  }

  void _determineRenderingMode() {
    // ✅ استخدام الوضع الثابت دائماً لتحسين الأداء (بدون حركة)
    _useStaticMode = true;
  }

  void _initializeAnimation() {
    if (_isDisposed) return;

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _useStaticMode ? 500 : 300),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.4,
      end: 0.6,
    ).animate(CurvedAnimation(parent: _controller!, curve: Curves.easeInOut));

    if (!_isDisposed) {
      _controller!.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _shimmerCount = (_shimmerCount > 0) ? _shimmerCount - 1 : 0;
    _controller?.dispose();

    // 🔍 مراقبة انتهاء عرض الشيمر

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        key: const ValueKey("shimmer"),
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: const Color(0xffE6E6E6),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
        child: _useStaticMode
            ? _buildStaticPlaceholder()
            : _buildAnimatedContent(),
      ),
    );
  }

  Widget _buildStaticPlaceholder() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Container(
                width: widget.circleDimensions ?? 18,
                height: widget.circleDimensions ?? 18,
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
          SizedBox(height: widget.height / 10),
          SvgPicture.asset(
            AppAssets.trydosTextSvg,
            width: widget.logoTextWidth,
            height: widget.logoTextHeight,
          ),
        ],
      ),
    );
  }

  Widget _buildStaticDot(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.black54,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildAnimatedContent() {
    if (_controller == null || _opacityAnimation == null) {
      return _buildStaticPlaceholder();
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSimplifiedLogo(),
          SizedBox(height: widget.height / 10),
          _buildCachedTextLogo(),
        ],
      ),
    );
  }

  Widget _buildSimplifiedLogo() {
    return AnimatedBuilder(
      animation: _opacityAnimation!,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation!.value,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: widget.circleDimensions ?? 18,
                height: widget.circleDimensions ?? 18,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF6B6B),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 2.5),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSimpleDot(3.0),
                  const SizedBox(width: 2),
                  _buildSimpleDot(4.0),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSimpleDot(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.black54,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildCachedTextLogo() {
    return SizedBox(
      width: widget.logoTextWidth,
      height: widget.logoTextHeight,
      child: SvgPicture.asset(
        AppAssets.trydosTextSvg,
        width: widget.logoTextWidth,
        height: widget.logoTextHeight,
        placeholderBuilder: (context) => Container(
          width: widget.logoTextWidth,
          height: widget.logoTextHeight,
          color: Colors.grey[300],
        ),
      ),
    );
  }
}
