import 'package:injectable/injectable.dart';

import '../../../common/constant/configuration/cloudinary_url_routes.dart';
import '../../api/client_config.dart';
import '../../api/methods/detect_server.dart';
import '../../api/methods/post.dart';
import '../model/upload_file_cloudinary_response.dart';

@injectable
class CommonUseRemoteDataSource {
  Future<UploadFileCloudinaryResponseModel> uploadCloudinaryFile(
    Map<String, dynamic> params,
  ) {
    PostClient<UploadFileCloudinaryResponseModel> uploadCloudinaryFile =
        PostClient<UploadFileCloudinaryResponseModel>(
          onUploadingFinished: params['usingOnUploadingFinishedFunction']
              ? ((bool isUploadingSuccess) {})
              : null,
          onSendProgress: params['usingSendProgressFunction']
              ? (count, total) {}
              : null,
          requestPrams: RequestConfig<UploadFileCloudinaryResponseModel>(
            receiveTimeout: const Duration(hours: 1),
            sendTimeout: const Duration(hours: 1),
            endpoint: CloudinaryEndPoints.uploadEP,
            data: params['data'],
            response: ResponseValue<UploadFileCloudinaryResponseModel>(
              fromJson: (response) =>
                  UploadFileCloudinaryResponseModel.fromJson(response),
            ),
          ),
          serverName: ServerName.cloudinary,
        );
    // uploadStory.call();
    return uploadCloudinaryFile();
  }
}
