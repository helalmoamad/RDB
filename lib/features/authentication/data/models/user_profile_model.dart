class UserProfileModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String userType;
  final String? profilePictureURL;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final bool isBlocked;
  final bool isTwoFactorEnabled;
  final String language;
  final String? address;
  final String createdAt;
  final String updatedAt;
  final KycVerification kycVerification;

  UserProfileModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.userType,
    required this.profilePictureURL,
    required this.isEmailVerified,
    required this.isPhoneVerified,
    required this.isBlocked,
    required this.isTwoFactorEnabled,
    required this.language,
    required this.address,
    required this.createdAt,
    required this.updatedAt,
    required this.kycVerification,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] ?? json['_id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      userType: json['userType'] ?? '',
      profilePictureURL:
          json['profilePictureURL'] ?? json['profilePictureUrl'] ?? '',
      isEmailVerified: json['isEmailVerified'] ?? false,
      isPhoneVerified: json['isPhoneVerified'] ?? false,
      isBlocked: json['isBlocked'] ?? false,
      isTwoFactorEnabled: json['isTwoFactorEnabled'] ?? false,
      language: json['language'] ?? '',
      address: json['address'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      kycVerification: KycVerification.fromJson(
        json['kycVerification'] as Map<String, dynamic>?,
      ),
    );
  }
}

/// حالة توثيق الهوية (KYC) القادمة من الباك.
/// مثال: {status: not_submitted, statusLabel: Not Submitted,
///        expiresAt: null, rejectionReason: null}
class KycVerification {
  final String status;
  final String statusLabel;
  final String? expiresAt;
  final String? rejectionReason;

  const KycVerification({
    required this.status,
    required this.statusLabel,
    this.expiresAt,
    this.rejectionReason,
  });

  /// true فقط عندما تكون الهوية موثّقة فعلياً.
  bool get isVerified => status.toLowerCase() == 'verified';

  factory KycVerification.fromJson(Map<String, dynamic>? json) {
    final map = json ?? const {};
    return KycVerification(
      status: map['status'] as String? ?? 'not_submitted',
      statusLabel: map['statusLabel'] as String? ?? 'Not Submitted',
      expiresAt: map['expiresAt'] as String?,
      rejectionReason: map['rejectionReason'] as String?,
    );
  }
}
