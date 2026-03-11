/*import 'dart:async';
import 'package:flutter/material.dart';
import '../../features/app/memory_management_helper.dart';

/// مساعد تحسين الأداء للتطبيق
class PerformanceHelper {
  /// فحص الذاكرة وتحسين الأداء في initState
  static Future<void> initializeWithMemoryCheck(String componentName) async {
    try {
      // فحص سريع للذاكرة
      MemoryManagementHelper.quickMemoryCheck();

      debugPrint('✅ $componentName initialized with memory check');
    } catch (e) {
      debugPrint('❌ Error in $componentName memory initialization: $e');
    }
  }

  /// تحسين أداء الصفحات
  static Future<void> optimizePagePerformance(String pageName) async {
    try {
      // فحص شامل للذاكرة للصفحات
      await MemoryManagementHelper.checkAndCleanMemory();

      debugPrint('📄 Page $pageName performance optimized');
    } catch (e) {
      debugPrint('❌ Error optimizing $pageName performance: $e');
    }
  }

  /// تنظيف الموارد عند dispose
  static void disposeWithCleanup(String componentName) {
    try {
      MemoryManagementHelper.cleanupOnPageDispose();

      debugPrint('🧹 $componentName disposed with cleanup');
    } catch (e) {
      debugPrint('❌ Error in $componentName dispose: $e');
    }
  }
}
*/
