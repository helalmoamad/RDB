import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../enums/status_code_type.dart';

import '../api.dart';
import '../client_config.dart';
import 'detect_server.dart';
import 'dart:developer';

class GetClient<T> extends BaseApi<T> {
  GetClient({
    required this.requestPrams,
    required this.serverName,
    this.onReceiveProgress,
  }) : _fromJson = requestPrams.response.fromJson,
       _valueOnSuccess = requestPrams.response.returnValueOnSuccess,
       _endpoint = requestPrams.endpoint,
       _queryParameters = requestPrams.queryParameters,
       _receiveTimeout = requestPrams.receiveTimeout,
       _sendTimeout = requestPrams.sendTimeout,
       super(serverName);
  final Duration? _receiveTimeout;
  final Duration? _sendTimeout;
  final Stopwatch stopWatch = Stopwatch();
  RequestConfig<T> requestPrams;
  final ProgressCallback? onReceiveProgress;

  final FromJson<T>? _fromJson;
  final T? _valueOnSuccess;
  final String _endpoint;
  final Map<String, dynamic>? _queryParameters;
  // ignore: annotate_overrides, overridden_fields
  final ServerName serverName;
  @override
  Future<T> call() async {
    try {
      stopWatch.start();
      final baseUri = getBaseUriForSpecificServer(serverName);

      final Response response = await client.getUri(
        Uri(
          host: baseUri.host,
          scheme: baseUri.scheme,
          path: _endpoint,
          queryParameters: _queryParameters,
        ),
        options: options.copyWith(
          receiveTimeout: _receiveTimeout ?? options.receiveTimeout,
          sendTimeout: _sendTimeout ?? options.sendTimeout,
        ),
        onReceiveProgress: onReceiveProgress,
      );

      stopWatch.stop();

      // Prepare data for saving - handle String, null, or empty responses
      dynamic dataToSave = response.data;
      if (dataToSave is String) {
        // If data is a string (e.g., empty string in 204), convert to map
        if (dataToSave.trim().isEmpty) {
          dataToSave = <String, dynamic>{};
        } else {
          // Try to parse as JSON, if fails use as string value
          try {
            dataToSave = json.decode(dataToSave);
          } catch (e) {
            dataToSave = {'data': dataToSave};
          }
        }
      } else {
        dataToSave ??= <String, dynamic>{};
      }
      log('request time: ${stopWatch.elapsed.toString()}');
      prettyPrinterI(stopWatch.elapsed.toString());

      if (response.statusCode == StatusCode.operationSucceeded.code ||
          response.statusCode == StatusCode.createdSucceeded.code ||
          response.statusCode == 204) {
        if (_fromJson == null) {
          return Future.value(_valueOnSuccess);
        }

        // Handle 204 No Content - response.data might be null, empty string, or empty
        dynamic dataToParse = response.data;
        if (response.statusCode == 204) {
          // For 204, use empty map if data is null or empty string
          if (dataToParse == null ||
              (dataToParse is String && dataToParse.trim().isEmpty)) {
            dataToParse = <String, dynamic>{};
          }
        }

        return _fromJson(dataToParse);
      } else {
        final exception = getException(
          statusCode: response.statusCode!,
          message: response.data['message'] ?? response.data['status'],
        );
        throw exception;
      }
    } catch (exception) {
      rethrow;
    }
  }
}
