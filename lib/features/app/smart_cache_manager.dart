/*import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'memory_management_helper.dart';
import 'home_page_image_protector.dart';

/// مدير الكاش الذكي مع حماية صور الصفحة الرئيسية
class SmartCacheManager {
  static bool _isInitialized = false;
  static SharedPreferences? _prefs;
  static Timer? _maintenanceTimer;

  // إحصائيات الاستخدام
  static final Map<String, int> _imageAccessCount = {};
  static final Map<String, DateTime> _imageLastAccess = {};

  // مفاتيح التخزين
  static const String _lastCleanupKey = 'smart_cache_last_cleanup';
  static const String _cacheStatsKey = 'smart_cache_statistics';

  /// تهيئة النظام الذكي
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();

      // تهيئة نظام حماية الصفحة الرئيسية
      await HomePageImageProtector.initialize();

      _configureSmartCacheSettings();
      _startMaintenanceTimer();
      _loadCacheStatistics();

      _isInitialized = true;
      debugPrint(
          '🎯 Smart Cache Manager initialized with home page protection');
    } catch (e) {
      debugPrint('❌ Error initializing Smart Cache Manager: $e');
      _useDefaultSafeSettings();
    }
  }

  /// تكوين إعدادات الكاش الذكية مع حماية الصفحة الرئيسية
  static void _configureSmartCacheSettings() {
    final imageCache = PaintingBinding.instance.imageCache;
    final deviceTier = MemoryManagementHelper.getDeviceTier();

    // إعدادات محسنة مع مساحة إضافية لصور الصفحة الرئيسية
    switch (deviceTier) {
      case DevicePerformanceLevel.premium:
        imageCache.maximumSizeBytes = 500 * 1024 * 1024; // 500MB
        imageCache.maximumSize = 1000; // 1000 صورة
        HomePageImageProtector.updateImageLimit(150); // 150 صورة محمية
        break;
      case DevicePerformanceLevel.high:
        imageCache.maximumSizeBytes = 400 * 1024 * 1024; // 400MB
        imageCache.maximumSize = 800; // 800 صورة
        HomePageImageProtector.updateImageLimit(120); // 120 صورة محمية
        break;
      case DevicePerformanceLevel.medium:
        imageCache.maximumSizeBytes = 300 * 1024 * 1024; // 300MB
        imageCache.maximumSize = 600; // 600 صورة
        HomePageImageProtector.updateImageLimit(100); // 100 صورة محمية
        break;
      case DevicePerformanceLevel.low:
        imageCache.maximumSizeBytes = 200 * 1024 * 1024; // 200MB
        imageCache.maximumSize = 400; // 400 صورة
        HomePageImageProtector.updateImageLimit(80); // 80 صورة محمية
        break;
    }

    debugPrint('🔧 Smart cache configured with home page protection');
    debugPrint(
        '💾 Max cache: ${imageCache.maximumSizeBytes ~/ (1024 * 1024)}MB, ${imageCache.maximumSize} images');
  }

  /// تسجيل وصول للصورة مع تحديد المصدر
  static void trackImageAccess(String imageUrl, {String? source}) {
    if (!_isInitialized) return;

    _imageAccessCount[imageUrl] = (_imageAccessCount[imageUrl] ?? 0) + 1;
    _imageLastAccess[imageUrl] = DateTime.now();

    // حماية صور الصفحة الرئيسية
    if (_isHomePageImage(imageUrl, source)) {
      HomePageImageProtector.protectHomePageImage(imageUrl, source: source);
    }

    // حفظ الإحصائيات كل 10 وصولات
    if (_imageAccessCount.values.fold(0, (sum, count) => sum + count) % 10 ==
        0) {
      _saveCacheStatistics();
    }
  }

  /// تحديد إذا كانت الصورة من الصفحة الرئيسية
  static bool _isHomePageImage(String imageUrl, String? source) {
    if (source != null) {
      return [
        'home_page_card2',
        'features_products_widget',
        'flash_deal_products_widget'
      ].contains(source);
    }

    // التحقق من URL
    return imageUrl.contains('/home/') ||
        imageUrl.contains('/featured/') ||
        imageUrl.contains('/flash/') ||
        imageUrl.contains('home_') ||
        imageUrl.contains('featured_') ||
        imageUrl.contains('flash_deal');
  }

  /// فحص الذاكرة وتنظيف ذكي مع حماية الصفحة الرئيسية
  static Future<void> smartMemoryCheck() async {
    if (!_isInitialized) {
      await initialize();
    }

    final imageCache = PaintingBinding.instance.imageCache;
    final currentUsage =
        imageCache.currentSizeBytes / imageCache.maximumSizeBytes;

    // تنظيف فقط إذا تجاوزت الذاكرة 85%
    if (currentUsage > 0.85) {
      await _performProtectedSmartCleanup();
    }
  }

  /// تنظيف ذكي مع حماية صور الصفحة الرئيسية
  static Future<void> _performProtectedSmartCleanup() async {
    debugPrint('🧹 Starting protected smart cleanup...');

    final imageCache = PaintingBinding.instance.imageCache;
    final initialSize = imageCache.currentSizeBytes;

    // الخطوة 1: مسح الصور المعروضة حالياً فقط (أقل تأثير)
    imageCache.clearLiveImages();
    await Future.delayed(const Duration(milliseconds: 50));

    final afterLiveCleanup = imageCache.currentSizeBytes;
    final currentUsage = afterLiveCleanup / imageCache.maximumSizeBytes;

    // الخطوة 2: مسح الصور الأقل استخداماً مع حماية الصفحة الرئيسية
    if (currentUsage > 0.75) {
      await _cleanupNonHomePageImages();
    }

    // الخطوة 3: تقليل مؤقت فقط للصور غير المحمية
    if (currentUsage > 0.7) {
      await _temporarilyReduceNonProtectedCache();
    }

    final finalSize = imageCache.currentSizeBytes;
    final savedMB = (initialSize - finalSize) / (1024 * 1024);

    debugPrint(
        '✅ Protected smart cleanup completed: ${savedMB.toStringAsFixed(1)}MB freed');
    debugPrint(
        '🛡️ Home page images protected: ${HomePageImageProtector.getProtectionStats()['homePageImages']}');

    // حفظ وقت التنظيف
    await _prefs?.setInt(
        _lastCleanupKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// مسح الصور الأقل استخداماً باستثناء صور الصفحة الرئيسية
  static Future<void> _cleanupNonHomePageImages() async {
    try {
      // ترتيب الصور حسب الاستخدام
      final sortedImages = _imageAccessCount.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));

      // فلترة الصور لاستبعاد المحمية
      final imagesToDelete = sortedImages
          .map((entry) => entry.key)
          .where((url) => !HomePageImageProtector.isProtectedImage(url))
          .toList();

      // مسح 30% من الصور غير المحمية
      final toRemove = (imagesToDelete.length * 0.3).round();

      for (int i = 0; i < toRemove && i < imagesToDelete.length; i++) {
        final imageUrl = imagesToDelete[i];

        // مسح من الكاش المخصص
        try {
          final cacheManager = DefaultCacheManager();
          await cacheManager.removeFile(imageUrl);
        } catch (e) {
          // تجاهل الأخطاء
        }

        // إزالة من التتبع
        _imageAccessCount.remove(imageUrl);
        _imageLastAccess.remove(imageUrl);
      }

      final protectedCount = sortedImages.length - imagesToDelete.length;
      debugPrint('🗑️ Removed $toRemove non-home-page images');
      debugPrint(
          '🛡️ Protected $protectedCount home page images from deletion');
    } catch (e) {
      debugPrint('⚠️ Error cleaning non-home-page images: $e');
    }
  }

  /// تقليل مؤقت للكاش مع حفظ المحمي
  static Future<void> _temporarilyReduceNonProtectedCache() async {
    final imageCache = PaintingBinding.instance.imageCache;
    final originalSize = imageCache.maximumSizeBytes;
    final originalCount = imageCache.maximumSize;

    // تقليل بنسبة 20% فقط (أقل من السابق لحماية الصور المهمة)
    imageCache.maximumSizeBytes = (originalSize * 0.8).round();
    imageCache.maximumSize = (originalCount * 0.8).round();

    debugPrint('📉 Temporarily reduced cache (protecting home page images)');

    // إعادة الحجم الأصلي بعد 3 دقائق (أقل من السابق)
    Future.delayed(const Duration(minutes: 3), () {
      imageCache.maximumSizeBytes = originalSize;
      imageCache.maximumSize = originalCount;
      debugPrint('📈 Cache size restored with home page protection');
    });
  }

  /// بدء timer الصيانة
  static void _startMaintenanceTimer() {
    _maintenanceTimer?.cancel();
    _maintenanceTimer = Timer.periodic(Duration(minutes: 15), (_) {
      _performMaintenanceCheck();
    });
  }

  /// فحص صيانة دوري
  static void _performMaintenanceCheck() async {
    if (!_isInitialized) return;

    // التحقق من صحة نظام الحماية
    if (!HomePageImageProtector.validateSystem()) {
      debugPrint('⚠️ Home page protection system needs maintenance');
      await HomePageImageProtector.initialize();
    }

    // تنظيف الإحصائيات القديمة
    _cleanupOldStatistics();
  }

  /// تنظيف الإحصائيات القديمة
  static void _cleanupOldStatistics() {
    final now = DateTime.now();
    final cutoffTime = now.subtract(Duration(hours: 24));

    _imageLastAccess.removeWhere((url, lastAccess) {
      final isOld = lastAccess.isBefore(cutoffTime);
      if (isOld && !HomePageImageProtector.isProtectedImage(url)) {
        _imageAccessCount.remove(url);
        return true;
      }
      return false;
    });
  }

  /// حفظ إحصائيات الكاش
  static void _saveCacheStatistics() {
    if (_prefs == null) return;

    final stats = {
      'totalAccess':
          _imageAccessCount.values.fold(0, (sum, count) => sum + count),
      'uniqueImages': _imageAccessCount.length,
      'lastUpdate': DateTime.now().millisecondsSinceEpoch,
    };

    _prefs!.setString(_cacheStatsKey, stats.toString());
  }

  /// تحميل إحصائيات الكاش
  static void _loadCacheStatistics() {
    // تحميل الإحصائيات المحفوظة إذا كانت متوفرة
    final savedStats = _prefs?.getString(_cacheStatsKey);
    if (savedStats != null) {
      debugPrint('📊 Loaded cache statistics: $savedStats');
    }
  }

  /// إحصائيات شاملة مع حماية الصفحة الرئيسية
  static Map<String, dynamic> getCacheStatistics() {
    final imageCache = PaintingBinding.instance.imageCache;
    final protectionStats = HomePageImageProtector.getProtectionStats();

    return {
      'totalImages': _imageAccessCount.length,
      'currentCacheSize':
          '${(imageCache.currentSizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB',
      'maxCacheSize':
          '${(imageCache.maximumSizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB',
      'cacheUsage':
          '${((imageCache.currentSizeBytes / imageCache.maximumSizeBytes) * 100).toStringAsFixed(1)}%',
      'homePageProtection': protectionStats,
      'mostAccessedImages': _getMostAccessedImages(5),
      'systemHealth': HomePageImageProtector.validateSystem()
          ? 'Healthy'
          : 'Needs Attention',
    };
  }

  /// الحصول على الصور الأكثر استخداماً
  static List<Map<String, dynamic>> _getMostAccessedImages(int limit) {
    final sorted = _imageAccessCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted
        .take(limit)
        .map((entry) => {
              'url': entry.key.length > 50
                  ? '${entry.key.substring(0, 50)}...'
                  : entry.key,
              'accessCount': entry.value,
              'isProtected': HomePageImageProtector.isProtectedImage(entry.key),
              'lastAccess':
                  _imageLastAccess[entry.key]?.toString() ?? 'Unknown',
            })
        .toList();
  }

  /// استخدام إعدادات افتراضية آمنة
  static void _useDefaultSafeSettings() {
    final imageCache = PaintingBinding.instance.imageCache;
    imageCache.maximumSizeBytes = 150 * 1024 * 1024; // 150MB
    imageCache.maximumSize = 300; // 300 صورة

    debugPrint('🔒 Using safe default cache settings');
  }

  /// تنظيف شامل مع حماية الصفحة الرئيسية
  static Future<void> dispose() async {
    _maintenanceTimer?.cancel();
    HomePageImageProtector.dispose();
    _imageAccessCount.clear();
    _imageLastAccess.clear();
    _isInitialized = false;
    debugPrint('🧹 Smart Cache Manager disposed with protection');
  }
}
*/
