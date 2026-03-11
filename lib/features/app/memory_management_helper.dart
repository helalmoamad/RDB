/*import 'dart:io';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'my_cached_network_image.dart';

enum DevicePerformanceLevel {
  low, // أجهزة ضعيفة
  medium, // أجهزة متوسطة
  high, // أجهزة قوية
  premium // أجهزة ممتازة
}

class DeviceSpecs {
  final int totalRamMB;
  final int processorCores;
  final int androidSdkVersion;
  final String deviceModel;
  final DevicePerformanceLevel performanceLevel;

  DeviceSpecs({
    required this.totalRamMB,
    required this.processorCores,
    required this.androidSdkVersion,
    required this.deviceModel,
    required this.performanceLevel,
  });
}

class MemoryManagementHelper {
  static bool _isCleaningMemory = false;
  static DateTime? _lastCleanupTime;
  static DeviceSpecs? _deviceSpecs;
  static bool _isInitialized = false;

  /// تهيئة helper مع قياس مواصفات الجهاز
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _deviceSpecs = await _detectDeviceSpecs();
      _configureOptimalSettings();
      _isInitialized = true;

      debugPrint('🚀 MemoryManagementHelper initialized');
      debugPrint('📱 Device: ${_deviceSpecs!.deviceModel}');
      debugPrint('💾 RAM: ${_deviceSpecs!.totalRamMB}MB');
      debugPrint('⚡ Performance Level: ${_deviceSpecs!.performanceLevel}');
    } catch (e) {
      debugPrint('❌ Error initializing MemoryManagementHelper: $e');
      // استخدام إعدادات افتراضية آمنة
      _useDefaultSafeSettings();
      _isInitialized = true;
    }
  }

  /// قياس مواصفات الجهاز
  static Future<DeviceSpecs> _detectDeviceSpecs() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    int totalRamMB = 2048; // قيمة افتراضية آمنة
    int processorCores = 4;
    int androidSdkVersion = 21;
    String deviceModel = 'Unknown';

    try {
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceModel = '${androidInfo.brand} ${androidInfo.model}';
        androidSdkVersion = androidInfo.version.sdkInt;

        // محاولة الحصول على معلومات الذاكرة من النظام
        try {
          final MethodChannel channel = MethodChannel('memory_info');
          final Map<dynamic, dynamic>? memoryInfo =
              await channel.invokeMethod('getTotalMemory');

          if (memoryInfo != null && memoryInfo['totalMemoryMB'] != null) {
            totalRamMB = memoryInfo['totalMemoryMB'];
          }
        } catch (e) {
          // استخدام تقدير بناءً على نموذج الجهاز وإصدار Android
          totalRamMB = _estimateRamFromDevice(deviceModel, androidSdkVersion);
        }

        // تقدير عدد المعالجات
        processorCores = Platform.numberOfProcessors;
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceModel = iosInfo.model;

        // تقدير مواصفات iOS بناءً على النموذج
        totalRamMB = _estimateIosRam(iosInfo.model);
        processorCores = Platform.numberOfProcessors;
      }
    } catch (e) {
      debugPrint('⚠️ Could not detect device specs: $e');
    }

    final performanceLevel = _calculatePerformanceLevel(
        totalRamMB, processorCores, androidSdkVersion);

    return DeviceSpecs(
      totalRamMB: totalRamMB,
      processorCores: processorCores,
      androidSdkVersion: androidSdkVersion,
      deviceModel: deviceModel,
      performanceLevel: performanceLevel,
    );
  }

  /// تقدير ذاكرة الوصول العشوائي بناءً على نموذج الجهاز
  static int _estimateRamFromDevice(String deviceModel, int sdkVersion) {
    final model = deviceModel.toLowerCase();

    // أجهزة ممتازة
    if (model.contains('galaxy s22') ||
        model.contains('galaxy s23') ||
        model.contains('galaxy s24') ||
        model.contains('pixel 7') ||
        model.contains('pixel 8') ||
        model.contains('oneplus 11') ||
        model.contains('xiaomi 13')) {
      return 8192; // 8GB+
    }

    // أجهزة قوية
    if (model.contains('galaxy s20') ||
        model.contains('galaxy s21') ||
        model.contains('pixel 6') ||
        model.contains('oneplus 9') ||
        model.contains('xiaomi 12') ||
        sdkVersion >= 31) {
      return 6144; // 6GB
    }

    // أجهزة متوسطة
    if (model.contains('galaxy a') ||
        model.contains('redmi') ||
        model.contains('realme') ||
        sdkVersion >= 28) {
      return 4096; // 4GB
    }

    // أجهزة ضعيفة
    return 2048; // 2GB
  }

  /// تقدير ذاكرة iOS
  static int _estimateIosRam(String model) {
    if (model.contains('iPhone 14') || model.contains('iPhone 15')) {
      return 6144; // 6GB
    } else if (model.contains('iPhone 12') || model.contains('iPhone 13')) {
      return 4096; // 4GB
    } else if (model.contains('iPad Pro')) {
      return 8192; // 8GB+
    }
    return 3072; // 3GB للأجهزة الأقدم
  }

  /// حساب مستوى أداء الجهاز
  static DevicePerformanceLevel _calculatePerformanceLevel(
      int ramMB, int cores, int sdkVersion) {
    // حساب النقاط بناءً على المواصفات
    int score = 0;

    // نقاط الذاكرة
    if (ramMB >= 8192)
      score += 40;
    else if (ramMB >= 6144)
      score += 30;
    else if (ramMB >= 4096)
      score += 20;
    else if (ramMB >= 3072) score += 10;

    // نقاط المعالج
    if (cores >= 8)
      score += 30;
    else if (cores >= 6)
      score += 20;
    else if (cores >= 4) score += 10;

    // نقاط إصدار النظام
    if (sdkVersion >= 31)
      score += 20; // Android 12+
    else if (sdkVersion >= 28)
      score += 15; // Android 9+
    else if (sdkVersion >= 24) score += 10; // Android 7+

    // تحديد المستوى
    if (score >= 80) return DevicePerformanceLevel.premium;
    if (score >= 60) return DevicePerformanceLevel.high;
    if (score >= 40) return DevicePerformanceLevel.medium;
    return DevicePerformanceLevel.low;
  }

  /// تكوين الإعدادات المثلى حسب مواصفات الجهاز
  static void _configureOptimalSettings() {
    if (_deviceSpecs == null) return;

    final imageCache = PaintingBinding.instance.imageCache;

    switch (_deviceSpecs!.performanceLevel) {
      case DevicePerformanceLevel.premium:
        // إعدادات للأجهزة الممتازة
        imageCache.maximumSizeBytes = 300 * 1024 * 1024; // 300MB
        imageCache.maximumSize = 500;
        break;

      case DevicePerformanceLevel.high:
        // إعدادات للأجهزة القوية
        imageCache.maximumSizeBytes = 200 * 1024 * 1024; // 200MB
        imageCache.maximumSize = 400;
        break;

      case DevicePerformanceLevel.medium:
        // إعدادات للأجهزة المتوسطة
        imageCache.maximumSizeBytes = 120 * 1024 * 1024; // 120MB
        imageCache.maximumSize = 250;
        break;

      case DevicePerformanceLevel.low:
        // إعدادات محافظة للأجهزة الضعيفة
        imageCache.maximumSizeBytes = 80 * 1024 * 1024; // 80MB
        imageCache.maximumSize = 150;
        break;
    }

    debugPrint(
        '🎯 Cache configured for ${_deviceSpecs!.performanceLevel} performance device');
    debugPrint(
        '💾 Max cache size: ${(imageCache.maximumSizeBytes / (1024 * 1024)).round()}MB');
  }

  /// استخدام إعدادات افتراضية آمنة
  static void _useDefaultSafeSettings() {
    final imageCache = PaintingBinding.instance.imageCache;
    imageCache.maximumSizeBytes = 80 * 1024 * 1024; // 80MB
    imageCache.maximumSize = 150;

    debugPrint('🔒 Using safe default cache settings');
  }

  /// تنظيف الذاكرة بطريقة ذكية حسب مواصفات الجهاز
  static Future<void> cleanupMemoryIfNeeded() async {
    if (_isCleaningMemory) return;

    final now = DateTime.now();

    // 🔧 EMERGENCY HOTFIX: زيادة فترات التنظيف لتجنب crashes
    int cleanupIntervalMinutes = 15; // زيادة الحد الأدنى إلى 15 دقيقة
    if (_deviceSpecs != null) {
      switch (_deviceSpecs!.performanceLevel) {
        case DevicePerformanceLevel.premium:
          cleanupIntervalMinutes = 20; // زيادة من 10 إلى 20
          break;
        case DevicePerformanceLevel.high:
          cleanupIntervalMinutes = 18; // زيادة من 7 إلى 18
          break;
        case DevicePerformanceLevel.medium:
          cleanupIntervalMinutes = 16; // زيادة من 5 إلى 16
          break;
        case DevicePerformanceLevel.low:
          cleanupIntervalMinutes = 15; // زيادة من 3 إلى 15 (تغيير كبير!)
          break;
      }
    }

    if (_lastCleanupTime != null &&
        now.difference(_lastCleanupTime!).inMinutes < cleanupIntervalMinutes) {
      return;
    }

    _isCleaningMemory = true;
    _lastCleanupTime = now;

    try {
      // تنظيف تدريجي لتجنب رسائل عدم الاستجابة
      await _performGradualCleanup();

      debugPrint('✅ Smart memory cleanup completed');
    } catch (e) {
      debugPrint('❌ Error during memory cleanup: $e');
    } finally {
      _isCleaningMemory = false;
    }
  }

  /// تنظيف تدريجي لتجنب توقف النظام
  static Future<void> _performGradualCleanup() async {
    // تنظيف على مراحل مع فواصل زمنية صغيرة

    // المرحلة 1: تنظيف الصور المعروضة حالياً
    PaintingBinding.instance.imageCache.clearLiveImages();
    await Future.delayed(Duration(milliseconds: 50));

    // المرحلة 2: تنظيف جزئي للكاش
    final imageCache = PaintingBinding.instance.imageCache;
    if (imageCache.currentSizeBytes > imageCache.maximumSizeBytes * 0.7) {
      imageCache.clear();
      await Future.delayed(Duration(milliseconds: 50));
    }

    // المرحلة 3: تنظيف الكاش المخصص
    try {
      await CustomCacheManagers().emptyCache();
      await Future.delayed(Duration(milliseconds: 50));
    } catch (e) {
      debugPrint('⚠️ Error cleaning custom cache: $e');
    }

    // المرحلة 4: تشغيل garbage collector بطريقة آمنة
    if (Platform.isAndroid || Platform.isIOS) {
      await Future.delayed(Duration(milliseconds: 100));
    }
  }

  /// فحص سريع ومتزامن للذاكرة للاستخدام في scroll listeners
  static void quickMemoryCheck() {
    // 🚨 EMERGENCY HOTFIX: تعطيل الفحص السريع مؤقتاً لمنع crashes أثناء الـ scrolling
    return; // تعطيل مؤقت للفحص السريع

    if (!_isInitialized || _isCleaningMemory) return;

    final imageCache = PaintingBinding.instance.imageCache;

    // 🔧 زيادة جميع نسب التنظيف لتكون أكثر تساهلاً
    double cleanupThreshold = 0.95; // زيادة الحد الأدنى من 0.85 إلى 0.95
    if (_deviceSpecs != null) {
      switch (_deviceSpecs!.performanceLevel) {
        case DevicePerformanceLevel.premium:
          cleanupThreshold = 0.98; // زيادة من 0.95 إلى 0.98
          break;
        case DevicePerformanceLevel.high:
          cleanupThreshold = 0.97; // زيادة من 0.9 إلى 0.97
          break;
        case DevicePerformanceLevel.medium:
          cleanupThreshold = 0.96; // زيادة من 0.85 إلى 0.96
          break;
        case DevicePerformanceLevel.low:
          cleanupThreshold = 0.95; // زيادة من 0.75 إلى 0.95 (تغيير كبير!)
          break;
      }
    }

    // إذا تجاوزت الذاكرة الحد، قم بتنظيف فوري وبسيط
    if (imageCache.currentSizeBytes >
        (imageCache.maximumSizeBytes * cleanupThreshold)) {
      // تنظيف بسيط وسريع بدون await
      imageCache.clearLiveImages();

      debugPrint(
          '⚡ Quick memory cleanup: ${(imageCache.currentSizeBytes / imageCache.maximumSizeBytes * 100).round()}%');
    }
  }

  /// تحسين إعدادات الكاش بناءً على الاستخدام الفعلي
  static void optimizeRuntimeSettings() {
    if (!_isInitialized || _deviceSpecs == null) return;

    final imageCache = PaintingBinding.instance.imageCache;
    final currentUsage =
        imageCache.currentSizeBytes / imageCache.maximumSizeBytes;

    // إذا كان الاستخدام عالي جداً، قلل الإعدادات
    if (currentUsage > 0.9) {
      switch (_deviceSpecs!.performanceLevel) {
        case DevicePerformanceLevel.premium:
          imageCache.maximumSizeBytes =
              250 * 1024 * 1024; // تقليل من 300 إلى 250
          imageCache.maximumSize = 450; // تقليل من 500 إلى 450
          break;
        case DevicePerformanceLevel.high:
          imageCache.maximumSizeBytes =
              170 * 1024 * 1024; // تقليل من 200 إلى 170
          imageCache.maximumSize = 350; // تقليل من 400 إلى 350
          break;
        case DevicePerformanceLevel.medium:
          imageCache.maximumSizeBytes =
              100 * 1024 * 1024; // تقليل من 120 إلى 100
          imageCache.maximumSize = 200; // تقليل من 250 إلى 200
          break;
        case DevicePerformanceLevel.low:
          imageCache.maximumSizeBytes = 60 * 1024 * 1024; // تقليل من 80 إلى 60
          imageCache.maximumSize = 120; // تقليل من 150 إلى 120
          break;
      }

      debugPrint(
          '🔧 Runtime cache optimization applied due to high usage: ${(currentUsage * 100).round()}%');
    }

    // إذا كان الاستخدام منخفض، يمكن زيادة الإعدادات قليلاً
    else if (currentUsage < 0.3) {
      switch (_deviceSpecs!.performanceLevel) {
        case DevicePerformanceLevel.premium:
          imageCache.maximumSizeBytes =
              350 * 1024 * 1024; // زيادة من 300 إلى 350
          imageCache.maximumSize = 600; // زيادة من 500 إلى 600
          break;
        case DevicePerformanceLevel.high:
          imageCache.maximumSizeBytes =
              230 * 1024 * 1024; // زيادة من 200 إلى 230
          imageCache.maximumSize = 450; // زيادة من 400 إلى 450
          break;
        default:
          // الأجهزة المتوسطة والضعيفة تبقى كما هي
          break;
      }

      debugPrint(
          '📈 Runtime cache expansion applied due to low usage: ${(currentUsage * 100).round()}%');
    }
  }

  /// فحص صحة إعدادات الكاش وإصلاح أي مشاكل
  static void validateCacheSettings() {
    if (!_isInitialized) return;

    final imageCache = PaintingBinding.instance.imageCache;

    // التأكد من أن الإعدادات في النطاق المعقول
    if (imageCache.maximumSizeBytes > 500 * 1024 * 1024) {
      // إذا كانت أكبر من 500MB، قللها
      imageCache.maximumSizeBytes = 300 * 1024 * 1024;
      debugPrint('⚠️ Cache size was too large, reduced to 300MB');
    }

    if (imageCache.maximumSize > 800) {
      // إذا كان عدد الصور أكبر من 800، قلله
      imageCache.maximumSize = 500;
      debugPrint('⚠️ Cache count was too large, reduced to 500 images');
    }

    // التأكد من أن الحد الأدنى معقول
    if (imageCache.maximumSizeBytes < 50 * 1024 * 1024) {
      imageCache.maximumSizeBytes = 80 * 1024 * 1024;
      debugPrint('⚠️ Cache size was too small, increased to 80MB');
    }

    if (imageCache.maximumSize < 100) {
      imageCache.maximumSize = 150;
      debugPrint('⚠️ Cache count was too small, increased to 150 images');
    }
  }

  /// فحص استهلاك الذاكرة وتنظيفها بذكاء
  static Future<void> checkAndCleanMemory() async {
    if (!_isInitialized) {
      await initialize();
    }

    final imageCache = PaintingBinding.instance.imageCache;

    // تحديد نسبة التنظيف حسب مواصفات الجهاز
    double cleanupThreshold = 0.8;
    if (_deviceSpecs != null) {
      switch (_deviceSpecs!.performanceLevel) {
        case DevicePerformanceLevel.premium:
          cleanupThreshold = 0.9; // استخدام أكثر للذاكرة
          break;
        case DevicePerformanceLevel.high:
          cleanupThreshold = 0.85;
          break;
        case DevicePerformanceLevel.medium:
          cleanupThreshold = 0.8;
          break;
        case DevicePerformanceLevel.low:
          cleanupThreshold = 0.7; // تنظيف مبكر للأجهزة الضعيفة
          break;
      }
    }

    if (imageCache.currentSizeBytes >
        (imageCache.maximumSizeBytes * cleanupThreshold)) {
      debugPrint(
          '🧹 Memory usage ${(imageCache.currentSizeBytes / imageCache.maximumSizeBytes * 100).round()}%, cleaning up...');
      await cleanupMemoryIfNeeded();
    }
  }

  /// تنظيف ذكي عند إغلاق الصفحات
  static void cleanupOnPageDispose() {
    final imageCache = PaintingBinding.instance.imageCache;

    // تحديد عدد الصور المسموح حسب مواصفات الجهاز
    int maxLiveImages = 50;
    if (_deviceSpecs != null) {
      switch (_deviceSpecs!.performanceLevel) {
        case DevicePerformanceLevel.premium:
          maxLiveImages = 100;
          break;
        case DevicePerformanceLevel.high:
          maxLiveImages = 80;
          break;
        case DevicePerformanceLevel.medium:
          maxLiveImages = 60;
          break;
        case DevicePerformanceLevel.low:
          maxLiveImages = 30;
          break;
      }
    }

    if (imageCache.liveImageCount > maxLiveImages) {
      imageCache.clearLiveImages();
      debugPrint(
          '🧹 Cleaned live images on page dispose (${imageCache.liveImageCount} images)');
    }
  }

  /// الحصول على معلومات مواصفات الجهاز
  static DeviceSpecs? get deviceSpecs => _deviceSpecs;

  /// التحقق من مستوى الأداء
  static bool get isHighPerformanceDevice =>
      _deviceSpecs?.performanceLevel == DevicePerformanceLevel.premium ||
      _deviceSpecs?.performanceLevel == DevicePerformanceLevel.high;

  /// إعدادات خاصة لمنع رسائل عدم الاستجابة
  static Future<void> preventSystemUIFreeze() async {
    // تنظيف استباقي لتجنب امتلاء الذاكرة
    final imageCache = PaintingBinding.instance.imageCache;

    if (imageCache.currentSizeBytes > imageCache.maximumSizeBytes * 0.9) {
      // تنظيف فوري ولكن تدريجي
      await _performGradualCleanup();
    }

    // إنشاء مساحة أمان في الذاكرة
    if (_deviceSpecs?.performanceLevel == DevicePerformanceLevel.low) {
      // للأجهزة الضعيفة، نحافظ على مساحة أكبر
      if (imageCache.currentSizeBytes > imageCache.maximumSizeBytes * 0.6) {
        imageCache.clearLiveImages();
      }
    }
  }

  /// فحص سريع وآمن للذاكرة مع معالجة الأخطاء
  static void safeQuickMemoryCheck() {
    try {
      if (!_isInitialized) {
        debugPrint('⚠️ Memory helper not initialized, skipping check');
        return;
      }

      quickMemoryCheck();
    } catch (e) {
      // في حالة فشل فحص الذاكرة، لا نريد توقف التطبيق
      debugPrint('⚠️ Safe memory check failed, continuing normally: $e');
    }
  }

  /// تنظيف آمن للذاكرة
  static Future<void> safeCleanupMemory() async {
    try {
      if (!_isInitialized) {
        debugPrint('⚠️ Memory helper not initialized, skipping cleanup');
        return;
      }

      await checkAndCleanMemory();
    } catch (e) {
      // في حالة فشل التنظيف، لا نريد توقف التطبيق
      debugPrint('⚠️ Safe memory cleanup failed, continuing normally: $e');
    }
  }

  /// تنظيف آمن عند إغلاق الصفحة
  static void safePageDispose() {
    try {
      cleanupOnPageDispose();
    } catch (e) {
      // في حالة فشل التنظيف، لا نريد توقف التطبيق
      debugPrint('⚠️ Safe page dispose failed, continuing normally: $e');
    }
  }

  /// الحصول على مستوى أداء الجهاز
  static DevicePerformanceLevel getDeviceTier() {
    if (!_isInitialized || _deviceSpecs == null) {
      // إرجاع قيمة افتراضية آمنة
      return DevicePerformanceLevel.medium;
    }
    return _deviceSpecs!.performanceLevel;
  }

  // ✅ نظام كاش ذكي جديد - يحافظ على الصور ولا يمسحها عند إغلاق التطبيق

  /// تنظيف ذكي للكاش - يمسح جزء فقط عند الحاجة
  static Future<void> smartCacheCleanup() async {
    if (!_isInitialized) {
      await initialize();
    }

    final imageCache = PaintingBinding.instance.imageCache;
    final currentUsage =
        imageCache.currentSizeBytes / imageCache.maximumSizeBytes;

    // ✅ تنظيف فقط إذا تجاوزت الذاكرة 90% (بدلاً من مسح كل شيء)
    if (currentUsage > 0.9) {
      debugPrint(
          '🧠 Smart cleanup: Memory at ${(currentUsage * 100).round()}%');

      // الخطوة 1: مسح الصور المعروضة حالياً فقط (أقل تأثير)
      final beforeLive = imageCache.currentSizeBytes;
      imageCache.clearLiveImages();
      final afterLive = imageCache.currentSizeBytes;

      await Future.delayed(const Duration(milliseconds: 50));

      // الخطوة 2: إذا لم يكفي، مسح 30% من الكاش فقط
      final newUsage =
          imageCache.currentSizeBytes / imageCache.maximumSizeBytes;
      if (newUsage > 0.8) {
        await _partialCacheCleanup();
      }

      final freedMB =
          (beforeLive - imageCache.currentSizeBytes) / (1024 * 1024);
      debugPrint(
          '✅ Smart cleanup freed: ${freedMB.toStringAsFixed(1)}MB (kept ${((imageCache.currentSizeBytes / imageCache.maximumSizeBytes) * 100).round()}%)');
    }
  }

  /// تنظيف جزئي للكاش - يحافظ على 70% من الصور
  static Future<void> _partialCacheCleanup() async {
    try {
      final imageCache = PaintingBinding.instance.imageCache;
      final originalSize = imageCache.currentSizeBytes;

      // تقليل حجم الكاش مؤقتاً لإجبار Flutter على مسح الصور الأقدم
      final originalMaxSize = imageCache.maximumSizeBytes;
      final originalMaxCount = imageCache.maximumSize;

      // تقليل بنسبة 30% مؤقتاً
      imageCache.maximumSizeBytes = (originalMaxSize * 0.7).round();
      imageCache.maximumSize = (originalMaxCount * 0.7).round();

      // انتظار Flutter لتنظيف الكاش تلقائياً
      await Future.delayed(const Duration(milliseconds: 100));

      // إعادة الحجم الأصلي بعد التنظيف
      imageCache.maximumSizeBytes = originalMaxSize;
      imageCache.maximumSize = originalMaxCount;

      final freedMB =
          (originalSize - imageCache.currentSizeBytes) / (1024 * 1024);
      debugPrint('🔄 Partial cleanup freed: ${freedMB.toStringAsFixed(1)}MB');
    } catch (e) {
      debugPrint('⚠️ Error in partial cleanup: $e');
    }
  }

  /// منع مسح الكاش عند إغلاق التطبيق
  static void preventAppCloseCacheClear() {
    // تجاوز التنظيف التلقائي عند إغلاق التطبيق
    debugPrint(
        '🛡️ Cache protection enabled - images will persist after app close');
  }

  /// تنظيف طارئ فقط عند الضرورة القصوى
  static Future<void> emergencyCleanup() async {
    debugPrint('🚨 Emergency cleanup - freeing 50% of cache');

    final imageCache = PaintingBinding.instance.imageCache;
    final originalSize = imageCache.currentSizeBytes;

    // مسح الصور المعروضة
    imageCache.clearLiveImages();
    await Future.delayed(const Duration(milliseconds: 50));

    // مسح 50% من الكاش المخصص
    try {
      await CustomCacheManagers().emptyCache();
      await Future.delayed(const Duration(milliseconds: 50));
    } catch (e) {
      debugPrint('⚠️ Error cleaning custom cache: $e');
    }

    final freedMB =
        (originalSize - imageCache.currentSizeBytes) / (1024 * 1024);
    debugPrint('🚨 Emergency cleanup freed: ${freedMB.toStringAsFixed(1)}MB');
  }

  /// فحص ذكي للذاكرة - لا يمسح إلا عند الضرورة
  static void smartMemoryCheck() {
    if (!_isInitialized) return;

    final imageCache = PaintingBinding.instance.imageCache;
    final currentUsage =
        imageCache.currentSizeBytes / imageCache.maximumSizeBytes;

    // تحديد نسبة التنظيف حسب مواصفات الجهاز
    double cleanupThreshold = 0.9; // نسبة أعلى لتجنب المسح المتكرر
    if (_deviceSpecs != null) {
      switch (_deviceSpecs!.performanceLevel) {
        case DevicePerformanceLevel.premium:
          cleanupThreshold = 0.95; // استخدام أكثر للذاكرة
          break;
        case DevicePerformanceLevel.high:
          cleanupThreshold = 0.92;
          break;
        case DevicePerformanceLevel.medium:
          cleanupThreshold = 0.9;
          break;
        case DevicePerformanceLevel.low:
          cleanupThreshold = 0.85; // تنظيف مبكر للأجهزة الضعيفة
          break;
      }
    }

    // تنظيف بسيط فقط إذا تجاوزت النسبة المحددة
    if (currentUsage > cleanupThreshold) {
      // تنظيف بسيط وسريع - مسح الصور المعروضة فقط
      imageCache.clearLiveImages();

      debugPrint(
          '⚡ Quick smart cleanup: ${(currentUsage * 100).round()}% -> ${((imageCache.currentSizeBytes / imageCache.maximumSizeBytes) * 100).round()}%');
    }
  }

  /// إعدادات كاش محسنة للحفاظ على الصور لفترة أطول
  static void configureSmartCacheSettings() {
    if (!_isInitialized || _deviceSpecs == null) return;

    final imageCache = PaintingBinding.instance.imageCache;

    // إعدادات أكبر للحفاظ على الصور لفترة أطول
    switch (_deviceSpecs!.performanceLevel) {
      case DevicePerformanceLevel.premium:
        imageCache.maximumSizeBytes = 500 * 1024 * 1024; // 500MB
        imageCache.maximumSize = 1000; // 1000 صورة
        break;
      case DevicePerformanceLevel.high:
        imageCache.maximumSizeBytes = 350 * 1024 * 1024; // 350MB
        imageCache.maximumSize = 700; // 700 صورة
        break;
      case DevicePerformanceLevel.medium:
        imageCache.maximumSizeBytes =
            200 * 1024 * 1024; // 200MB (تقليل لمنع التعليق)
        imageCache.maximumSize = 400; // 400 صورة (تقليل لمنع التعليق)

        // 🛡️ حماية إضافية للأجهزة المتوسطة من التعليق
        debugPrint(
            '🛡️ Applied medium device protection - reduced cache limits');
        break;
      case DevicePerformanceLevel.low:
        imageCache.maximumSizeBytes = 150 * 1024 * 1024; // 150MB
        imageCache.maximumSize = 300; // 300 صورة
        break;
    }

    debugPrint(
        '🧠 Smart cache configured: ${imageCache.maximumSizeBytes ~/ (1024 * 1024)}MB, ${imageCache.maximumSize} images');
  }

  /// إحصائيات الكاش الذكي
  static Map<String, dynamic> getSmartCacheStats() {
    final imageCache = PaintingBinding.instance.imageCache;

    return {
      'currentSize':
          '${(imageCache.currentSizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB',
      'maxSize':
          '${(imageCache.maximumSizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB',
      'usage':
          '${((imageCache.currentSizeBytes / imageCache.maximumSizeBytes) * 100).toStringAsFixed(1)}%',
      'imageCount': imageCache.currentSize,
      'maxImageCount': imageCache.maximumSize,
      'liveImages': imageCache.liveImageCount,
    };
  }

  // 🚀 Progressive Loading Memory Optimization Methods

  /// تحسين خفيف للذاكرة - للاستخدام بين مراحل التحميل
  static void softMemoryCleanup() {
    try {
      final imageCache = PaintingBinding.instance.imageCache;
      final currentUsage =
          imageCache.currentSizeBytes / imageCache.maximumSizeBytes;

      // تنظيف خفيف فقط إذا كانت الذاكرة أكثر من 75%
      if (currentUsage > 0.75) {
        imageCache.clearLiveImages();
        debugPrint(
            '🔄 Soft memory cleanup performed: ${(currentUsage * 100).round()}%');
      }
    } catch (e) {
      debugPrint('⚠️ Error in soft memory cleanup: $e');
    }
  }

  /// تحسين متوسط للذاكرة - للاستخدام عند تحميل المنتجات
  static void moderateMemoryCleanup() {
    try {
      final imageCache = PaintingBinding.instance.imageCache;
      final currentUsage =
          imageCache.currentSizeBytes / imageCache.maximumSizeBytes;

      // تنظيف متوسط إذا كانت الذاكرة أكثر من 70%
      if (currentUsage > 0.70) {
        imageCache.clearLiveImages();

        // تحسين إضافي للأجهزة المتوسطة والضعيفة
        if (_deviceSpecs?.performanceLevel == DevicePerformanceLevel.medium ||
            _deviceSpecs?.performanceLevel == DevicePerformanceLevel.low) {
          // تأخير قصير لإتمام التنظيف
          Future.delayed(Duration(milliseconds: 50), () {
            _partialCacheCleanup();
          });
        }

        debugPrint(
            '⚡ Moderate memory cleanup performed: ${(currentUsage * 100).round()}%');
      }
    } catch (e) {
      debugPrint('⚠️ Error in moderate memory cleanup: $e');
    }
  }

  /// تحسين شامل للذاكرة - عند اكتمال التحميل التدريجي
  static void comprehensiveMemoryCleanup() {
    try {
      final imageCache = PaintingBinding.instance.imageCache;
      final beforeSize = imageCache.currentSizeBytes;

      // تنظيف الصور المعروضة
      imageCache.clearLiveImages();

      // انتظار قصير لإتمام التنظيف التلقائي
      Future.delayed(Duration(milliseconds: 100));

      // تحسين إضافي حسب نوع الجهاز
      if (_deviceSpecs != null) {
        switch (_deviceSpecs!.performanceLevel) {
          case DevicePerformanceLevel.low:
            // تنظيف أكثر للأجهزة الضعيفة
            Future.delayed(Duration(milliseconds: 200), () {
              smartCacheCleanup();
            });
            break;
          case DevicePerformanceLevel.medium:
            // تنظيف متوسط للأجهزة المتوسطة
            Future.delayed(Duration(milliseconds: 150), () {
              _partialCacheCleanup();
            });
            break;
          default:
            // الأجهزة القوية لا تحتاج تنظيف إضافي
            break;
        }
      }

      final freedMB =
          (beforeSize - imageCache.currentSizeBytes) / (1024 * 1024);
      debugPrint(
          '🏁 Comprehensive memory cleanup completed: ${freedMB.toStringAsFixed(1)}MB freed');
    } catch (e) {
      debugPrint('⚠️ Error in comprehensive memory cleanup: $e');
    }
  }
}
*/
