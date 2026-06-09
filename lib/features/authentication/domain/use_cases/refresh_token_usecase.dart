import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/verify_otp_sign_up_and_in_response_model.dart';
import '../repositories/auth_repository.dart';

@injectable
class RefreshTokenUsecase
    implements UseCase<VerifyOtpSignUpAndInResponseModel, String> {
  RefreshTokenUsecase(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, VerifyOtpSignUpAndInResponseModel>> call(
    String refreshToken,
  ) async {
    return repository.refreshToken(refreshToken);
  }
}
