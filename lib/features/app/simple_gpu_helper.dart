import 'package:flutter/material.dart';

/// 🎮 مساعد بسيط لتحسين الصور حسب معالج الرسوم
class SimpleGPUHelper {
  /// 🔧 الحصول على إعدادات محسنة للصور
  static Map<String, dynamic> getOptimizedImageSettings(
      double width, double height, context) {
    // إعدادات بسيطة حسب حجم الشاشة
    final screenWidth = MediaQuery.of(context).size.width;
    final isHighResDevice = screenWidth > 400;

    final scale = isHighResDevice ? 1.3 : 1.1;

    return {
      'memCacheHeight': (height * scale).round(),
      'memCacheWidth': (width * scale).round(),
      'renderingScale': isHighResDevice ? 1.0 : 0.9,
    };
  }

  /// 🔧 التحقق من كون المعالج مهيأ (دائماً true للبساطة)
  static bool get isInitialized => true;
}
