import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'dart:developer' as dev;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:easy_localization/easy_localization.dart' as tran;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rdb/trydos_application.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:rdb/core/di/di_container.dart';
import 'package:rdb/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:root_check_flutter/root_check_flutter.dart';
import 'core/domin/repositories/prefs_repository.dart';
import 'package:rdb/services/security_service.dart';

bool declineCallBecauseOfNotificationButton = false;
bool isHydratedStorageInitialized = false;
bool isLoadDotenvFile = false;
bool isDependencyInitialized = false;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
////////////////////////////
bool notificationClicked = false;
//todo this list will store on it the api's that we try to load it and returned a failure for the first time so we check if it's not  in this list we try to reload it
List<String> isFailedTheFirstTime = [];
List<String> apisMustNotToRequest = [];
////////////////////////////////////////
int applicationVersion = 1;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // نرسم صفحة بيضاء فوراً (أول إطار) قبل أي تهيئة ثقيلة، فيُغلق سبلاش النظام
  // الإجباري (Android 12+) مباشرةً ويُجبَر التطبيق على المرور بها — ثم تتم
  // التهيئة الثقيلة وننتقل لصفحة السبلاش الرئيسية. هذا يمنع التجمّد على سبلاش
  // النظام على أي جهاز (بما فيها HiOS/TECNO).
  runApp(const _AppBootstrap());
}

/// يرسم أول إطار (صفحة بيضاء) فوراً ثم يُنفّذ تهيئة التطبيق الثقيلة، وعند جهوزها
/// يعرض التطبيق الفعلي. يضمن إغلاق سبلاش النظام دائماً ويمنع التجمّد عليه.
class _AppBootstrap extends StatefulWidget {
  const _AppBootstrap();

  @override
  State<_AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<_AppBootstrap> {
  bool _ready = false;
  bool _isDeviceRooted = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      // الترتيب مهم: التخزين قبل أي HydratedBloc، والـ DI قبل عرض التطبيق.
      HydratedBloc.storage = await HydratedStorage.build(
        storageDirectory: await getApplicationDocumentsDirectory(),
      );
      isHydratedStorageInitialized = true;
      HttpOverrides.global = MyHttpOverrides();
      await Future.wait([
        tran.EasyLocalization.ensureInitialized(),
        dotenv.load(),
        configureDependencies(),
      ]);
      isLoadDotenvFile = true;
      isDependencyInitialized = true;
      GetIt.I<PrefsRepository>().setTimerForOtpRunning(false);
      GetIt.I<AuthBloc>().add(GetUserCountryEvent());
      _isDeviceRooted = await _checkDeviceRooted();
      // تهيئة خدمة الأمان
      await SecurityService.instance.initialize();
    } catch (e, st) {
      dev.log('App bootstrap failed: $e', stackTrace: st);
    }
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    // صفحة بيضاء **دائمة خلف** التطبيق: تُرسَم كأول إطار (تُغلق سبلاش النظام)،
    // وتبقى مرئية أسفل TrydosApplication أثناء تركيبه (MaterialApp/الترجمة) —
    // فتمنع أي ومضة سوداء في الانتقال من الصفحة البيضاء إلى سبلاش التطبيق.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: Color(0xFFFFFFFF)),
          if (_ready)
            TrydosApplication(
              navKey: navigatorKey,
              isSecurityIssueFound: _isDeviceRooted,
            ),
        ],
      ),
    );
  }
}

Future<bool> _checkDeviceRooted() async {
  try {
    return await RootCheckFlutter.isDeviceRooted;
  } catch (e, st) {
    dev.log('Root check failed: $e', stackTrace: st);
    return false;
  }
}
