// To parse this JSON data, do
//
//     final uploadFileCloudinaryResponseModel = uploadFileCloudinaryResponseModelFromJson(jsonString);

import 'dart:convert';

UploadFileCloudinaryResponseModel uploadFileCloudinaryResponseModelFromJson(String str) => UploadFileCloudinaryResponseModel.fromJson(json.decode(str));

String uploadFileCloudinaryResponseModelToJson(UploadFileCloudinaryResponseModel data) => json.encode(data.toJson());

class UploadFileCloudinaryResponseModel {
  String? assetId;
  String? publicId;
  int? version;
  String? versionId;
  String? signature;
  int? width;
  int? height;
  String? format;
  String? resourceType;
  DateTime? createdAt;
  List<dynamic>? tags;
  int? bytes;
  String? type;
  String? etag;
  bool? placeholder;
  String? url;
  String? secureUrl;
  String? folder;
  String? accessMode;
  String? originalFilename;

  UploadFileCloudinaryResponseModel({
    this.assetId,
    this.publicId,
    this.version,
    this.versionId,
    this.signature,
    this.width,
    this.height,
    this.format,
    this.resourceType,
    this.createdAt,
    this.tags,
    this.bytes,
    this.type,
    this.etag,
    this.placeholder,
    this.url,
    this.secureUrl,
    this.folder,
    this.accessMode,
    this.originalFilename,
  });

  UploadFileCloudinaryResponseModel copyWith({
    String? assetId,
    String? publicId,
    int? version,
    String? versionId,
    String? signature,
    int? width,
    int? height,
    String? format,
    String? resourceType,
    DateTime? createdAt,
    List<dynamic>? tags,
    int? bytes,
    String? type,
    String? etag,
    bool? placeholder,
    String? url,
    String? secureUrl,
    String? folder,
    String? accessMode,
    String? originalFilename,
  }) =>
      UploadFileCloudinaryResponseModel(
        assetId: assetId ?? this.assetId,
        publicId: publicId ?? this.publicId,
        version: version ?? this.version,
        versionId: versionId ?? this.versionId,
        signature: signature ?? this.signature,
        width: width ?? this.width,
        height: height ?? this.height,
        format: format ?? this.format,
        resourceType: resourceType ?? this.resourceType,
        createdAt: createdAt ?? this.createdAt,
        tags: tags ?? this.tags,
        bytes: bytes ?? this.bytes,
        type: type ?? this.type,
        etag: etag ?? this.etag,
        placeholder: placeholder ?? this.placeholder,
        url: url ?? this.url,
        secureUrl: secureUrl ?? this.secureUrl,
        folder: folder ?? this.folder,
        accessMode: accessMode ?? this.accessMode,
        originalFilename: originalFilename ?? this.originalFilename,
      );

  factory UploadFileCloudinaryResponseModel.fromJson(Map<String, dynamic> json) => UploadFileCloudinaryResponseModel(
    assetId: json["asset_id"],
    publicId: json["public_id"],
    version: json["version"],
    versionId: json["version_id"],
    signature: json["signature"],
    width: json["width"],
    height: json["height"],
    format: json["format"],
    resourceType: json["resource_type"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    tags: json["tags"] == null ? [] : List<dynamic>.from(json["tags"]!.map((x) => x)),
    bytes: json["bytes"],
    type: json["type"],
    etag: json["etag"],
    placeholder: json["placeholder"],
    url: json["url"],
    secureUrl: json["secure_url"],
    folder: json["folder"],
    accessMode: json["access_mode"],
    originalFilename: json["original_filename"],
  );

  Map<String, dynamic> toJson() => {
    "asset_id": assetId,
    "public_id": publicId,
    "version": version,
    "version_id": versionId,
    "signature": signature,
    "width": width,
    "height": height,
    "format": format,
    "resource_type": resourceType,
    "created_at": createdAt?.toIso8601String(),
    "tags": tags == null ? [] : List<dynamic>.from(tags!.map((x) => x)),
    "bytes": bytes,
    "type": type,
    "etag": etag,
    "placeholder": placeholder,
    "url": url,
    "secure_url": secureUrl,
    "folder": folder,
    "access_mode": accessMode,
    "original_filename": originalFilename,
  };
}
