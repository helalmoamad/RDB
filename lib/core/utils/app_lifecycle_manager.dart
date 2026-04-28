import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:rdb/core/domin/repositories/prefs_repository.dart';
import 'package:rdb/routes/router.dart';

/// 🔄 مدير حالة التطبيق - لمنع الشاشة السوداء عند العودة من الخلفية
class AppLifecycleManager {
  static final AppLifecycleManager _instance = AppLifecycleManager._internal();
  factory AppLifecycleManager() => _instance;
  AppLifecycleManager._internal();

  /// 📊 حالة التطبيق الحالية
  AppLifecycleState? _currentState;
  AppLifecycleState? get currentState => _currentState;

  /// 🔒 هل يجب طلب الـ PIN عند العودة؟
  bool _shouldRequestPin = false;

  /// ⏱️ وقت آخر مرة كان التطبيق نشطاً
  DateTime? _lastActiveTime;
  DateTime? get lastActiveTime => _lastActiveTime;

  /// 🔄 معالجة تغيير حالة التطبيق
  void handleLifecycleChange(AppLifecycleState state) {
    final previousState = _currentState;
    _currentState = state;

    debugPrint('🔄 App Lifecycle: $previousState → $state');

    switch (state) {
      case AppLifecycleState.resumed:
        _handleResumed(previousState);
        break;
      case AppLifecycleState.paused:
        _handlePaused();
        break;
      case AppLifecycleState.inactive:
        _handleInactive();
        break;
      case AppLifecycleState.detached:
        _handleDetached();
        break;
      case AppLifecycleState.hidden:
        _handleHidden();
        break;
    }
  }

  /// ✅ معالجة عودة التطبيق للواجهة
  void _handleResumed(AppLifecycleState? previousState) {
    debugPrint('✅ App Resumed');

    final prefs = GetIt.I<PrefsRepository>();
    final persistentShouldShowPin = prefs.shouldShowPin ?? false;

    // حساب المدة في الخلفية
    if (_lastActiveTime != null) {
      final duration = DateTime.now().difference(_lastActiveTime!);
      debugPrint('⏱️ App was in background for: ${duration.inSeconds} seconds');

      // إذا كان التطبيق في الخلفية لأكثر من 5 دقائق
      if (duration.inMinutes > 5) {
        debugPrint('⚠️ App was in background for long time - may need refresh');
        _handleLongBackgroundReturn();
      }
    }

    _lastActiveTime = DateTime.now();

    // ✅ استعادة واجهة النظام دائماً (حتى في الحالات القصيرة)
    _restoreSystemUI();

    // 🔒 طلب رمز PIN إذا كان مفعلاً وكان التطبيق في الخلفية
    if (_shouldRequestPin || persistentShouldShowPin) {
      _requestPinIfNecessary();
      _shouldRequestPin = false;
      // لا نقوم بمسح persistentShouldShowPin هنا، بل نقوم بمسحه عند نجاح إدخال الرمز في صفحة الـ PIN
    }
  }

  /// 🔒 التحقق من ضرورة طلب رمز PIN
  void _requestPinIfNecessary() {
    try {
      final prefs = GetIt.I<PrefsRepository>();
      final isLoggedIn =
          prefs.walletToken != null &&
          ((prefs.isVerifiedPhone ?? false) ||
              (prefs.isVerifiedPhonePeforeExpiredToken ?? false));
      final hasStoredName = (prefs.userName ?? '').trim().isNotEmpty;

      if (isLoggedIn) {
        // التحقق من أننا لسنا بالفعل في صفحة PIN لتجنب التكرار
        final currentRoute = GRouter
            .router
            .routerDelegate
            .currentConfiguration
            .last
            .matchedLocation;
        final targetRoute = hasStoredName
            ? GRouter.config.applicationRoutes.kPinCodePage
            : GRouter.config.applicationRoutes.kEnterNamePage;
        if (currentRoute != targetRoute) {
          debugPrint('🔒 Security: Requesting secure auth step on app resume');
          GRouter.router.push(targetRoute);
        } else {
          debugPrint('ℹ️ Security: User already on auth step page');
        }
      }
    } catch (e) {
      debugPrint('❌ Error requesting PIN: $e');
    }
  }

  /// ⏸️ معالجة دخول التطبيق للخلفية
  void _handlePaused() {
    debugPrint('⏸️ App Paused');
    _lastActiveTime = DateTime.now();
    _shouldRequestPin = true;

    // حفظ الحالة في التخزين الدائم لضمان طلب الرموز حتى لو تم إغلاق التطبيق من قبل النظام
    GetIt.I<PrefsRepository>().setShouldShowPin(true);
  }

  /// 🔄 معالجة حالة غير نشط
  void _handleInactive() {
    debugPrint('🔄 App Inactive');
  }

  /// 🔌 معالجة انفصال التطبيق
  void _handleDetached() {
    debugPrint('🔌 App Detached');
  }

  /// 👁️ معالجة إخفاء التطبيق
  void _handleHidden() {
    debugPrint('👁️ App Hidden');
  }

  /// 🔄 معالجة العودة بعد فترة طويلة في الخلفية
  void _handleLongBackgroundReturn() {
    debugPrint('🔄 Handling long background return');

    // يمكن إضافة منطق هنا مثل:
    // - إعادة تحميل البيانات
    // - تحديث الـ tokens
    // - إعادة الاتصال بالخوادم
  }

  /// 🎨 استعادة إعدادات واجهة النظام
  void _restoreSystemUI() {
    try {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
        ),
      );
      debugPrint('✅ System UI restored');
    } catch (e) {
      debugPrint('❌ Error restoring system UI: $e');
    }
  }

  /// 📊 الحصول على معلومات حالة التطبيق
  Map<String, dynamic> getStateInfo() {
    return {
      'currentState': _currentState?.toString(),
      'lastActiveTime': _lastActiveTime?.toIso8601String(),
      'timeSinceLastActive': _lastActiveTime != null
          ? DateTime.now().difference(_lastActiveTime!).inSeconds
          : null,
    };
  }

  /// 🔄 إعادة تعيين الحالة
  void reset() {
    _currentState = null;
    _lastActiveTime = null;
    debugPrint('🔄 AppLifecycleManager reset');
  }
}
