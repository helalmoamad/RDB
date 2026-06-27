import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import 'dart:developer' as dev;

class SecurityService {
  static const platform = MethodChannel('com.rdb.www/security');

  static SecurityService? _instance;

  late LifecycleObserver _observer;

  SecurityService._();

  static SecurityService get instance {
    _instance ??= SecurityService._();

    return _instance!;
  }

  Future<void> initialize() async {
    _observer = LifecycleObserver();

    WidgetsBinding.instance.addObserver(_observer);

    dev.log('SecurityService: تم تهيئة خدمة الأمان وملاحظ دورة الحياة');
  }

  Future<void> hideContent({AppLifecycleState? reason}) async {
    // حماية إضافية: لا تنفذ إلا إذا كانت الحالة paused أو hidden
    final state = reason ?? WidgetsBinding.instance.lifecycleState;

    if (state != AppLifecycleState.paused &&
        state != AppLifecycleState.hidden) {
      dev.log(
        'SecurityService: تجاهل إخفاء المحتوى لأن الحالة ليست paused أو hidden: $state',
      );
      return;
    }
    try {
      await platform.invokeMethod<void>('hideContent');
      dev.log(
        'SecurityService: تم تفعيل حماية الخصوصية (إخفاء المحتوى) [state=$state]',
      );
    } on PlatformException catch (e) {
      dev.log('SecurityService: فشل في تفعيل حماية الخصوصية: ${e.message}');
    }
  }

  Future<void> showContent() async {
    try {
      await platform.invokeMethod<void>('showContent');

      dev.log('SecurityService: تم إلغاء حماية الخصوصية (إظهار المحتوى)');
    } on PlatformException catch (e) {
      dev.log('SecurityService: فشل في إلغاء حماية الخصوصية: ${e.message}');
    }
  }

  /// يفحص هل لوحة المفاتيح الافتراضية الحالية من طرف ثالث (أندرويد فقط).
  /// على iOS تُمنع لوحات الطرف الثالث كلياً من AppDelegate، لذا يعيد دائماً false.
  Future<bool> isThirdPartyKeyboard() async {
    if (!Platform.isAndroid) return false;
    try {
      final result = await platform.invokeMethod<bool>('isThirdPartyKeyboard');
      return result ?? false;
    } on PlatformException catch (e) {
      dev.log('SecurityService: فشل فحص لوحة المفاتيح: ${e.message}');
      return false;
    }
  }

  /// يفتح نافذة اختيار لوحة المفاتيح ليبدّل المستخدم للوحة آمنة (أندرويد فقط).
  Future<void> openKeyboardPicker() async {
    if (!Platform.isAndroid) return;
    try {
      await platform.invokeMethod<void>('openKeyboardPicker');
    } on PlatformException catch (e) {
      dev.log('SecurityService: فشل فتح مُحدّد لوحة المفاتيح: ${e.message}');
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(_observer);

    dev.log('SecurityService: تم إلغاء ملاحظ دورة الحياة');
  }
}

class LifecycleObserver with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    dev.log('LifecycleObserver: الحالة الحالية = $state');
    switch (state) {
      case AppLifecycleState.paused:
        SecurityService.instance.hideContent(reason: AppLifecycleState.hidden);
        break;
      case AppLifecycleState.hidden:
        SecurityService.instance.hideContent(reason: AppLifecycleState.hidden);
        break;

      case AppLifecycleState.resumed:
        dev.log('LifecycleObserver: التطبيق عاد للواجهة (resumed)');
        SecurityService.instance.showContent();
        break;

      case AppLifecycleState.inactive:
        SecurityService.instance.hideContent(reason: AppLifecycleState.hidden);
        break;

      case AppLifecycleState.detached:
        dev.log('LifecycleObserver: التطبيق منفصل (detached)');
        SecurityService.instance.hideContent(reason: AppLifecycleState.hidden);
        break;
    }
  }
}
