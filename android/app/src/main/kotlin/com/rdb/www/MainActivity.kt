package com.rdb.www

import android.os.Bundle
import android.util.Log
import android.view.ViewGroup
import android.view.WindowManager
import android.widget.FrameLayout
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.renderer.FlutterUiDisplayListener
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    companion object {
        private const val CHANNEL = "com.rdb.www/security"
        private const val TAG = "SecurityService"
    }

    private var overlayView: FrameLayout? = null

    // يصبح true عند رسم Flutter أوّل إطار؛ نُبقي سبلاش النظام ظاهراً حتى ذلك.
    private var flutterUiDisplayed = false

    override fun onCreate(savedInstanceState: Bundle?) {
        // يُستدعى قبل super.onCreate() ليتولّى AndroidX SplashScreen سبلاش النظام.
        val splashScreen = installSplashScreen()
        // أبقِ سبلاش النظام (الأبيض) ظاهراً حتى يرسم Flutter أوّل إطار فعلياً،
        // لمنع الوميض الأسود من الـ SurfaceView في الفجوة بين انتهاء السبلاش وأوّل
        // إطار (ظهر على بعض أجهزة Android 12/13 مثل HiOS/TECNO).
        splashScreen.setKeepOnScreenCondition { !flutterUiDisplayed }
        super.onCreate(savedInstanceState)
        ensureOverlayViewCreated()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // علّم جهوز أوّل إطار من Flutter ليُغلَق سبلاش النظام عندها تحديداً (لا قبلها).
        flutterEngine.renderer.addIsDisplayingFlutterUiListener(
            object : FlutterUiDisplayListener {
                override fun onFlutterUiDisplayed() {
                    flutterUiDisplayed = true
                }

                override fun onFlutterUiNoLongerDisplayed() {}
            },
        )

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
        Log.d(TAG, "[DEBUG] تم استدعاء hideContent من Flutter");
        try {
            // تفعيل FLAG_SECURE لمنع التقاط الشاشة والـ screenshots
            window.setFlags(
                WindowManager.LayoutParams.FLAG_SECURE,
                WindowManager.LayoutParams.FLAG_SECURE
            )
            Log.d(TAG, "تم تفعيل FLAG_SECURE")

            // إضافة overlay أسود داخل محتوى الـ Activity نفسه
            runOnUiThread {
                Log.d(TAG, "[DEBUG] runOnUiThread: إضافة overlayView");
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
                Log.d(TAG, "تم إخفاء المحتوى بإضافة Overlay (runOnUiThread)")
            }
        } catch (e: Exception) {
            Log.e(TAG, "خطأ أثناء إخفاء المحتوى", e)
        }
    }

    private fun showContent() {
        Log.d(TAG, "[DEBUG] تم استدعاء showContent من Flutter");
        try {
            // إزالة FLAG_SECURE للسماح بعرض المحتوى طبيعياً
            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
            Log.d(TAG, "تم إزالة FLAG_SECURE")

            runOnUiThread {
                Log.d(TAG, "[DEBUG] runOnUiThread: إزالة overlayView");
                overlayView?.visibility = android.view.View.GONE
                Log.d(TAG, "تم إظهار المحتوى وإخفاء Overlay (runOnUiThread)")
            }
        } catch (e: Exception) {
            Log.e(TAG, "خطأ أثناء إظهار المحتوى", e)
        }
    }

    private fun ensureOverlayViewCreated() {
        if (overlayView == null) {
            overlayView = FrameLayout(this).apply {
                setBackgroundColor(android.graphics.Color.TRANSPARENT)
                layoutParams = FrameLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.MATCH_PARENT,
                )
                isClickable = false
                isFocusable = false
                visibility = android.view.View.GONE
            }
        }
    }
}