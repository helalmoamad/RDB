enum VerifyOtpSessionStatus {
  authenticated('authenticated'),
  existingUser('existing_user'),
  newUser('new_user'),
  requiresPasscode('requires_passcode'),
  requiresApproval('requires_approval'),
  unknown('unknown');

  final String value;
  const VerifyOtpSessionStatus(this.value);

  static VerifyOtpSessionStatus fromString(String? status) {
    switch (status) {
      case 'authenticated':
        return VerifyOtpSessionStatus.authenticated;
      case 'existing_user':
        return VerifyOtpSessionStatus.existingUser;
      case 'new_user':
        return VerifyOtpSessionStatus.newUser;
      case 'requires_passcode':
        return VerifyOtpSessionStatus.requiresPasscode;
      case 'requires_approval':
        return VerifyOtpSessionStatus.requiresApproval;
      default:
        return VerifyOtpSessionStatus.unknown;
    }
  }
}
