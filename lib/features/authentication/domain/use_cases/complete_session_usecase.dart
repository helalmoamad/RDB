import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/verify_otp_sign_up_and_in_response_model.dart';
import '../repositories/auth_repository.dart';

@injectable
class CompleteSessionUsecase
    implements
        UseCase<VerifyOtpSignUpAndInResponseModel, CompleteSessionParams> {
  CompleteSessionUsecase(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, VerifyOtpSignUpAndInResponseModel>> call(
    CompleteSessionParams params,
  ) async {
    return repository.completeSession(params.map);
  }
}

class CompleteSessionParams {
  String sessionToken;

  CompleteSessionParams({required this.sessionToken});

  Map<String, dynamic> get map {
    final data = <String, dynamic>{"sessionToken": sessionToken};

    return data;
  }
}
