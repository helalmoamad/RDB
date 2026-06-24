import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:rdb/core/error/failures.dart';
import 'package:rdb/core/use_case/use_case.dart';
import 'package:rdb/features/authentication/domain/repositories/auth_repository.dart';

/// إرسال توكن FCM للباك (POST /send/fcm). يُمرَّر التوكن كـ params.
@injectable
class SendFcmUseCase implements UseCase<bool, String> {
  SendFcmUseCase(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, bool>> call(String token) =>
      repository.sendFcmToken(token);
}
