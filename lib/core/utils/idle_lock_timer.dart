import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:rdb/core/domin/repositories/prefs_repository.dart';
import 'package:rdb/core/utils/app_lock_overlay.dart';

/// ⏱️ مؤقّت الخمول: يقفل التطبيق برمز المرور بعد [kIdleLockTimeout] من **عدم
/// تفاعل المستخدم مع الشاشة**.
///
/// كان القفل يحدث سابقاً عند الخروج للخلفية فقط
/// ([AppLifecycleManager]) أو عند عودة الإنترنت. هذا المؤقّت يغطّي الحالة
/// الثالثة: التطبيق مفتوح في المقدّمة والمستخدم تركه دون لمس.
///
/// **لا يملك منطق قفل خاصاً به**: يعيد استخدام
/// [AppLockController.showLock] تماماً كما تفعل بقيّة نقاط القفل، فيظهر نفس
/// الـ route فوق الـ root navigator ويغطّي جميع الشاشات.
///
/// شروط العمل (نفس شروط `AppLockController._canShowGate`):
///  - جلسة قائمة (`walletToken` غير فارغ) — فلا يظهر قبل تسجيل الدخول.
///  - رمز مرور مضبوط (`passcode` غير فارغ) — فلا يظهر على صفحة تعيين الرمز.
///
/// يتوقّف المؤقّت تلقائياً بينما القفل/شاشة التبديل معروضة، وأثناء وجود
/// التطبيق في الخلفية (القفل عند العودة يتكفّل به [AppLifecycleManager])،
/// ويُستأنف عند فكّ القفل أو العودة للمقدّمة.
const Duration kIdleLockTimeout = Duration(minutes: 6);

class IdleLockTimer {
  IdleLockTimer._();
  static final IdleLockTimer instance = IdleLockTimer._();

  Timer? _timer;
  DateTime? _lastActivityAt;
  bool _started = false;

  // ── دورة الحياة ──

  /// يبدأ المراقبة (تُستدعى مرّة واحدة من جذر التطبيق).
  void start() {
    if (_started) return;
    _started = true;
    // فكّ القفل يعيد تشغيل العدّاد، وإظهاره يوقفه — بلا حاجة لتعديل
    // AppLockController نفسه.
    AppLockController.instance.isPasscodeVerified.addListener(_onGateChanged);
    AppLockController.instance.isShowSwitch.addListener(_onGateChanged);
    reportActivity();
  }

  void stop() {
    if (!_started) return;
    _started = false;
    AppLockController.instance.isPasscodeVerified.removeListener(_onGateChanged);
    AppLockController.instance.isShowSwitch.removeListener(_onGateChanged);
    _cancel();
    _lastActivityAt = null;
  }

  /// يُستدعى من الـ `Listener` على جذر التطبيق عند كل لمسة/سحب.
  ///
  /// رخيص عمداً: يسجّل الوقت فقط ولا يُعيد إنشاء المؤقّت في كل حدث (أحداث
  /// السحب تصل بمعدّل الإطارات). المؤقّت نفسه يُعيد جدولة المتبقّي عند إطلاقه.
  void reportActivity() {
    _lastActivityAt = DateTime.now();
    if (_timer == null) _schedule(kIdleLockTimeout);
  }

  /// يوقف العدّ في الخلفية ويستأنفه عند العودة للمقدّمة.
  void handleLifecycleChange(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      reportActivity();
    } else {
      _cancel();
    }
  }

  // ── التفاصيل ──

  void _onGateChanged() {
    if (_isGateVisible) {
      _cancel();
    } else {
      reportActivity();
    }
  }

  /// هل الجلسة مؤهّلة أصلاً للقفل؟ (نفس شرط `AppLockController._canShowGate`)
  bool get _isEligible {
    if (!GetIt.I.isRegistered<PrefsRepository>()) return false;
    final prefs = GetIt.I<PrefsRepository>();
    return (prefs.walletToken ?? '').isNotEmpty &&
        (prefs.passcode ?? '').isNotEmpty;
  }

  /// القفل أو شاشة التبديل معروضة الآن → لا معنى للعدّ.
  bool get _isGateVisible =>
      !AppLockController.instance.isPasscodeVerified.value ||
      AppLockController.instance.isShowSwitch.value;

  void _schedule(Duration duration) {
    _timer?.cancel();
    _timer = Timer(duration, _onElapsed);
  }

  void _cancel() {
    _timer?.cancel();
    _timer = null;
  }

  void _onElapsed() {
    _timer = null;
    if (!_started || !_isEligible || _isGateVisible) return;

    final lastActivityAt = _lastActivityAt;
    if (lastActivityAt != null) {
      final remaining =
          kIdleLockTimeout - DateTime.now().difference(lastActivityAt);
      // وصل تفاعل بعد جدولة المؤقّت → أكمل ما تبقّى بدل القفل الآن.
      if (remaining > Duration.zero) {
        _schedule(remaining);
        return;
      }
    }

    _lock();
  }

  void _lock() {
    // نفس نداءَي القفل المستخدمين في `TrydosApplication._lockWithPasscodeIfSet`
    // و`HomePage`: تثبيت الحالة في التخزين ثم دفع طبقة الحماية.
    GetIt.I<PrefsRepository>().setShouldShowPin(true);
    AppLockController.instance.showLock();
  }
}
