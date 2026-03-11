import 'dart:async';
import 'package:flutter/foundation.dart';

/// نظام حماية صور الصفحة الرئيسية - أولوية قصوى
class HomePageImageProtector {
  static final Set<String> _homePageImages = <String>{};
  static final Set<String> _protectedImages = <String>{};
  static bool _isInitialized = false;
  static int _maxHomePageImages = 100;
  static Timer? _cleanupTimer;

  /// تهيئة نظام الحماية
  static Future<void> initialize() async {
    if (_isInitialized) return;

    _isInitialized = true;
    _startPeriodicCleanup();

    debugPrint('🛡️ Home page image protector initialized');
    debugPrint('📊 Max protected images: $_maxHomePageImages');
  }

  /// إضافة صورة للحماية (صور الصفحة الرئيسية)
  static void protectHomePageImage(String imageUrl, {String? source}) {
    if (!_isInitialized) return;

    // تحديد مصدر الصورة للأولوية
    final imageSource = source ?? _detectImageSource(imageUrl);

    if (_isHomePageSource(imageSource)) {
      _homePageImages.add(imageUrl);
      _protectedImages.add(imageUrl);

      debugPrint(
          '🛡️ Protected home page image: ${_getShortUrl(imageUrl)} from $imageSource');

      // إذا تجاوز العدد المسموح، احذف الأقدم
      _enforceImageLimit();
    }
  }

  /// فحص إذا كانت الصورة محمية
  static bool isProtectedImage(String imageUrl) {
    return _protectedImages.contains(imageUrl);
  }

  /// فحص إذا كانت الصورة من الصفحة الرئيسية
  static bool isHomePageImage(String imageUrl) {
    return _homePageImages.contains(imageUrl);
  }

  /// تحديد مصدر الصورة
  static String _detectImageSource(String imageUrl) {
    if (imageUrl.contains('/home/') || imageUrl.contains('home_')) {
      return 'home_page_card2';
    } else if (imageUrl.contains('/featured/') ||
        imageUrl.contains('featured_')) {
      return 'features_products_widget';
    } else if (imageUrl.contains('/flash/') ||
        imageUrl.contains('flash_deal')) {
      return 'flash_deal_products_widget';
    } else if (imageUrl.contains('/banner/') || imageUrl.contains('banner_')) {
      return 'home_banner';
    }
    return 'other';
  }

  /// فحص إذا كان المصدر من الصفحة الرئيسية
  static bool _isHomePageSource(String source) {
    return [
      'home_page_card2',
      'features_products_widget',
      'flash_deal_products_widget',
      'home_banner'
    ].contains(source);
  }

  /// تطبيق حد الصور المحمية
  static void _enforceImageLimit() {
    if (_homePageImages.length <= _maxHomePageImages) return;

    // تحويل إلى قائمة وترتيب حسب الأولوية
    final imagesList = _homePageImages.toList();
    final imagesToRemove = imagesList.length - _maxHomePageImages;

    // إزالة الصور الزائدة (الأقدم أولاً)
    for (int i = 0; i < imagesToRemove; i++) {
      final imageToRemove = imagesList[i];
      _homePageImages.remove(imageToRemove);
      _protectedImages.remove(imageToRemove);
    }

    debugPrint(
        '🗑️ Removed $imagesToRemove old home page images to maintain limit');
  }

  /// فلترة الصور للحذف (استبعاد المحمية)
  static List<String> filterImagesForDeletion(List<String> imagesToDelete) {
    final filteredImages =
        imagesToDelete.where((url) => !_protectedImages.contains(url)).toList();

    final protectedCount = imagesToDelete.length - filteredImages.length;

    if (protectedCount > 0) {
      debugPrint(
          '🛡️ Protected $protectedCount home page images from deletion');
    }

    return filteredImages;
  }

  /// تنظيف دوري للصور المحمية
  static void _startPeriodicCleanup() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(const Duration(minutes: 30), (_) {
      _performMaintenanceCleanup();
    });
  }

  /// تنظيف صيانة للصور القديمة جداً
  static void _performMaintenanceCleanup() {
    // الاحتفاظ بآخر 80 صورة فقط كل 30 دقيقة
    if (_homePageImages.length > 80) {
      final imagesList = _homePageImages.toList();
      final imagesToRemove = imagesList.length - 80;

      for (int i = 0; i < imagesToRemove; i++) {
        final imageToRemove = imagesList[i];
        _homePageImages.remove(imageToRemove);
        _protectedImages.remove(imageToRemove);
      }

      debugPrint(
          '🧹 Maintenance cleanup: removed $imagesToRemove old protected images');
    }
  }

  /// الحصول على إحصائيات الحماية
  static Map<String, dynamic> getProtectionStats() {
    final sourceStats = <String, int>{};

    for (final imageUrl in _homePageImages) {
      final source = _detectImageSource(imageUrl);
      sourceStats[source] = (sourceStats[source] ?? 0) + 1;
    }

    return {
      'totalProtectedImages': _protectedImages.length,
      'homePageImages': _homePageImages.length,
      'maxAllowed': _maxHomePageImages,
      'sourceBreakdown': sourceStats,
      'protectionRate':
          '${((_protectedImages.length / _maxHomePageImages) * 100).toStringAsFixed(1)}%',
    };
  }

  /// تحديث حد الصور المحمية
  static void updateImageLimit(int newLimit) {
    _maxHomePageImages = newLimit;
    _enforceImageLimit();
    debugPrint('📊 Updated max protected images to: $newLimit');
  }

  /// تنظيف الذاكرة عند إغلاق التطبيق
  static void dispose() {
    _cleanupTimer?.cancel();
    _homePageImages.clear();
    _protectedImages.clear();
    _isInitialized = false;
    debugPrint('🛡️ Home page image protector disposed');
  }

  /// اختصار URL للعرض
  static String _getShortUrl(String url) {
    if (url.length <= 50) return url;
    return '${url.substring(0, 25)}...${url.substring(url.length - 20)}';
  }

  /// فرض حماية طارئة لصور معينة
  static void emergencyProtect(List<String> criticalImages) {
    for (final imageUrl in criticalImages) {
      _protectedImages.add(imageUrl);
      _homePageImages.add(imageUrl);
    }

    debugPrint(
        '🚨 Emergency protection applied to ${criticalImages.length} critical images');
  }

  /// إزالة الحماية من صورة معينة
  static void unprotectImage(String imageUrl) {
    final wasProtected = _protectedImages.remove(imageUrl);
    _homePageImages.remove(imageUrl);

    if (wasProtected) {
      debugPrint('🔓 Unprotected image: ${_getShortUrl(imageUrl)}');
    }
  }

  /// فحص سلامة النظام
  static bool validateSystem() {
    final isValid = _isInitialized &&
        _protectedImages.length <= _maxHomePageImages &&
        _homePageImages.every((image) => _protectedImages.contains(image));

    if (!isValid) {
      debugPrint('⚠️ Home page image protector system validation failed');
    }

    return isValid;
  }
}
