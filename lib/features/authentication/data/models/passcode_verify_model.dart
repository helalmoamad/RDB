class PasscodeVerifyModel {
  final String status;
  final String sessionId;
  final String sessionToken;

  PasscodeVerifyModel({
    required this.status,
    required this.sessionId,
    required this.sessionToken,
  });

  factory PasscodeVerifyModel.fromJson(Map<String, dynamic> json) {
    return PasscodeVerifyModel(
      status: json['status'] ?? '',
      sessionId: json['sessionId'] ?? '',
      sessionToken: json['sessionToken'] ?? '',
    );
  }
}
