import 'package:dartz/dartz.dart';

import '../../data/model/upload_file_cloudinary_response.dart';
import '../../error/failures.dart';

abstract class CommonUseRepository {
  Future<Either<Failure, UploadFileCloudinaryResponseModel>>
      uploadFileCloudinary(Map<String, dynamic> params);
}
