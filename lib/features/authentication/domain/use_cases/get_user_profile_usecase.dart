import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:rdb/core/error/failures.dart';
import 'package:rdb/core/use_case/use_case.dart';
import 'package:rdb/features/authentication/domain/repositories/auth_repository.dart';
import '../../data/models/user_profile_model.dart';

@injectable
class GetUserProfileUseCase implements UseCase<UserProfileModel, NoParams> {
  final AuthRepository repository;

  GetUserProfileUseCase(this.repository);

  @override
  Future<Either<Failure, UserProfileModel>> call(NoParams params) {
    return repository.getUserProfile();
  }
}
