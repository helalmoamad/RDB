import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:rdb/common/helper/helper_functions.dart';

import 'language_service.dart';

class LocalizationService extends StatelessWidget {
  final Widget child;
  const LocalizationService({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return EasyLocalization(
      path: "assets/languages",
      startLocale: HelperFunctions.getInitLocale(),
      fallbackLocale: HelperFunctions.getInitLocale(),
      supportedLocales: supportedLocal,
      child: child,
    );
  }
}
