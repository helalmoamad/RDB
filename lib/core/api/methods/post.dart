// ignore_for_file: overridden_fields, camel_case_types

import 'dart:async';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:rdb/common/helper/show_message.dart';

import '../../../enums/status_code_type.dart';
import '../api.dart';
import '../client_config.dart';
import 'detect_server.dart';

typedef whenComplete = FutureOr<void> Function();

class PostClient<T> extends BaseApi<T> {
  final void Function(bool isUploadingSuccess)? onUploadingFinished;

  PostClient({
    required this.requestPrams,
    required this.serverName,
    this.onUploadingFinished,
    this.onSendProgress,
    this.onReceiveProgress,
  }) : _fromJson = requestPrams.response.fromJson,
       _valueOnSuccess = requestPrams.response.returnValueOnSuccess,
       _queryParameters = requestPrams.queryParameters,
       _data = requestPrams.data,
       _extraHeaders = requestPrams.extraHeaders,
       _endpoint = requestPrams.endpoint,
       _receiveTimeout = requestPrams.receiveTimeout,
       _sendTimeout = requestPrams.sendTimeout,
       super(serverName);
  final Stopwatch stopWatch = Stopwatch();
  final RequestConfig<T> requestPrams;

  final ProgressCallback? onSendProgress;
  final ProgressCallback? onReceiveProgress;
  final Duration? _receiveTimeout;
  final Duration? _sendTimeout;
  final Map<String, dynamic>? _extraHeaders;
  final FromJson<T>? _fromJson;
  final T? _valueOnSuccess;
  final dynamic _queryParameters;
  final dynamic _data;
  final String _endpoint;
  // ignore: annotate_overrides
  final ServerName serverName;

  @override
  Future<T> call() async {
    try {
      final baseUri = getBaseUriForSpecificServer(serverName);
      //todo just in case the server is Cloudinary i want to clear the header
      if (serverName == ServerName.cloudinary) {
        options = Options();
        client.options.headers = {};
        // Fluttertoast.showToast(msg: client.options.headers.toString());
      }
      stopWatch.start();
      final Response response = await client
          .postUri(
            Uri(
              host: baseUri.host,
              scheme: baseUri.scheme,
              path: _endpoint,
              queryParameters: _queryParameters,
            ),
            options: options.copyWith(
              receiveTimeout: _receiveTimeout ?? options.receiveTimeout,
              sendTimeout: _sendTimeout ?? options.sendTimeout,
              // خريطة جديدة لهذا الطلب وحده: `addAll` كانت تكتب داخل خريطة
              // ترويسات Dio المفرد، فتبقى الترويسة على كل الطلبات اللاحقة —
              // وهذا يسرّب أسرارًا لجهات لا تحتاجها (برهان الوجه أحادي
              // الاستخدام، مفتاح التاجر) وقد يُبطلها الخادم.
              headers: _extraHeaders != null
                  ? {...?options.headers, ..._extraHeaders}
                  : options.headers,
            ),
            data: _data,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          )
          .then((response) {
            stopWatch.stop();
            log('request time: ${stopWatch.elapsed.toString()}');
            onUploadingFinished?.call(true);
            return response;
          })
          .catchError((error, errorStack) {
            // إظهار رسالة الفشل من الباك إند
            if (error.response.statusCode == 422) {
              showMessage(
                error.response.data['message'],
                foreGroundColor: Colors.white,
                backGroundColor: Colors.red,
                hasError: true,
                showInRelease: true,
              );
            }
            onUploadingFinished?.call(false);
            return error;
          });

      if (response.statusCode == StatusCode.operationSucceeded.code ||
          response.statusCode == StatusCode.createdSucceeded.code ||
          response.statusCode == 204) {
        if (_fromJson == null) {
          return Future.value(_valueOnSuccess);
        }

        return _fromJson(response.data);
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
