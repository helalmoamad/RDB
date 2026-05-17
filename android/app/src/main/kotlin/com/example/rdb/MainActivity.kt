package com.example.rdb

import android.os.Bundle
import android.view.ViewGroup
import android.view.WindowManager
import android.widget.FrameLayout
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.util.Log

class MainActivity : FlutterFragmentActivity() {
    companion object {
        private const val CHANNEL = "com.example.rdb/security"
        private const val TAG = "SecurityService"
    }

    private var overlayView: FrameLayout? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        ensureOverlayViewCreated()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hideContent" -> {
                        hideContent()
                        result.success(null)
                    }
                    "showContent" -> {
                        showContent()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun hideContent() {
        try {
            // تفعيل FLAG_SECURE لمنع التقاط الشاشة والـ screenshots
            window.setFlags(
                WindowManager.LayoutParams.FLAG_SECURE,
                WindowManager.LayoutParams.FLAG_SECURE
            )
            Log.d(TAG, "تم تفعيل FLAG_SECURE")

            // إضافة overlay أسود داخل محتوى الـ Activity نفسه
            ensureOverlayViewCreated()
            val root = findViewById<ViewGroup>(android.R.id.content)
            val overlay = overlayView
            if (overlay != null && overlay.parent == null) {
                val params = FrameLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.MATCH_PARENT,
                )
                root.addView(overlay, params)
                Log.d(TAG, "تم إضافة overlay أسود")
            }
        } catch (e: Exception) {
            Log.e(TAG, "خطأ في hideContent: ${e.message}", e)
        }
    }

    private fun showContent() {
        try {
            // إزالة FLAG_SECURE
            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
            Log.d(TAG, "تم إزالة FLAG_SECURE")

            // إزالة الـ overlay الأسود
            val overlay = overlayView
            val parent = overlay?.parent
            if (overlay != null && parent is ViewGroup) {
                parent.removeView(overlay)
                Log.d(TAG, "تم إزالة overlay أسود")
            }
        } catch (e: Exception) {
            Log.e(TAG, "خطأ في showContent: ${e.message}", e)
        }
    }

    private fun ensureOverlayViewCreated() {
        if (overlayView == null) {
            overlayView = FrameLayout(this).apply {
                setBackgroundColor(android.graphics.Color.BLACK)
                isClickable = true
                isFocusable = true
            }
        }
    }

    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        // يُستدعى مبكراً عند الضغط على Home/Recent قبل لقطة التطبيقات المصغرة غالباً.
        Log.d(TAG, "onUserLeaveHint: استدعاء hideContent")
        hideContent()
    }

    override fun onPause() {
        super.onPause()
        Log.d(TAG, "onPause: استدعاء hideContent")
        hideContent()
    }

    override fun onResume() {
        super.onResume()
        Log.d(TAG, "onResume: استدعاء showContent")
        showContent()
    }

    override fun onDestroy() {
        super.onDestroy()
        // تنظيف الـ overlay عند إغلاق التطبيق
        val overlay = overlayView
        val parent = overlay?.parent
        if (overlay != null && parent is ViewGroup) {
            try {
                parent.removeView(overlay)
            } catch (e: Exception) {
                Log.e(TAG, "خطأ في تنظيف overlay: ${e.message}", e)
            }
        }
        overlayView = null
    }
}

