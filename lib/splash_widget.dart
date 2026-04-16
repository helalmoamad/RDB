import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart' as tran;
import 'package:rdb/common/constant/design/assets_provider.dart';
import 'package:rdb/core/utils/extensions/build_context.dart';
import 'package:rdb/generated/locale_keys.g.dart';
import 'package:rdb/theme/typography.dart';

/// Wallet splash screen. Preloads home page data during 5 seconds.
class SplashWidget extends StatefulWidget {
  const SplashWidget({super.key});

  @override
  State<SplashWidget> createState() => _SplashWidgetState();
}

class _SplashWidgetState extends State<SplashWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 5500),
        )..addListener(() {
          setState(() {});
        });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _controller.forward().then((_) {
            if (mounted) {
              setState(() => _showSplash = false);
            }
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedOpacity(
          opacity: _showSplash ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          onEnd: () {},
          child: IgnorePointer(
            ignoring: !_showSplash,
            child: _SplashOverlay(progress: _controller.value),
          ),
        ),
      ],
    );
  }
}

class _SplashOverlay extends StatelessWidget {
  final double progress;

  const _SplashOverlay({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(flex: 5),

            // Logo section
            SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(AppAssets.rdb, height: 72.h),
                  SizedBox(height: 20.h),
                  SvgPicture.asset(
                    AppAssets.rammazDigitalBanking,
                    height: 13.h,
                  ),
                ],
              ),
            ),

            const Spacer(flex: 4),

            // Progress bar and Safe text
            SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Custom progress bar
                  Container(
                    width: 146.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.r),
                      border: Border.all(color: const Color(0xFF707070)),
                    ),

                    child: Stack(
                      children: [
                        Container(
                          width: (177.w) * progress,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3066CC),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      _getWord(progress),
                      key: ValueKey<String>(_getWord(progress)),
                      textAlign: TextAlign.center,
                      style: context.textTheme.headlineMedium?.rq.copyWith(
                        fontSize: 13.sp,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(flex: 2),

            // Powered By section
            Directionality(
              textDirection: TextDirection.ltr,
              child: Padding(
                padding: EdgeInsets.only(bottom: 40.h),
                child: Center(
                  child: IntrinsicWidth(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Powered By",
                          style: TextStyle(
                            fontSize: 8.sp,
                            color: const Color(0xff404040),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            SvgPicture.asset(AppAssets.rammaz, height: 10.h),
                            Positioned(
                              top: -5.h,
                              left: 44.w,
                              child: SvgPicture.asset(AppAssets.bracket),
                            ),
                            Positioned(
                              top: -5.h,
                              right: -5.w,
                              child: SvgPicture.asset(
                                AppAssets.rLetter,
                                height: 7.h,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getWord(double progress) {
    if (progress < 0.30) return '${LocaleKeys.safe.tr()}...';
    if (progress < 0.55) return '${LocaleKeys.easy.tr()}...';
    if (progress < 0.80) return '${LocaleKeys.transaction.tr()}...';
    return '${LocaleKeys.payment.tr()}...';
  }
}
