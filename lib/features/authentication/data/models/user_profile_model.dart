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
    );
  }
}
