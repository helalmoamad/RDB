import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:rdb/core/error/failures.dart';
import 'package:rdb/core/use_case/use_case.dart';
import 'package:rdb/features/authentication/domain/repositories/auth_repository.dart';

/// إرسال توكن FCM للباك (POST /send/fcm). يُمرَّر التوكن كـ params.
@injectable
class RemoveFcmUsecase implements UseCase<bool, RemoveFcmParams> {
  RemoveFcmUsecase(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, bool>> call(RemoveFcmParams params) =>
      repository.sendFcmToken(params.map);
}

class RemoveFcmParams {
  String? fcmToken;

  RemoveFcmParams({this.fcmToken});
  Map<String, dynamic> get map => {"fcmToken": fcmToken};
}
