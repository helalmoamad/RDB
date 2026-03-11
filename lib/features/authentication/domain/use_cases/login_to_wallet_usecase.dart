import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:rdb/features/authentication/data/models/login_to_wallet_model.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repositories/auth_repository.dart';

@injectable
class LoginToWalletUseCase
    implements UseCase<LoginToWalletModel, LoginToWalletParams> {
  LoginToWalletUseCase(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, LoginToWalletModel>> call(
    LoginToWalletParams params,
  ) async {
    return repository.loginToWallet(params.map);
  }
}

class LoginToWalletParams {
  String? otpIdToken;
  String? phone;
  String? name;
  String? originalUserId;

  LoginToWalletParams({
    this.phone,
    this.otpIdToken,
    this.name,
    this.originalUserId,
  });
  Map<String, dynamic> get map => {
    "otp_id_token": otpIdToken,
    "mobile_phone": phone,
    "firstName": name,
  };
}
