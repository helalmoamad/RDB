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
import 'package:posthog_flutter/posthog_flutter.dart';
import 'core/domin/repositories/prefs_repository.dart';
import 'package:rdb/services/security_service.dart';
import 'package:rdb/service/analytics_service.dart';
import 'package:rdb/service/notification_service/notification_service.dart';

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
int applicationVersion = 30;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // ⚠️ مهم جداً لِـ Session Replay: يجب تهيئة PostHog (Posthog().setup) **قبل**
  // runApp. لأن PostHogWidget.initState يقرأ Posthog().config، فإن كان null (لم
  // تتم التهيئة بعد) يخرج فوراً ولا يبدأ التقاط اللقطات ولا يسجّل مستمع التفعيل —
  // فتظهر الجلسات بأحداث ومدة لكن **بلا فيديو** ("missing snapshot data").
  // لذا نحمّل .env ونهيّئ PostHog هنا أولاً، ثم نلفّ التطبيق بـ PostHogWidget.
  try {
    await dotenv.load();
    await AnalyticsService.instance.init();
  } catch (e, st) {
    dev.log('PostHog early init failed: $e', stackTrace: st);
  }
  // PostHogWidget يلفّ كامل شجرة الويدجت ليتيح تسجيل الجلسات (Session Replay)
  // لكل الشاشات — بما فيها شاشات مكتبة trydos_wallet المعروضة داخل نفس الشجرة.
  runApp(const PostHogWidget(child: _AppBootstrap()));
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
      // تهيئة PostHog بعد تحميل .env (يقرأ المفاتيح منه). يلتقط Session Replay
      // كل شاشات التطبيق بما فيها شاشات مكتبة المحفظة لأنها ضمن PostHogWidget.
      await AnalyticsService.instance.init();
      // تهيئة الإشعارات (Firebase Messaging + الإشعارات المحلّية) — ملف واحد يدير
      // كل الحالات، ومنطق كل نوع في handle_with_notification_type.dart.
      await AppNotificationService.instance.init();
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
