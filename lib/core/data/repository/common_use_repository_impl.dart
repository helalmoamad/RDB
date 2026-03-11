import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:rdb/core/api/api.dart';
import 'package:rdb/core/data/model/upload_file_cloudinary_response.dart';
import 'package:rdb/core/domin/repositories/common_use_repository.dart';
import 'package:rdb/core/error/failures.dart';

import '../data_source/common_use_repo_data_source.dart';

@LazySingleton(as: CommonUseRepository)
class CommonUseRepositoryImpl extends CommonUseRepository
    with HandlingExceptionRequest {
  final CommonUseRemoteDataSource commonUseRemoteDataSource;

  CommonUseRepositoryImpl(this.commonUseRemoteDataSource);

  @override
  Future<Either<Failure, UploadFileCloudinaryResponseModel>>
  uploadFileCloudinary(Map<String, dynamic> params) {
    return handlingExceptionRequest(
      tryCall: () => commonUseRemoteDataSource.uploadCloudinaryFile(params),
    );
  }
}
