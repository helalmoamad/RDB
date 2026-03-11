// To parse this JSON data, do
//
//     final sendOtpResponseModel = sendOtpResponseModelFromJson(jsonString);

import 'dart:convert';

SendOtpResponseModel sendOtpResponseModelFromJson(String str) =>
    SendOtpResponseModel.fromJson(json.decode(str));

String sendOtpResponseModelToJson(SendOtpResponseModel data) =>
    json.encode(data.toJson());

class SendOtpResponseModel {
  final String? message;
  final int? msegatId;
  final String? sessionInfo;
  final String? provider;

  SendOtpResponseModel({
    this.message,
    this.msegatId,
    this.sessionInfo,
    this.provider,
  });

  SendOtpResponseModel copyWith({
    String? message,
    int? msegatId,
    String? sessionInfo,
    String? provider,
  }) => SendOtpResponseModel(
    message: message ?? this.message,
    msegatId: msegatId ?? this.msegatId,
    sessionInfo: sessionInfo ?? this.sessionInfo,
    provider: provider ?? this.provider,
  );

  factory SendOtpResponseModel.fromJson(Map<String, dynamic> json) =>
      SendOtpResponseModel(
        message: json["message"],
        msegatId: json["msegatId"],
        sessionInfo: json["sessionInfo"],
        provider: json["provider"],
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "msegatId": msegatId,
    "sessionInfo": sessionInfo,
    "provider": provider,
  };
}
