import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:rdb/core/utils/extensions/build_context.dart';
import 'package:rdb/core/version_update/version_update.dart';
import 'package:rdb/features/authentication/presentation/manager/auth_bloc.dart';
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
    GetIt.I<PrefsRepository>().setShouldShowPin(true);
    GetIt.I<AuthBloc>().add(GetUserProfileEvent());
    GetIt.I<AuthBloc>().add(GetPasskeyListEvent());
    // تحديث استباقي للتوكن مبكرًا لكسب الوقت قبل الوصول للصفحة الرئيسية
    GetIt.I<AuthBloc>().add(const EnsureWalletTokenValidEvent());
    // فحص التحديث يبدأ مع السبلاش بالتوازي مع مدته. لا نغادر إلا بعد اكتمال
    // الاثنين: الاختياري بعد إغلاق الحوار، والإلزامي لا يكتمل أبداً فيبقى
    // التطبيق خلف الحوار (المغادرة أثناء فتحه كانت ستستبدل route الحوار).
    Future.wait([
      Future<void>.delayed(const Duration(milliseconds: 6300)),
      VersionUpdate.checkOnSplash(),
    ]).then((_) {
      if (!mounted) return;
      final hasToken = prefsRepository.walletToken != null;

      final isNameEntered = (prefsRepository.userName?.length ?? 0) > 2;
      final isPinSet = (prefsRepository.passcode?.length ?? 0) > 3;

      context.go(
        !hasToken
            ? GRouter.config.applicationRoutes.kRegistrationPage
            : !isNameEntered
            ? GRouter.config.applicationRoutes.kEnterNamePage
            : !isPinSet
            ? GRouter.config.applicationRoutes.kPinCodeSetupPage
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
      body: Center(child: SplashWidget()),
    );
  }
}
