/*import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sync/semaphore.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/app/memory_management_helper.dart';

/// 🚀 محسن precacheImage لتجنب تأثيرها على UI threads والسكرول
class PrecacheImageOptimizer {
  static final Map<String, bool> _cachingInProgress = {};
  static final Map<String, DateTime> _lastCacheAttempt = {};
  static const int _cacheCooldownSeconds = 5; // منع إعادة المحاولة خلال 5 ثوان

  /// ⚡ تحميل آمن للصور بدون تأثير على UI thread
  static Future<void> safePrecacheImage({
    required String imageUrl,
    required BuildContext context,
    required String type,
    required Semaphore semaphore,
  }) async {
    // التحقق من عدم وجود تحميل جارٍ للصورة نفسها
    if (_cachingInProgress[imageUrl] == true) {
      debugPrint('⚠️ Image already being cached: $type');
      return;
    }

    // التحقق من cooldown period
    final lastAttempt = _lastCacheAttempt[imageUrl];
    if (lastAttempt != null) {
      final timeSinceLastAttempt = DateTime.now().difference(lastAttempt);
      if (timeSinceLastAttempt.inSeconds < _cacheCooldownSeconds) {
        debugPrint('⏳ Cache cooldown active for: $type');
        return;
      }
    }

    // فحص الذاكرة قبل البدء
    if (!_isMemorySafeForCaching()) {
      debugPrint('⚠️ Skipping precache - memory usage too high: $type');
      return;
    }

    // التحقق من وجود الصورة في الكاش
    if (await _isImageAlreadyCached(imageUrl)) {
      debugPrint('✅ Image already cached: $type');
      return;
    }

    // تسجيل بداية التحميل
    _cachingInProgress[imageUrl] = true;
    _lastCacheAttempt[imageUrl] = DateTime.now();

    try {
      await semaphore.acquire();

      // ⚡ تحميل غير متزامن مع تجنب blocking الـ UI thread
      await _performAsyncCaching(imageUrl, context);

      debugPrint('✅ Successfully cached: $type');
    } catch (e) {
      debugPrint('❌ Error caching image ($type): $e');
    } finally {
      semaphore.release();
      _cachingInProgress.remove(imageUrl);
    }
  }

  /// فحص أمان الذاكرة
  static bool _isMemorySafeForCaching() {
    final imageCache = PaintingBinding.instance.imageCache;
    final currentUsage =
        imageCache.currentSizeBytes / imageCache.maximumSizeBytes;

    // تحديد نسبة الأمان حسب مواصفات الجهاز
    double safeThreshold = 0.85;
    final deviceTier = MemoryManagementHelper.getDeviceTier();

    switch (deviceTier) {
      case DevicePerformanceLevel.premium:
        safeThreshold = 0.95;
        break;
      case DevicePerformanceLevel.high:
        safeThreshold = 0.9;
        break;
      case DevicePerformanceLevel.medium:
        safeThreshold = 0.85;
        break;
      case DevicePerformanceLevel.low:
        safeThreshold = 0.75;
        break;
    }

    return currentUsage < safeThreshold;
  }

  /// التحقق من وجود الصورة في الكاش
  static Future<bool> _isImageAlreadyCached(String imageUrl) async {
    try {
      final cachedFile = await CustomCacheManagers().getFileFromCache(imageUrl);
      return cachedFile != null;
    } catch (e) {
      return false;
    }
  }

  /// تحميل غير متزامن للصورة
  static Future<void> _performAsyncCaching(
      String imageUrl, BuildContext context) async {
    // استخدام Completer للتحكم في العملية بشكل أفضل
    final completer = Completer<void>();

    // تشغيل العملية في microtask منفصل
    scheduleMicrotask(() async {
      try {
        await precacheImage(
          CachedNetworkImageProvider(
            imageUrl,
            headers: {
              'User-Agent': (kDebugMode ? "developer" : "users") +
                  'device OS:' +
                  (Platform.isAndroid ? 'Android' : 'IOS') +
                  ' , application version: 1.0.0',
              "Referer": (kDebugMode ? "developer" : "users") +
                  'device OS:' +
                  (Platform.isAndroid ? 'Android' : 'IOS')
            },
            cacheManager: CustomCacheManagers(),
          ),
          context,
        );

        if (!completer.isCompleted) {
          completer.complete();
        }
      } catch (e) {
        if (!completer.isCompleted) {
          completer.completeError(e);
        }
      }
    });

    return completer.future;
  }

  /// تنظيف البيانات المؤقتة
  static void cleanup() {
    _cachingInProgress.clear();
    _lastCacheAttempt.clear();
    debugPrint('🧹 PrecacheImageOptimizer cleanup completed');
  }

  /// إحصائيات التحميل
  static Map<String, dynamic> getStats() {
    return {
      'cachingInProgress': _cachingInProgress.length,
      'totalCacheAttempts': _lastCacheAttempt.length,
      'memoryUsage': _getMemoryUsagePercentage(),
    };
  }

  static double _getMemoryUsagePercentage() {
    final imageCache = PaintingBinding.instance.imageCache;
    return (imageCache.currentSizeBytes / imageCache.maximumSizeBytes) * 100;
  }
}

/// 🎯 إضافة للـ PreCachingImageBloc - استخدام المحسن الجديد
extension PrecacheImageBlocOptimizer on Object {
  /// استبدال _onCacheImageEvent القديمة بهذه النسخة المحسنة
  static Future<void> optimizedCacheImageEvent({
    required String imageUrl,
    required BuildContext context,
    required String type,
    required Semaphore semaphore,
  }) async {
    if (!imageUrl.contains("cloudinary")) {
      return;
    }

    await PrecacheImageOptimizer.safePrecacheImage(
      imageUrl: imageUrl,
      context: context,
      type: type,
      semaphore: semaphore,
    );
  }
}
*/
