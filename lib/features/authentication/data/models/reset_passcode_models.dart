// نماذج استجابات endpoints إعادة تعيين رمز المرور (مطابقة لدليل الباك).
// كل الاستجابات الناجحة HTTP 200 وتُقرأ من ظرف JSON (لا من رمز الحالة).

/// قفل بسبب محاولات خاطئة سابقة.
class ResetLockout {
  const ResetLockout({this.lockedUntil, this.lockoutHours});

  /// وقت انتهاء القفل (ISO8601).
  final String? lockedUntil;

  /// عدد ساعات القفل (5 / 12 / 24...). الدليل يسمّيه nextLockoutHours في init
  /// و lockoutHours في answers — نقبل كليهما.
  final int? lockoutHours;

  factory ResetLockout.fromJson(Map<String, dynamic> json) => ResetLockout(
    lockedUntil: json['lockedUntil'] as String?,
    lockoutHours: (json['nextLockoutHours'] ?? json['lockoutHours']) as int?,
  );
}

/// طلب الوجه (للموثّقين على مجموعة idle-lock فقط).
class ResetStepUp {
  const ResetStepUp({this.method, this.challengeId, this.reason});

  final String? method; // "face"
  final String? challengeId;
  final String? reason;

  factory ResetStepUp.fromJson(Map<String, dynamic> json) => ResetStepUp(
    method: json['method'] as String?,
    challengeId: json['challengeId'] as String?,
    reason: json['reason'] as String?,
  );
}

/// استجابة `init` — ثلاث حالات: مقفول / موثّق (وجه) / غير موثّق (أسئلة).
class ResetInitResponse {
  const ResetInitResponse({
    required this.isVerified,
    this.lockout,
    this.stepUp,
  });

  final bool isVerified;
  final ResetLockout? lockout;
  final ResetStepUp? stepUp;

  bool get isLocked => lockout != null;
  bool get needsFace => stepUp?.method == 'face';

  factory ResetInitResponse.fromJson(Map<String, dynamic> json) =>
      ResetInitResponse(
        isVerified: (json['isVerified'] as bool?) ?? false,
        lockout: json['lockout'] != null
            ? ResetLockout.fromJson(json['lockout'] as Map<String, dynamic>)
            : null,
        stepUp: json['stepUp'] != null
            ? ResetStepUp.fromJson(json['stepUp'] as Map<String, dynamic>)
            : null,
      );
}

/// استجابة `send-otp` (idle-lock فقط).
class ResetSendOtpResponse {
  const ResetSendOtpResponse({required this.ok, this.sessionInfo, this.error});

  final bool ok;
  final String? sessionInfo;
  final String? error;

  factory ResetSendOtpResponse.fromJson(Map<String, dynamic> json) =>
      ResetSendOtpResponse(
        ok: (json['ok'] as bool?) ?? false,
        sessionInfo: json['sessionInfo'] as String?,
        error: json['error'] as String?,
      );
}

/// استجابة `verify-otp` (idle-lock فقط).
class ResetVerifyOtpResponse {
  const ResetVerifyOtpResponse({required this.ok, this.error});

  final bool ok;
  final String? error;

  factory ResetVerifyOtpResponse.fromJson(Map<String, dynamic> json) =>
      ResetVerifyOtpResponse(
        ok: (json['ok'] as bool?) ?? false,
        error: json['error'] as String?,
      );
}

/// خيار إجابة قادم من الباك.
class ResetQuestionOption {
  const ResetQuestionOption({required this.id, required this.label});

  final String id;
  final String label;

  factory ResetQuestionOption.fromJson(Map<String, dynamic> json) =>
      ResetQuestionOption(
        id: json['id'] as String? ?? '',
        label: json['label'] as String? ?? '',
      );
}

/// سؤال قادم من الباك (النصّ والخيارات يأتيان من السيرفر).
class ResetQuestion {
  const ResetQuestion({
    required this.id,
    required this.text,
    required this.options,
  });

  final String id;
  final String text;
  final List<ResetQuestionOption> options;

  factory ResetQuestion.fromJson(Map<String, dynamic> json) => ResetQuestion(
    id: json['id'] as String? ?? '',
    text: json['text'] as String? ?? '',
    options: ((json['options'] as List<dynamic>?) ?? [])
        .map((e) => ResetQuestionOption.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

/// استجابة `GET questions`.
class ResetQuestionsResponse {
  const ResetQuestionsResponse({
    required this.questions,
    this.attemptsRemaining,
  });

  final List<ResetQuestion> questions;
  final int? attemptsRemaining;

  factory ResetQuestionsResponse.fromJson(Map<String, dynamic> json) =>
      ResetQuestionsResponse(
        questions: ((json['questions'] as List<dynamic>?) ?? [])
            .map((e) => ResetQuestion.fromJson(e as Map<String, dynamic>))
            .toList(),
        attemptsRemaining: json['attemptsRemaining'] as int?,
      );
}

/// استجابة `answers` — نجاح(+resetToken) / خطأ(+attemptsRemaining) / قفل.
class ResetAnswersResponse {
  const ResetAnswersResponse({
    required this.success,
    this.attemptsRemaining,
    this.resetToken,
    this.lockedUntil,
    this.lockoutHours,
  });

  final bool success;
  final int? attemptsRemaining;
  final String? resetToken;
  final String? lockedUntil;
  final int? lockoutHours;

  bool get isLocked => lockedUntil != null;

  factory ResetAnswersResponse.fromJson(Map<String, dynamic> json) =>
      ResetAnswersResponse(
        success: (json['success'] as bool?) ?? false,
        attemptsRemaining: json['attemptsRemaining'] as int?,
        resetToken: json['resetToken'] as String?,
        lockedUntil: json['lockedUntil'] as String?,
        lockoutHours: json['lockoutHours'] as int?,
      );
}

/// استجابة `complete`.
class ResetCompleteResponse {
  const ResetCompleteResponse({required this.success});

  final bool success;

  factory ResetCompleteResponse.fromJson(Map<String, dynamic> json) =>
      ResetCompleteResponse(success: (json['success'] as bool?) ?? false);
}
