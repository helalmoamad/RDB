import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:rdb/features/authentication/data/models/reset_passcode_models.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repositories/auth_repository.dart';

// ───────────── معاملات ─────────────

/// معاملات تعتمد فقط على نقطة الدخول (init / questions).
class ResetEntryParams {
  ResetEntryParams({required this.midLogin});
  final bool midLogin;
}

class ResetSendOtpParams {
  ResetSendOtpParams({required this.phoneNumber, required this.channel});
  final String phoneNumber; // يبدأ بـ +
  final String channel; // "sms" | "whatsapp"

  Map<String, dynamic> get map => {
    'phoneNumber': phoneNumber,
    'channel': channel,
  };
}

class ResetVerifyOtpParams {
  ResetVerifyOtpParams({required this.phoneNumber, required this.otpCode});
  final String phoneNumber;
  final String otpCode;

  Map<String, dynamic> get map => {
    'phoneNumber': phoneNumber,
    'otpCode': otpCode,
  };
}

class ResetAnswersParams {
  ResetAnswersParams({required this.answers, required this.midLogin});

  /// قائمة {questionId, optionId}.
  final List<Map<String, String>> answers;
  final bool midLogin;

  Map<String, dynamic> get map => {'answers': answers};
}

class ResetCompleteParams {
  ResetCompleteParams({
    required this.passcode,
    required this.midLogin,
    this.resetToken,
  });
  final String passcode; // 4-6 أرقام
  final String? resetToken;
  final bool midLogin;

  Map<String, dynamic> get map => {
    'passcode': passcode,
    if (resetToken != null) 'resetToken': resetToken,
  };
}

// ───────────── حالات الاستخدام ─────────────

@injectable
class ResetInitUseCase implements UseCase<ResetInitResponse, ResetEntryParams> {
  ResetInitUseCase(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, ResetInitResponse>> call(ResetEntryParams params) =>
      repository.resetPasscodeInit(midLogin: params.midLogin);
}

@injectable
class ResetSendOtpUseCase
    implements UseCase<ResetSendOtpResponse, ResetSendOtpParams> {
  ResetSendOtpUseCase(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, ResetSendOtpResponse>> call(
    ResetSendOtpParams params,
  ) => repository.resetPasscodeSendOtp(params.map);
}

@injectable
class ResetVerifyOtpUseCase
    implements UseCase<ResetVerifyOtpResponse, ResetVerifyOtpParams> {
  ResetVerifyOtpUseCase(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, ResetVerifyOtpResponse>> call(
    ResetVerifyOtpParams params,
  ) => repository.resetPasscodeVerifyOtp(params.map);
}

@injectable
class ResetQuestionsUseCase
    implements UseCase<ResetQuestionsResponse, ResetEntryParams> {
  ResetQuestionsUseCase(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, ResetQuestionsResponse>> call(
    ResetEntryParams params,
  ) => repository.resetPasscodeQuestions(midLogin: params.midLogin);
}

@injectable
class ResetAnswersUseCase
    implements UseCase<ResetAnswersResponse, ResetAnswersParams> {
  ResetAnswersUseCase(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, ResetAnswersResponse>> call(
    ResetAnswersParams params,
  ) => repository.resetPasscodeAnswers(params.map, midLogin: params.midLogin);
}

@injectable
class ResetCompleteUseCase
    implements UseCase<ResetCompleteResponse, ResetCompleteParams> {
  ResetCompleteUseCase(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, ResetCompleteResponse>> call(
    ResetCompleteParams params,
  ) => repository.resetPasscodeComplete(params.map, midLogin: params.midLogin);
}

@injectable
class ReverifyFaceStartUseCase
    implements UseCase<ReverifyStartResponse, String> {
  ReverifyFaceStartUseCase(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, ReverifyStartResponse>> call(String challengeId) =>
      repository.reverifyFaceStart(challengeId);
}

/// معاملات التحقّق بالوجه (step-up): challengeId من init + صورة وجه مباشرة +
/// sessionId العائد من start.
class ReverifyFaceParams {
  ReverifyFaceParams({
    required this.challengeId,
    required this.liveFaceImageData,
    this.sessionId,
  });
  final String challengeId;
  final String liveFaceImageData; // data:image/jpeg;base64,...
  final String? sessionId;
}

@injectable
class ReverifyFaceVerifyUseCase
    implements UseCase<ReverifyVerifyResponse, ReverifyFaceParams> {
  ReverifyFaceVerifyUseCase(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, ReverifyVerifyResponse>> call(
    ReverifyFaceParams params,
  ) => repository.reverifyFaceVerify(
    challengeId: params.challengeId,
    liveFaceImageData: params.liveFaceImageData,
    sessionId: params.sessionId,
  );
}
