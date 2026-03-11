import 'dart:async';

import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:rdb/common/constant/constant.dart';

import 'package:rdb/core/domin/repositories/prefs_repository.dart';

import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

//import 'package:flutter_svg/svg.dart';
import 'package:rdb/home_page.dart';

//import 'common/constant/design/assets_provider.dart';

Widget get logo {
  return SizedBox(
    width: 300,
    height: 200,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(AppAssets.rdb),
        const SizedBox(height: 12),
        SvgPicture.asset(AppAssets.rammazDigitalBanking),
      ],
    ),
  );
}

class BasePage extends StatefulWidget {
  const BasePage({super.key});

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> with WidgetsBindingObserver {
  final ValueNotifier<int> buildSearchResult = ValueNotifier(0);
  bool showUpgradeApp = true;
  Timer? _logoutTimer;
  @override
  @override
  void dispose() {
    _logoutTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeMetrics() {
    setState(() {});
    super.didChangeMetrics();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xffFFFFFF),
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    super.didChangeDependencies();
  }

  final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();

  bool requestMainCategoriesDone = false;

  @override
  Widget build(BuildContext context) {
    _prefsRepository.setTokenExpired(false);
    return HomePage();
  }
}
