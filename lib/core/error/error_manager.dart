class ErrorManager {
  static final Map<String, int> _retryCounts = {};

  /// تحدد هل يجب إعادة المحاولة بناءً على كود الخطأ واسم الحدث
  static bool shouldRetry(String eventName, int statusCode) {
    int maxRetries = 1;

    if (statusCode == 0 ||
        statusCode == 429 ||
        statusCode == 502 ||
        statusCode == 503 ||
        statusCode == 504) {
      maxRetries = 2;
    }
    int currentCount = _retryCounts[eventName] ?? 0;
    bool canRetry = currentCount < maxRetries;

    return canRetry;
  }

  /// زيادة عداد المحاولات
  static void incrementRetry(String eventName) {
    _retryCounts[eventName] = (_retryCounts[eventName] ?? 0) + 1;
  }

  /// تصفير عداد المحاولات
  static void resetRetry(String eventName) {
    _retryCounts[eventName] = 0;
  }

  /// الحصول على عدد المحاولات الحالي
  static int getRetryCount(String eventName) {
    return _retryCounts[eventName] ?? 0;
  }

  /// تنظيف جميع العدادات
  static void clearAllRetries() {
    _retryCounts.clear();
  }
}
