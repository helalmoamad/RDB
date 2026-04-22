import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:rdb/core/domin/repositories/prefs_repository.dart';
import 'package:rdb/core/utils/extensions/build_context.dart';
import 'package:rdb/core/utils/form_state_mixin.dart';
import 'package:rdb/core/utils/form_utils.dart';
import 'package:rdb/features/authentication/presentation/widgets/pin_item.dart';
import 'package:rdb/routes/router.dart';
import 'package:rdb/theme/typography.dart';
import 'package:rdb/generated/locale_keys.g.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'dart:async';
import 'dart:ui' as ui;

enum PinCodeState { set, confirm, verify, done }

/// Progressive lockout durations (index = lockout level).
/// Level 0: 5 wrong attempts → 30 s
/// Level 1: 1 wrong attempt  → 1 min
/// Level 2: 1 wrong attempt  → 30 min
/// Level 3: 1 wrong attempt  → 1 h
/// Level 4: 1 wrong attempt  → 1 day
/// Level 5: 1 wrong attempt  → 1 week
/// Level 6+: 1 wrong attempt → 1 month
const List<Duration> _kLockoutDurations = [
  Duration(seconds: 30),
  Duration(minutes: 1),
  Duration(minutes: 30),
  Duration(hours: 1),
  Duration(days: 1),
  Duration(days: 7),
  Duration(days: 30),
];

const int _kMaxAttemptsBeforeFirstLock = 5;

class PinCodePage extends StatefulWidget {
  const PinCodePage({super.key});

  @override
  State<PinCodePage> createState() => _PinCodePageState();
}

class _PinCodePageState extends State<PinCodePage> with FormStateMinxin {
  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  final LocalAuthentication _localAuth = LocalAuthentication();
  late PinCodeState _state;
  String _firstPin = '';
  int codeStatus = 0; // 0: idle, 1: success, 2: error
  late final ValueNotifier<int> checkOtp;
  bool isExpired = false;
  bool _supportsFingerprint = false;
  bool _isAuthenticating = false;

  // ── Lockout state ──
  bool _isLockedOut = false;
  int _lockoutRemainingSeconds = 0;
  Timer? _lockoutTimer;

  @override
  void initState() {
    super.initState();
    checkOtp = ValueNotifier<int>(0);
    final storedPin = prefsRepository.passcode;
    if (storedPin == null || storedPin.isEmpty) {
      _state = PinCodeState.set;
    } else {
      _state = PinCodeState.verify;
    }
    _checkBiometricAvailability();
    _resumeLockoutIfActive();
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    super.dispose();
  }

  // ── Lockout helpers ──

  /// Returns the lockout duration for the given [level], capped at the max.
  Duration _durationForLevel(int level) {
    final idx = level.clamp(0, _kLockoutDurations.length - 1);
    return _kLockoutDurations[idx];
  }

  /// Formats remaining seconds into a human-readable countdown string.
  String _formatRemaining(int totalSeconds) {
    if (totalSeconds <= 0) return '0s';
    if (totalSeconds < 60) return '${totalSeconds}s';
    if (totalSeconds < 3600) {
      final m = totalSeconds ~/ 60;
      final s = totalSeconds % 60;
      return s > 0 ? '${m}m ${s}s' : '${m}m';
    }
    if (totalSeconds < 86400) {
      final h = totalSeconds ~/ 3600;
      final m = (totalSeconds % 3600) ~/ 60;
      return m > 0 ? '${h}h ${m}m' : '${h}h';
    }
    final d = totalSeconds ~/ 86400;
    final h = (totalSeconds % 86400) ~/ 3600;
    return h > 0 ? '${d}d ${h}h' : '${d}d';
  }

  /// Called on app start / resume: re-activates lockout if timer hasn't expired.
  void _resumeLockoutIfActive() {
    final lockoutUntilMs = prefsRepository.pinLockoutUntilMs;
    if (lockoutUntilMs <= 0) return;
    final remaining = lockoutUntilMs - DateTime.now().millisecondsSinceEpoch;
    if (remaining <= 0) {
      // Lock has expired while app was closed; clear stored timestamp only,
      // but keep level and failed attempts for escalation.
      prefsRepository.setPinLockoutUntilMs(0);
      return;
    }
    _startLockoutCountdown(remaining ~/ 1000);
  }

  /// Persists a new lockout at [level] and starts the UI countdown.
  Future<void> _applyLockout(int level) async {
    final duration = _durationForLevel(level);
    final untilMs =
        DateTime.now().millisecondsSinceEpoch + duration.inMilliseconds;
    await prefsRepository.setPinLockoutUntilMs(untilMs);
    await prefsRepository.setPinLockoutLevel(level + 1);
    await prefsRepository.setPinFailedAttempts(0);
    _startLockoutCountdown(duration.inSeconds);
  }

  /// Starts the visual countdown timer.
  void _startLockoutCountdown(int seconds) {
    _lockoutTimer?.cancel();
    setState(() {
      _isLockedOut = true;
      _lockoutRemainingSeconds = seconds;
    });
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _lockoutRemainingSeconds--;
      });
      if (_lockoutRemainingSeconds <= 0) {
        timer.cancel();
        prefsRepository.setPinLockoutUntilMs(0);
        setState(() {
          _isLockedOut = false;
        });
        _clearRotation();
      }
    });
  }

  /// Records a wrong attempt and applies lockout escalation when needed.
  Future<void> _recordWrongAttempt() async {
    final level = prefsRepository.pinLockoutLevel;

    if (level == 0) {
      // First lockout phase: count up to 5 attempts.
      final attempts = prefsRepository.pinFailedAttempts + 1;
      await prefsRepository.setPinFailedAttempts(attempts);
      if (attempts >= _kMaxAttemptsBeforeFirstLock) {
        await _applyLockout(0); // 30 s lockout
      }
    } else {
      // Every wrong attempt after the first lockout triggers escalation.
      await _applyLockout(level);
    }
  }

  /// Resets all lockout state on successful authentication.
  Future<void> _resetLockoutState() async {
    _lockoutTimer?.cancel();
    await prefsRepository.setPinFailedAttempts(0);
    await prefsRepository.setPinLockoutLevel(0);
    await prefsRepository.setPinLockoutUntilMs(0);
    if (mounted) setState(() => _isLockedOut = false);
  }

  // ── Biometric helpers ──

  Future<void> _checkBiometricAvailability() async {
    try {
      final bool canCheck = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      final List<BiometricType> availableBiometrics = await _localAuth
          .getAvailableBiometrics();
      final bool hasAnyAvailableBiometric = availableBiometrics.isNotEmpty;
      if (!mounted) return;
      setState(() {
        final bool canUseBiometric =
            _state == PinCodeState.verify && canCheck && isDeviceSupported;
        _supportsFingerprint = canUseBiometric && hasAnyAvailableBiometric;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _supportsFingerprint = false);
    }
  }

  Future<void> _authenticateWithBiometric({required bool isFace}) async {
    if (_isAuthenticating) return;
    if (!isFace && !_supportsFingerprint) return;

    setState(() => _isAuthenticating = true);
    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: LocaleKeys.information_securely.tr(),
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      if (!mounted) return;
      if (didAuthenticate) {
        await _resetLockoutState();
        prefsRepository.setShouldShowPin(false);
        // ignore: use_build_context_synchronously
        context.go(GRouter.config.applicationRoutes.kBasePage);
      }
    } on PlatformException catch (e) {
      if (e.code == auth_error.notAvailable ||
          e.code == auth_error.notEnrolled ||
          e.code == auth_error.passcodeNotSet) {
        if (!mounted) return;
        setState(() => _supportsFingerprint = false);
      }
    } catch (_) {
      // Ignore transient auth errors.
    } finally {
      // ignore: control_flow_in_finally
      if (!mounted) return;
      setState(() => _isAuthenticating = false);
    }
  }

  // ── PIN helpers ──

  void _onPinChanged() => setState(() => codeStatus = 0);

  void _clearRotation() {
    for (var controller in form.controllers) {
      controller.text = '\u200b';
    }
    resetPinGlobalState();
  }

  String _getEnteredPin() =>
      form.controllers.map((c) => c.text.replaceAll('\u200b', '')).join();

  void _handlePinComplete() async {
    if (_isLockedOut) return;
    final inputPin = _getEnteredPin();
    if (inputPin.length < numberOfFields) return;

    switch (_state) {
      case PinCodeState.set:
        setState(() {
          _firstPin = inputPin;
          _state = PinCodeState.confirm;
          codeStatus = 0;
          _clearRotation();
        });
        break;

      case PinCodeState.confirm:
        if (inputPin == _firstPin) {
          await prefsRepository.setPasscode(inputPin);
          setState(() {
            _state = PinCodeState.done;
            codeStatus = 1;
          });
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              prefsRepository.setShouldShowPin(false);
              context.go(GRouter.config.applicationRoutes.kBasePage);
            }
          });
        } else {
          setState(() => codeStatus = 2);
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                _state = PinCodeState.set;
                _firstPin = '';
                codeStatus = 0;
                _clearRotation();
              });
            }
          });
        }
        break;

      case PinCodeState.verify:
        if (inputPin == prefsRepository.passcode) {
          await _resetLockoutState();
          setState(() => codeStatus = 1);
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              prefsRepository.setShouldShowPin(false);
              context.go(GRouter.config.applicationRoutes.kBasePage);
            }
          });
        } else {
          setState(() => codeStatus = 2);
          await _recordWrongAttempt();
          if (!_isLockedOut) {
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                setState(() {
                  codeStatus = 0;
                  _clearRotation();
                });
              }
            });
          } else {
            // Clear error state immediately when transitioning to lockout screen.
            Future.delayed(const Duration(milliseconds: 400), () {
              if (mounted) setState(() => codeStatus = 0);
            });
          }
        }
        break;

      case PinCodeState.done:
        break;
    }
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    if (_isLockedOut) return _buildLockoutScreen(context);

    String title = '';
    String subtitle = LocaleKeys.last_step.tr();
    String label = '';

    switch (_state) {
      case PinCodeState.set:
        title = LocaleKeys.set_passcode.tr();
        label = LocaleKeys.set_passcode.tr();
        break;
      case PinCodeState.confirm:
        title = LocaleKeys.set_passcode.tr();
        label = codeStatus == 2
            ? LocaleKeys.passcode_mismatch_restart.tr()
            : LocaleKeys.reenter_passcode.tr();
        break;
      case PinCodeState.verify:
        title = LocaleKeys.enter_passcode.tr();
        label = LocaleKeys.enter_passcode.tr();
        break;
      case PinCodeState.done:
        title = LocaleKeys.set_passcode_done.tr();
        label = LocaleKeys.set_passcode.tr();
        break;
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xffF4FFF4),
      body: PopScope(
        canPop: _state == PinCodeState.set,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (_state == PinCodeState.confirm) {
            setState(() {
              _state = PinCodeState.set;
              _firstPin = '';
              codeStatus = 0;
              _clearRotation();
            });
          }
        },
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.only(
              left: 20.h,
              right: 20.h,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 288.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.h),
                  child: Text(
                    title,
                    style: context.textTheme.titleLarge?.bq.copyWith(
                      color: const Color(0xff1D1D1D),
                      height: 1.42,
                      fontSize: 30.sp,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.h),
                  child: Text(
                    subtitle,
                    style: context.textTheme.titleLarge?.mq.copyWith(
                      color: const Color(0xff1D1D1D),
                      height: 1.42,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
                SizedBox(height: 130.h),
                _buildPinSlot(),
                SizedBox(height: 10.h),
                Center(
                  child: Text(
                    label,
                    style: context.textTheme.titleLarge?.bq.copyWith(
                      fontSize: 14.sp,
                      color: Colors.black45,
                    ),
                  ),
                ),
                10.verticalSpace,
                if (_supportsFingerprint)
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: _isAuthenticating
                              ? null
                              : () => _authenticateWithBiometric(isFace: false),
                          tooltip: LocaleKeys.fingerprint_login_tooltip.tr(),
                          iconSize: 40.sp,
                          color: const Color(0xff4D84FF),
                          icon: const Icon(Icons.fingerprint_rounded),
                        ),
                      ],
                    ),
                  ),
                if (_isAuthenticating)
                  Center(
                    child: SizedBox(
                      width: 22.w,
                      height: 22.w,
                      child: const CircularProgressIndicator(strokeWidth: 2.0),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Lockout screen — shown instead of the normal PIN UI while locked out.
  Widget _buildLockoutScreen(BuildContext context) {
    final remaining = _formatRemaining(_lockoutRemainingSeconds);
    return Scaffold(
      backgroundColor: const Color(0xffF4FFF4),
      body: PopScope(
        canPop: false,
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  LocaleKeys.pin_lockout_too_many_attempts.tr(),
                  textAlign: TextAlign.center,
                  style: context.textTheme.titleLarge?.bq.copyWith(
                    color: const Color(0xff1D1D1D),
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12.h),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                      fontSize: 14.sp,
                    ),
                    children: [
                      TextSpan(
                        text: '${LocaleKeys.pin_lockout_try_again_in.tr()} ',
                      ),
                      TextSpan(
                        text: remaining,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xff1D1D1D),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPinSlot() {
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: SizedBox(
        height: 60.w,
        width: double.infinity,
        child: Row(
          textDirection: ui.TextDirection.ltr,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            PinItem(
              key: const Key('otp_item_1'),
              borderColor: codeStatus == 1
                  ? const Color(0xff78D97F)
                  : codeStatus == 2
                  ? const Color(0xffFF5F61)
                  : const Color(0xff4D84FF),
              isExpired: isExpired,
              contentColor: codeStatus == 1
                  ? const Color(0xffF4FFF4)
                  : codeStatus == 2
                  ? const Color(0xffFDF5F5)
                  : const Color(0xffFAFAFA),
              controller: form.controllers[0],
              wrongCode: codeStatus == 2,
              fromPasscose: true,
              verfySucessful: codeStatus == 1,
              index: 0,
              pasteOtpCode: pasteOtpCode,
              onChange: _onPinChanged,
              autoFocus: true,
            ),
            PinItem(
              key: const Key('otp_item_2'),
              borderColor: codeStatus == 1
                  ? const Color(0xff78D97F)
                  : codeStatus == 2
                  ? const Color(0xffFF5F61)
                  : const Color(0xff4D84FF),
              verfySucessful: codeStatus == 1,
              contentColor: codeStatus == 1
                  ? const Color(0xffF4FFF4)
                  : codeStatus == 2
                  ? const Color(0xffFDF5F5)
                  : const Color(0xffFAFAFA),
              fromPasscose: true,
              isExpired: isExpired,
              controller: form.controllers[1],
              wrongCode: codeStatus == 2,
              index: 1,
              onChange: _onPinChanged,
              autoFocus: false,
            ),
            PinItem(
              key: const Key('otp_item_3'),
              borderColor: codeStatus == 1
                  ? const Color(0xff78D97F)
                  : codeStatus == 2
                  ? const Color(0xffFF5F61)
                  : const Color(0xff4D84FF),
              verfySucessful: codeStatus == 1,
              fromPasscose: true,
              isExpired: isExpired,
              contentColor: codeStatus == 1
                  ? const Color(0xffF4FFF4)
                  : codeStatus == 2
                  ? const Color(0xffFDF5F5)
                  : const Color(0xffFAFAFA),
              index: 2,
              wrongCode: codeStatus == 2,
              onChange: _onPinChanged,
              controller: form.controllers[2],
              autoFocus: false,
            ),
            PinItem(
              key: const Key('otp_item_4'),
              borderColor: codeStatus == 1
                  ? const Color(0xff78D97F)
                  : codeStatus == 2
                  ? const Color(0xffFF5F61)
                  : const Color(0xff4D84FF),
              verfySucessful: codeStatus == 1,
              fromPasscose: true,
              isExpired: isExpired,
              contentColor: codeStatus == 1
                  ? const Color(0xffF4FFF4)
                  : codeStatus == 2
                  ? const Color(0xffFDF5F5)
                  : const Color(0xffFAFAFA),
              index: 3,
              wrongCode: codeStatus == 2,
              onChange: _onPinChanged,
              controller: form.controllers[3],
              autoFocus: false,
            ),
            PinItem(
              key: const Key('otp_item_5'),
              borderColor: codeStatus == 1
                  ? const Color(0xff78D97F)
                  : codeStatus == 2
                  ? const Color(0xffFF5F61)
                  : const Color(0xff4D84FF),
              verfySucessful: codeStatus == 1,
              fromPasscose: true,
              contentColor: codeStatus == 1
                  ? const Color(0xffF4FFF4)
                  : codeStatus == 2
                  ? const Color(0xffFDF5F5)
                  : const Color(0xffFAFAFA),
              isExpired: isExpired,
              index: 4,
              wrongCode: codeStatus == 2,
              onChange: _onPinChanged,
              controller: form.controllers[4],
              autoFocus: false,
            ),
            PinItem(
              key: const Key('otp_item_6'),
              borderColor: codeStatus == 1
                  ? const Color(0xff78D97F)
                  : codeStatus == 2
                  ? const Color(0xffFF5F61)
                  : const Color(0xff4D84FF),
              verfySucessful: codeStatus == 1,
              fromPasscose: true,
              isExpired: isExpired,
              contentColor: codeStatus == 1
                  ? const Color(0xffF4FFF4)
                  : codeStatus == 2
                  ? const Color(0xffFDF5F5)
                  : const Color(0xffFAFAFA),
              index: 5,
              wrongCode: codeStatus == 2,
              onChange: _onPinChanged,
              checkOtp: _handlePinComplete,
              controller: form.controllers[5],
              autoFocus: false,
            ),
          ],
        ),
      ),
    );
  }

  void pasteOtpCode(String text) {
    if (text.length != 6) return;
    for (int i = 0; i < 6; i++) {
      form.controllers[i].text = text[i];
    }
    _handlePinComplete();
  }

  @override
  int get numberOfFields => 6;
}
