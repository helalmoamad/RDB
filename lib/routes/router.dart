import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rdb/features/authentication/presentation/pages/enter_name_page.dart';
import 'package:rdb/features/authentication/presentation/pages/first_registeration_page.dart';
import 'package:rdb/features/authentication/presentation/pages/login_successfully.dart';
import 'package:rdb/features/authentication/presentation/pages/passcode_welcome_page.dart';
// 'package:rdb/features/authentication/presentation/pages/register_completed.dart';
import 'package:rdb/features/authentication/presentation/pages/pin_code_page.dart';
import 'package:rdb/splash_page.dart';

import '../base_page.dart';
import '../features/authentication/presentation/pages/already_exist_account.dart';
import '../features/authentication/presentation/pages/number_not_registered.dart';

import '../main.dart';
import 'router_config.dart';

class GRouter {
  static GoRouter get router => _router;

  static RouterConfiguration get config => _config;

  static final RouterConfiguration _config = RouterConfiguration.init();

  static final GoRouter _router = GoRouter(
    observers: [BotToastNavigatorObserver()],
    initialLocation: _config.kRootRoute,
    overridePlatformDefaultLocation: true,
    navigatorKey: navigatorKey,
    routes: <RouteBase>[
      GoRoute(
        path: _config.kRootRoute,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return _builderPage(child: const SplashPage(), state: state);
        },
      ),

      // GoRoute(
      //     path: _config.applicationRoutes.kRoomCallPage,
      //     pageBuilder: (BuildContext context, GoRouterState state) {
      //       return _builderPage(
      //         child:  RoomCallPage(),
      //         state: state,
      //       );
      //     }),
      /*  GoRoute(
        path: _config.applicationRoutes.kRegistrationCompletedPage,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return _builderPage(
            child: RegisterCompleted(
              userName: state.uri.queryParameters['userName']!,
            ),
            state: state,
          );
        },
      ),*/
      GoRoute(
        path: _config.applicationRoutes.kRegistrationPage,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return _builderPage(child: const RegistrationPage(), state: state);
        },
      ),
      GoRoute(
        path: _config.applicationRoutes.kPinCodePage,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return _builderPage(child: const PinCodePage(), state: state);
        },
      ),
      GoRoute(
        path: _config.applicationRoutes.kEnterNamePage,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return _builderPage(child: const EnterNamePage(), state: state);
        },
      ),
      GoRoute(
        path: _config.applicationRoutes.kPasscodeWelcomePage,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return _builderPage(child: const PasscodeWelcomePage(), state: state);
        },
      ),

      GoRoute(
        path: _config.applicationRoutes.kBasePage,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return _builderPage(child: const BasePage(), state: state);
        },
        routes: [
          GoRoute(
            path: _config.applicationRoutes.kRegistrationPageName,
            pageBuilder: (BuildContext context, GoRouterState state) {
              return _builderPage(
                child: const RegistrationPage(),
                state: state,
              );
            },
            routes: [
              GoRoute(
                path: _config.applicationRoutes.kNumberNotRegisteredName,
                pageBuilder: (BuildContext context, GoRouterState state) {
                  return _builderPage(
                    child: NumberNotRegistered(
                      phoneNumber: state.uri.queryParameters['phoneNumber']!,
                    ),
                    state: state,
                  );
                },
              ),
              GoRoute(
                path: _config.applicationRoutes.kUserExistName,
                pageBuilder: (BuildContext context, GoRouterState state) {
                  return _builderPage(
                    child: AlreadyExistAccount(
                      phoneNumber: state.uri.queryParameters['phoneNumber']!,
                    ),
                    state: state,
                  );
                },
              ),
              GoRoute(
                path: _config.applicationRoutes.kLoginSuccessfullyPageName,
                pageBuilder: (BuildContext context, GoRouterState state) {
                  return _builderPage(
                    child: LoginSuccessfully(
                      phoneNumber: state.uri.queryParameters['phoneNumber']!,
                      fromLogin:
                          state.uri.queryParameters['fromLogin'] == 'true',
                    ),
                    state: state,
                  );
                },
              ),
            ],
          ),
          //Route(
          //   path: _config.applicationRoutes.kPageViewStoryCollectionsPageName,
          //   pageBuilder: (BuildContext context, GoRouterState state) {
          //     return _builderPage(
          //       child:  StoryCollectionPageView(initialPage: int.parse(state.uri.queryParameters['initialPage']!),),
          //       state: state,
          //     );
          //   },
          // ),
        ],
      ),
      // StatefulShellRoute.indexedStack(
      //   branches: [
      //     StatefulShellBranch(
      //       routes: [
      //         GoRoute(
      //           path: _config.applicationRoutes.kHomePage,
      //           pageBuilder: (BuildContext context, GoRouterState state) {
      //             return _builderPage(
      //               child: const HomePage(),
      //               state: state,
      //             );
      //           },
      //         ),
      //         GoRoute(
      //           path: _config.applicationRoutes.kHomePage,
      //           pageBuilder: (BuildContext context, GoRouterState state) {
      //             return _builderPage(
      //               child: const HomePage(),
      //               state: state,
      //             );
      //           },
      //         ),
      //         GoRoute(
      //           path: _config.applicationRoutes.kChatPage,
      //           pageBuilder: (BuildContext context, GoRouterState state) {
      //             return _builderPage(
      //               child: ChatPages(description: ''),
      //               state: state,
      //             );
      //           },
      //         ),
      //         GoRoute(
      //           path: _config.applicationRoutes.kHomePage,
      //           pageBuilder: (BuildContext context, GoRouterState state) {
      //             return _builderPage(
      //               child: const HomePage(),
      //               state: state,
      //             );
      //           },
      //         ),
      //       ],
      //     ),
      //   ],
      //   builder: (context, state, navigationShell) {
      //     return BasePage(
      //       navigationShell: navigationShell,
      //     );
      //   },
      // ),
    ],
    errorBuilder: (context, state) => const SplashPage(),
  );

  static Page<dynamic> _builderPage<T>({
    required Widget child,
    required GoRouterState state,
  }) {
    //if (Platform.isIOS) {
    return MaterialPage<T>(child: child, key: state.pageKey);
    // } else {
    //   return MaterialPage<T>(child: child, key: state.pageKey);
    // }
  }
}
