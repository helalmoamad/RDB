class PasskeyModel {
  final String? id;
  final String? credentialId;
  final String? deviceName;
  final DateTime? createdAt;
  final DateTime? lastUsedAt;

  PasskeyModel({
    this.id,
    this.credentialId,
    this.deviceName,
    this.createdAt,
    this.lastUsedAt,
  });

  factory PasskeyModel.fromJson(Map<String, dynamic> json) => PasskeyModel(
    id: json["_id"],
    credentialId: json["credentialId"],
    deviceName: json["deviceName"],
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"] as String),
    lastUsedAt: json["lastUsedAt"] == null
        ? null
        : DateTime.parse(json["lastUsedAt"] as String),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "credentialId": credentialId,
    "deviceName": deviceName,
    "createdAt": createdAt?.toIso8601String(),
    "lastUsedAt": lastUsedAt?.toIso8601String(),
  };
}
