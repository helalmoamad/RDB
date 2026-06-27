import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:rdb/core/error/failures.dart';
import 'package:rdb/core/use_case/use_case.dart';
import 'package:rdb/features/authentication/domain/repositories/auth_repository.dart';
import 'package:rdb/main.dart';

/// إرسال توكن FCM للباك (POST /send/fcm). يُمرَّر التوكن كـ params.
@injectable
class SendFcmUseCase implements UseCase<bool, SendFcmParams> {
  SendFcmUseCase(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, bool>> call(SendFcmParams params) =>
      repository.sendFcmToken(params.map);
}

class SendFcmParams {
  String? fcmToken;
  String? deviceId;
  String? deviceName;
  String? osVersion;

  SendFcmParams({
    this.deviceName,
    this.fcmToken,
    this.deviceId,
    this.osVersion,
  });
  Map<String, dynamic> get map => {
    "fcmToken": fcmToken,
    "platform": Platform.isAndroid ? 'android' : 'ios',
    "deviceName": deviceName,
    "deviceId": deviceId,
    "appVersion": applicationVersion.toString(),
    "osVersion": osVersion,
  };
}
