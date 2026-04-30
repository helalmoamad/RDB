import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:rdb/core/utils/extensions/build_context.dart';
import 'package:rdb/routes/router.dart';
import 'package:rdb/splash_widget.dart';
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
    Future.delayed(const Duration(milliseconds: 6300), () {
      final hasToken = prefsRepository.walletToken != null;
      final isVerified =
          (prefsRepository.isVerifiedPhone ?? false) ||
          (prefsRepository.isVerifiedPhonePeforeExpiredToken ?? false);

      // ignore: use_build_context_synchronously
      context.go(
        !hasToken || !isVerified
            ? GRouter.config.applicationRoutes.kRegistrationPage
            : GRouter.config.applicationRoutes.kPinCodePage,
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
      body: Center(child: SplashWidget()),
    );
  }
}
