// ignore_for_file: overridden_fields

import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';

import '../../../enums/status_code_type.dart';
import '../api.dart';
import '../client_config.dart';
import 'detect_server.dart';

class PatchClient<T> extends BaseApi<T> {
  PatchClient({
    required this.requestPrams,
    required this.serverName,
    this.onSendProgress,
    this.onReceiveProgress,
  }) : _fromJson = requestPrams.response.fromJson,
       _valueOnSuccess = requestPrams.response.returnValueOnSuccess,
       _data = requestPrams.data,
       _extraHeaders = requestPrams.extraHeaders,
       _queryParameters = requestPrams.queryParameters,
       _endpoint = requestPrams.endpoint,
       _receiveTimeout = requestPrams.receiveTimeout,
       _sendTimeout = requestPrams.sendTimeout,
       super(serverName);

  final RequestConfig<T> requestPrams;
  final Stopwatch stopWatch = Stopwatch();
  final ProgressCallback? onSendProgress;
  final ProgressCallback? onReceiveProgress;
  final Duration? _receiveTimeout;
  final Duration? _sendTimeout;

  final FromJson<T>? _fromJson;
  final T? _valueOnSuccess;
  final dynamic _queryParameters;
  final dynamic _data;
  final Map<String, dynamic>? _extraHeaders;
  final String _endpoint;

  @override
  final ServerName serverName;

  @override
  Future<T> call() async {
    try {
      final baseUri = getBaseUriForSpecificServer(serverName);
      stopWatch.start();
      final Response response = await client.patchUri(
        Uri(
          host: baseUri.host,
          scheme: baseUri.scheme,
          path: _endpoint,
          queryParameters: _queryParameters,
        ),
        options: options.copyWith(
          receiveTimeout: _receiveTimeout ?? options.receiveTimeout,
          sendTimeout: _sendTimeout ?? options.sendTimeout,
          headers: _extraHeaders != null
              ? (options.headers?..addAll(_extraHeaders))
              : options.headers,
        ),
        data: _data,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      stopWatch.stop();

      dynamic dataToParse = response.data;
      if (response.statusCode == 204) {
        if (dataToParse == null ||
            (dataToParse is String && dataToParse.trim().isEmpty)) {
          dataToParse = <String, dynamic>{};
        }
      } else if (dataToParse is String) {
        if (dataToParse.trim().isEmpty) {
          dataToParse = <String, dynamic>{};
        } else {
          try {
            dataToParse = json.decode(dataToParse);
          } catch (_) {
            dataToParse = {'data': dataToParse};
          }
        }
      } else {
        dataToParse ??= <String, dynamic>{};
      }

      log('request time: ${stopWatch.elapsed.toString()}');
      prettyPrinterI(stopWatch.elapsed.toString());

      if (response.statusCode == StatusCode.operationSucceeded.code ||
          response.statusCode == StatusCode.createdSucceeded.code ||
          response.statusCode == 204) {
        if (_fromJson == null) {
          return await Future.value(_valueOnSuccess);
        }

        return _fromJson(dataToParse);
      } else {
        throw getException(
          statusCode: response.statusCode!,
          message: response.data['message'] ?? response.data['status'],
        );
      }
    } catch (exception) {
      rethrow;
    }
  }
}
