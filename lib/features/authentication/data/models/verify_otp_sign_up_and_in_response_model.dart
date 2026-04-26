// To parse this JSON data, do
//
//     final verifyOtpSignUpAndInResponseModel = verifyOtpSignUpAndInResponseModelFromJson(jsonString);

import 'dart:convert';

VerifyOtpSignUpAndInResponseModel verifyOtpSignUpAndInResponseModelFromJson(
  String str,
) => VerifyOtpSignUpAndInResponseModel.fromJson(json.decode(str));

String verifyOtpSignUpAndInResponseModelToJson(
  VerifyOtpSignUpAndInResponseModel data,
) => json.encode(data.toJson());

class VerifyOtpSignUpAndInResponseModel {
  final User? user;
  final String? status;
  final Token? accessToken;
  final Token? refreshToken;

  VerifyOtpSignUpAndInResponseModel({
    this.user,
    this.accessToken,
    this.refreshToken,
    this.status,
  });

  VerifyOtpSignUpAndInResponseModel copyWith({
    User? user,
    Token? accessToken,
    Token? refreshToken,
    String? status,
  }) => VerifyOtpSignUpAndInResponseModel(
    user: user ?? this.user,
    accessToken: accessToken ?? this.accessToken,
    refreshToken: refreshToken ?? this.refreshToken,
    status: status ?? this.status,
  );

  factory VerifyOtpSignUpAndInResponseModel.fromJson(
    Map<String, dynamic> json,
  ) => VerifyOtpSignUpAndInResponseModel(
    status: json["status"],
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    accessToken: json["accessToken"] == null
        ? null
        : Token.fromJson(json["accessToken"]),
    refreshToken: json["refreshToken"] == null
        ? null
        : Token.fromJson(json["refreshToken"]),
  );

  Map<String, dynamic> toJson() => {
    "user": user?.toJson(),
    "status": status,
    "accessToken": accessToken?.toJson(),
    "refreshToken": refreshToken?.toJson(),
  };
}

class Token {
  final String? token;
  final DateTime? expiresAt;

  Token({this.token, this.expiresAt});

  Token copyWith({String? token, DateTime? expiresAt}) =>
      Token(token: token ?? this.token, expiresAt: expiresAt ?? this.expiresAt);

  factory Token.fromJson(Map<String, dynamic> json) => Token(
    token: json["token"],
    expiresAt: json["expiresAt"] == null
        ? null
        : DateTime.parse(json["expiresAt"]),
  );

  Map<String, dynamic> toJson() => {
    "token": token,
    "expiresAt": expiresAt?.toIso8601String(),
  };
}

class User {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phoneNumber;
  final String? profilePictureUrl;
  final String? userType;
  final bool? isEmailVerified;
  final bool? isPhoneVerified;
  final bool? isBlocked;
  final String? blockReason;
  final DateTime? blockedAt;
  final bool? isTwoFactorEnabled;
  final String? language;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Address? address;
  final KycVerification? kycVerification;

  User({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.profilePictureUrl,
    this.userType,

    this.isEmailVerified,
    this.isPhoneVerified,
    this.isBlocked,
    this.blockReason,
    this.blockedAt,
    this.isTwoFactorEnabled,
    this.language,
    this.createdAt,
    this.updatedAt,
    this.address,
    this.kycVerification,
  });

  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? profilePictureUrl,
    String? userType,
    BrowserInfo? ratingStats,
    BrowserInfo? browserInfo,
    BrowserInfo? locationInfo,
    BrowserInfo? guestToken,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    bool? isBlocked,
    String? blockReason,
    DateTime? blockedAt,
    bool? isTwoFactorEnabled,
    String? language,
    DateTime? createdAt,
    DateTime? updatedAt,
    Address? address,
    KycVerification? kycVerification,
  }) => User(
    id: id ?? this.id,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    email: email ?? this.email,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
    userType: userType ?? this.userType,
    isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
    isBlocked: isBlocked ?? this.isBlocked,
    blockReason: blockReason ?? this.blockReason,
    blockedAt: blockedAt ?? this.blockedAt,
    isTwoFactorEnabled: isTwoFactorEnabled ?? this.isTwoFactorEnabled,
    language: language ?? this.language,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    address: address ?? this.address,
    kycVerification: kycVerification ?? this.kycVerification,
  );

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    firstName: json["firstName"],
    lastName: json["lastName"],
    email: json["email"],
    phoneNumber: json["phoneNumber"],
    profilePictureUrl: json["profilePictureURL"],
    userType: json["userType"],
    isEmailVerified: json["isEmailVerified"],
    isPhoneVerified: json["isPhoneVerified"],
    isBlocked: json["isBlocked"],
    blockReason: json["blockReason"],
    blockedAt: json["blockedAt"] == null
        ? null
        : DateTime.parse(json["blockedAt"]),
    isTwoFactorEnabled: json["isTwoFactorEnabled"],
    language: json["language"],
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null
        ? null
        : DateTime.parse(json["updatedAt"]),
    address: json["address"] == null ? null : Address.fromJson(json["address"]),
    kycVerification: json["kycVerification"] == null
        ? null
        : KycVerification.fromJson(json["kycVerification"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "firstName": firstName,
    "lastName": lastName,
    "email": email,
    "phoneNumber": phoneNumber,
    "profilePictureURL": profilePictureUrl,
    "userType": userType,
    "isEmailVerified": isEmailVerified,
    "isPhoneVerified": isPhoneVerified,
    "isBlocked": isBlocked,
    "blockReason": blockReason,
    "blockedAt": blockedAt?.toIso8601String(),
    "isTwoFactorEnabled": isTwoFactorEnabled,
    "language": language,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "address": address?.toJson(),
    "kycVerification": kycVerification?.toJson(),
  };
}

class Address {
  final String? id;
  final String? userId;
  final Id? countryId;
  final Id? regionId;
  final Id? cityId;
  final String? address1;
  final String? address2;
  final String? zipCode;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Address({
    this.id,
    this.userId,
    this.countryId,
    this.regionId,
    this.cityId,
    this.address1,
    this.address2,
    this.zipCode,
    this.createdAt,
    this.updatedAt,
  });

  Address copyWith({
    String? id,
    String? userId,
    Id? countryId,
    Id? regionId,
    Id? cityId,
    String? address1,
    String? address2,
    String? zipCode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Address(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    countryId: countryId ?? this.countryId,
    regionId: regionId ?? this.regionId,
    cityId: cityId ?? this.cityId,
    address1: address1 ?? this.address1,
    address2: address2 ?? this.address2,
    zipCode: zipCode ?? this.zipCode,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    id: json["id"],
    userId: json["userId"],
    countryId: json["countryId"] == null
        ? null
        : Id.fromJson(json["countryId"]),
    regionId: json["regionId"] == null ? null : Id.fromJson(json["regionId"]),
    cityId: json["cityId"] == null ? null : Id.fromJson(json["cityId"]),
    address1: json["address1"],
    address2: json["address2"],
    zipCode: json["zipCode"],
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null
        ? null
        : DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "countryId": countryId?.toJson(),
    "regionId": regionId?.toJson(),
    "cityId": cityId?.toJson(),
    "address1": address1,
    "address2": address2,
    "zipCode": zipCode,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

class Id {
  final String? id;
  final String? name;
  final String? nameAr;
  final String? code;

  Id({this.id, this.name, this.nameAr, this.code});

  Id copyWith({String? id, String? name, String? nameAr, String? code}) => Id(
    id: id ?? this.id,
    name: name ?? this.name,
    nameAr: nameAr ?? this.nameAr,
    code: code ?? this.code,
  );

  factory Id.fromJson(Map<String, dynamic> json) => Id(
    id: json["id"],
    name: json["name"],
    nameAr: json["nameAr"],
    code: json["code"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "nameAr": nameAr,
    "code": code,
  };
}

class BrowserInfo {
  BrowserInfo();

  BrowserInfo copyWith() => BrowserInfo();

  factory BrowserInfo.fromJson(Map<String, dynamic> json) => BrowserInfo();

  Map<String, dynamic> toJson() => {};
}

class KycVerification {
  final String? status;
  final DateTime? expiresAt;

  KycVerification({this.status, this.expiresAt});

  KycVerification copyWith({String? status, DateTime? expiresAt}) =>
      KycVerification(
        status: status ?? this.status,
        expiresAt: expiresAt ?? this.expiresAt,
      );

  factory KycVerification.fromJson(Map<String, dynamic> json) =>
      KycVerification(
        status: json["status"],
        expiresAt: json["expiresAt"] == null
            ? null
            : DateTime.parse(json["expiresAt"]),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "expiresAt": expiresAt?.toIso8601String(),
  };
}
