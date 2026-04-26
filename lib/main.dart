import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as dev;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rdb/trydos_application.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:rdb/core/di/di_container.dart';
import 'package:rdb/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:root_check_flutter/root_check_flutter.dart';
import 'core/domin/repositories/prefs_repository.dart';

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
int applicationVersion = 11;
request() async {
  final Stopwatch stopWatch = Stopwatch();
  stopWatch.start();
  //await http.get(Uri.parse('http://market_under_dev_backend.trydos.dev/api/new_v1/mobile/home/mainCategories'));///

  await Dio().getUri(Uri.parse('http://ip-api.com/json')).onError((e, st) {
    //
    dev.log(e.toString());
    return Response(requestOptions: RequestOptions());
  });

  stopWatch.stop();
  dev.log('request time ::::: ${stopWatch.elapsed.toString()}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );
  isHydratedStorageInitialized = true;
  HttpOverrides.global = MyHttpOverrides();
  await Future.wait([
    EasyLocalization.ensureInitialized(),
    dotenv.load(),
    configureDependencies(),
  ]);
  isLoadDotenvFile = true;
  GetIt.I<PrefsRepository>().setTimerForOtpRunning(false);
  isDependencyInitialized = true;
  GetIt.I<AuthBloc>().add(GetUserCountryEvent());
  final bool isDeviceRooted = await _isDeviceRooted();
  runApp(
    TrydosApplication(
      navKey: navigatorKey,
      isSecurityIssueFound: isDeviceRooted,
    ),
  );
}

Future<bool> _isDeviceRooted() async {
  try {
    return await RootCheckFlutter.isDeviceRooted;
  } catch (e, st) {
    dev.log('Root check failed: $e', stackTrace: st);
    return false;
  }
}
