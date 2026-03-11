import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:rdb/base_page.dart';
import 'package:rdb/core/utils/extensions/build_context.dart';
import 'package:rdb/routes/router.dart';
import 'core/domin/repositories/prefs_repository.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();

  @override
  void initState() {
    Future.delayed(Duration(seconds: 3), () {
      // ignore: use_build_context_synchronously
      context.go(
        prefsRepository.walletToken == null
            ? GRouter.config.applicationRoutes.kRegistrationPage
            : GRouter.config.applicationRoutes.kBasePage,
      );
    });

    super.initState();
  }

  @override
  void didChangeDependencies() async {
    /*if (!_eventLogged) {
      FirebaseAnalyticsService.logEventForSession(
        executedEventName: AnalyticsButtonsEventNameConst.WEl,
        eventName: AnalyticsEventsConst.SCREEN_VIEW,
        extraParams: {
          'screen_name': AuthScreenConst.WELCOME_SCREEN,
          'screen_path': '',
          'platform': GlobalPlatform.MOBILE,
        },
      );
      //////////
      _eventLogged = true;
    }*/

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: Center(child: logo),
    );
  }
}
