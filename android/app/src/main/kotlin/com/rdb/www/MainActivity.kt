package com.rdb.www

import android.os.Bundle
import android.util.Log
import android.view.ViewGroup
import android.view.WindowManager
import android.widget.FrameLayout
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    companion object {
        private const val CHANNEL = "com.rdb.www/security"
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
                overlay.bringToFront()
            }
            overlay?.visibility = android.view.View.VISIBLE
            Log.d(TAG, "تم إخفاء المحتوى بإضافة Overlay")
        } catch (e: Exception) {
            Log.e(TAG, "خطأ أثناء إخفاء المحتوى", e)
        }
    }

    private fun showContent() {
        try {
            // إزالة FLAG_SECURE للسماح بعرض المحتوى طبيعياً
            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
            Log.d(TAG, "تم إزالة FLAG_SECURE")

            overlayView?.visibility = android.view.View.GONE
            Log.d(TAG, "تم إظهار المحتوى وإخفاء Overlay")
        } catch (e: Exception) {
            Log.e(TAG, "خطأ أثناء إظهار المحتوى", e)
        }
    }

    private fun ensureOverlayViewCreated() {
        if (overlayView == null) {
            overlayView = FrameLayout(this).apply {
                setBackgroundColor(android.graphics.Color.BLACK)
                layoutParams = FrameLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.MATCH_PARENT,
                )
                isClickable = true
                isFocusable = true
                visibility = android.view.View.GONE
            }
        }
    }
}