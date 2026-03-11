//
// import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
//
// import '../../features/calls/presentation/pages/answer_call.dart';
// import '../../main.dart';
// import '../../routes/router.dart';
//
// @pragma('vm:entry-point')
// Future<void> onCallAccepted(CallEvent callEvent) async {
//
//   // GetIt.I<CallsBloc>().add(AnswerVideoCallEvent(
//   //     chatId: callEvent.userInfo!["channel_id"].toString()));
//   // initialCallEvent=callEvent;
//   // navigatorKey.currentState!.context!.go(Uri(path:GRouter.config.applicationRoutes.kAnswerCall ,
//   //     queryParameters: {
//   //       "channelName":  callEvent.userInfo!["channel_id"].toString(),
//   //       "callerName":  callEvent.userInfo! ["callerName"]!,
//   //       "callerPhoto": callEvent.userInfo! ["callerPhoto"],
//   //     }).toString());
//   // Navigator.of(navigatorKey.currentState!.context).push(MaterialPageRoute(
//   //   builder: (context) => AnswerCall(
//   //     channelName: callEvent.userInfo!["channel_id"].toString(),
//   //     callerName: callEvent.userInfo!["callerName"]!,
//   //     callerPhoto: callEvent.userInfo!["photoPath"],
//   //   ),
//   // ));
// }
