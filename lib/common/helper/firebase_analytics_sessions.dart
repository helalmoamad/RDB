// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:get_it/get_it.dart';
// import 'package:injectable/injectable.dart';
// import 'package:trydos/core/domin/repositories/prefs_repository.dart';
// import 'package:uuid/uuid.dart';

// class CustomSession {
//   String? sessionName;
//   String sessionId;
//   DateTime startTime;
//   DateTime? endTime;
//   List<Map<String, dynamic>> events;

//   CustomSession()
//       : sessionId = Uuid().v4(),
//         startTime = DateTime.now()
//             .toUtc()
//             .add(Duration(minutes: GetIt.I<PrefsRepository>().getdurtion ?? 0)),
//         events = [];

//   void addEvent(String eventName, Map<String, dynamic> parameters) {
//     events.add({
//       'name': eventName,
//       'parameters': parameters,
//       'timestamp': DateTime.now().millisecondsSinceEpoch,
//     });
//   }

//   void endSession() {
//     endTime = DateTime.now()
//         .toUtc()
//         .add(Duration(minutes: GetIt.I<PrefsRepository>().getdurtion ?? 0));
//   }
// }

// @LazySingleton()
// class SessionManager {
//   CustomSession? currentSession;

//   void startNewSession() {
//     if (currentSession != null) {
//       endCurrentSession();
//     }
//     currentSession = CustomSession();
//   }

//   void endCurrentSession() async {
//     if (currentSession != null) {
//       currentSession!.endSession();
//       FirebaseAnalytics.instance.logEvent(
//         name: currentSession!.sessionName!,
//         parameters: {
//           'session_id': currentSession?.sessionId,
//           'session_startAt': currentSession?.startTime,
//           'session_endAt': currentSession?.endTime,
//           "evets": currentSession!.events
//         },
//       );
//       currentSession = null;
//     }
//   }

//   void addEventToSession(String eventName, Map<String, dynamic> parameters) {
//     currentSession?.addEvent(eventName, parameters);
//   }
//   // إرسال الحدث إلى Firebase Analytics
// }
