// import 'dart:io';
//
// import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
// import 'package:flutter/foundation.dart';
// import 'package:get_it/get_it.dart';
// import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
//
// import '../../core/di/di_container.dart';
// import '../../features/calls/presentation/bloc/calls_bloc.dart';
// import '../../features/chat/data/models/my_chats_response_model.dart';
//
// @pragma('vm:entry-point')
// Future<void> onCallRejected(CallEvent callEvent) async {
//   await configureDependencies();
//
//   // Chat currentChat = GetIt.I<ChatBloc>().state.chats.firstWhere(
//   //     (element) => element.id == callEvent.userInfo!['channel_id'].toString());
//   // debugPrint("asdfasdas${currentChat.id!}");
// HttpOverrides.global = MyHttpOverrides();
//   debugPrint("callaczx${callEvent.callerName}");
//   debugPrint("callaczx${callEvent.callPhoto}");
//   GetIt.I<CallsBloc>().add(RejectVideoCallEvent(
//       chatId: callEvent.userInfo!["channel_id"].toString()));
// }
