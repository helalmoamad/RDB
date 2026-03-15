import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rdb/core/utils/extensions/build_context.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../../common/test_utils/test_var.dart';
import '../../../../common/test_utils/widgets_keys.dart';
import 'edited_spinkit_three_bounce.dart';

class RDBLoader extends StatelessWidget {
  RDBLoader({super.key, double? size, Color? color})
    : _widget = _TripperLoaderCircle(
        size: size,
        color: color,
        key: TestVariables.kTestMode
            ? const Key(WidgetsKeys.loadingAfterSearchKey)
            : null,
      );

  RDBLoader.spinKitThreeBounce({super.key, double? size, Color? color})
    : _widget = _TripperLoaderThreeBounce(size: size, color: color, key: key);

  RDBLoader.spinKitThreeBounceEditing({super.key, double? size, Color? color})
    : _widget = _TripperLoaderThreeBounceEditing(
        size: size,
        color: color,
        key: key,
      );

  final Widget _widget;

  @override
  Widget build(BuildContext context) {
    return _widget;
  }
}

class _TripperLoaderCircle extends StatelessWidget {
  const _TripperLoaderCircle({super.key, this.size, this.color});

  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SpinKitFadingCircle(
      color: color ?? context.theme.colorScheme.primary,
      size: size ?? 40.r,
    );
  }
}

class _TripperLoaderThreeBounce extends StatelessWidget {
  const _TripperLoaderThreeBounce({super.key, this.size, this.color});

  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SpinKitThreeBounce(
      color: color ?? context.theme.colorScheme.primary,
      size: size ?? 20.r,
    );
  }
}

class _TripperLoaderThreeBounceEditing extends StatelessWidget {
  const _TripperLoaderThreeBounceEditing({super.key, this.size, this.color});

  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return EditedSpinKitThreeBounce(
      color: color ?? context.theme.colorScheme.inversePrimary,
      size: size ?? 24.0,
    );
  }
}
