import 'dart:async';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../enums/status_code_type.dart';
import '../error/exception.dart';
import '../error/failures.dart';

typedef RequestCall<T> = Future<T> Function();

mixin HandlingExceptionRequest {
  void prettyPrinterError(final String message) {
    Logger(printer: PrettyPrinter(methodCount: 0)).e(message);
  }

  void prettyPrinterWtf(final String message) {
    // ignore: deprecated_member_use
    Logger(printer: PrettyPrinter(methodCount: 0)).wtf(message);
  }

  void prettyPrinterI(final String message) {
    Logger(printer: PrettyPrinter(methodCount: 0)).i(message);
  }

  void prettyPrinterV(final String message) {
    // ignore: deprecated_member_use
    Logger(printer: PrettyPrinter(methodCount: 0)).v(message);
  }

  Exception getException({required int statusCode, String? message}) {
    //if(tryAgain==true)
    //return TryAgainException
    if (statusCode == StatusCode.operationFailed.code) {
      return OperationFailedException(message: message);
    } else if (statusCode == StatusCode.serverError.code) {
      return ServerExceptionForCode500(
        message: message,
        statusCode: statusCode,
      );
    } else if (statusCode == StatusCode.unauth.code) {
      return Unauth(message: message, statusCode: statusCode);
    } else {
      return ServerException(message: message);
    }
  }

  Future<Either<Failure, T>> handlingExceptionRequest<T>({
    required RequestCall<T> tryCall,
  }) async {
    try {
      T response = await tryCall();
      return Right(response);
    } on ServerExceptionForCode500 {
      // Fluttertoast.showToast(msg: 'sssssss',backgroundColor: Colors.yellow);
      prettyPrinterError("***|| ServerExceptionForCode500 ||*** ");
      return const Left(
        ServerFailure("ServerExceptionForCode500", statusCode: 500),
      );
    } on Unauth {
      // Fluttertoast.showToast(msg: 'sssssss',backgroundColor: Colors.yellow);
      prettyPrinterError("***|| Unauth ||*** ");
      return const Left(ServerFailure("Unauth ", statusCode: 401));
    } on ServerException catch (e) {
      // Fluttertoast.showToast(msg: 'sssssss',backgroundColor: Colors.yellow);
      prettyPrinterError("***|| ServerException ||*** ");
      if (e.hashCode == 422) {
        // مرر رسالة الباك الحقيقية
        return Left(
          ServerFailure(
            e.message ?? "ServerException",
            message: e.message,
            statusCode: 422,
          ),
        );
      }
      return const Left(ServerFailure("ServerException", statusCode: 400));
    } on DioException catch (e, s) {
      // Fluttertoast.showToast(msg: 'aaaaaaaaaaaa',backgroundColor: Colors.yellow);

      prettyPrinterError("***|| DioError ||*** \n $s");

      // Extract message from response data if available (especially for 422)
      String? errorMessage;
      int? statusCode = e.response?.statusCode;

      if (e.response?.data != null) {
        try {
          if (e.response!.data is Map<String, dynamic>) {
            errorMessage = e.response!.data['message'] as String?;
          } else if (e.response!.data is String) {
            // Try to parse string as JSON
            try {
              final decoded = json.decode(e.response!.data as String);
              if (decoded is Map<String, dynamic>) {
                errorMessage = decoded['message'] as String?;
              }
            } catch (_) {
              // If parsing fails, use the string as message
              errorMessage = e.response!.data as String;
            }
          }
        } catch (_) {
          // If extraction fails, use default message
        }
      }

      // Handle 422 specifically
      if (statusCode == 422) {
        return Left(
          ServerFailure(
            errorMessage ?? "Validation error",
            message: errorMessage,
            statusCode: 422,
          ),
        );
      }

      return Left(
        DioFailure(statusCode: statusCode ?? 400, message: errorMessage),
      );
    } catch (e, stackTrace) {
      prettyPrinterError(
        "***|| CATCH ERROR ||***"
        "\n $e"
        "***|| Stack Trace ||***"
        "\n $stackTrace",
      );
      return const Left(ServerFailure("ServerException", statusCode: 400));
    }
  }
}
