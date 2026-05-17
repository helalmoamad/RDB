import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repositories/auth_repository.dart';

@injectable
class UpdateUserProfileUseCase
    implements UseCase<bool, UpdateUserProfileParams> {
  UpdateUserProfileUseCase(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, bool>> call(UpdateUserProfileParams params) async {
    return repository.updateUserProfile(params.map);
  }
}

class UpdateUserProfileParams {
  UpdateUserProfileParams({
    required this.profilePictureUrl,
    required this.firstName,
    required this.lastName,
  });

  final String profilePictureUrl;
  final String firstName;
  final String lastName;

  Map<String, dynamic> get map => {
    'profilePictureURL': profilePictureUrl,
    'firstName': firstName,
    'lastName': lastName,
  };
}
