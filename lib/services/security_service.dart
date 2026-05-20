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

  Future<void> hideContent() async {
    try {
      await platform.invokeMethod<void>('hideContent');
      dev.log('SecurityService: تم تفعيل حماية الخصوصية (إخفاء المحتوى)');
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

  void dispose() {
    WidgetsBinding.instance.removeObserver(_observer);
    dev.log('SecurityService: تم إلغاء ملاحظ دورة الحياة');
  }
}

class LifecycleObserver with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    dev.log('LifecycleObserver: تغيير حالة التطبيق إلى: $state');

    switch (state) {
      case AppLifecycleState.paused:
        // عندما يتم إيقاف التطبيق (الذهاب للخلفية)
        SecurityService.instance.hideContent();
        break;
      case AppLifecycleState.inactive:
        // عندما يكون التطبيق غير نشط (مثل عند ظهور dialog نظام)
        SecurityService.instance.hideContent();
        break;
      case AppLifecycleState.hidden:
        // عندما يكون التطبيق مخفياً تماماً
        SecurityService.instance.hideContent();
        break;
      case AppLifecycleState.resumed:
        // عندما يعود التطبيق للمقدمة
        SecurityService.instance.showContent();
        break;
      case AppLifecycleState.detached:
        // عند إغلاق التطبيق
        SecurityService.instance.hideContent();
        break;
    }
  }
}
