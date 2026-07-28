package com.fusionisland.app

import android.app.*
import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.graphics.Color
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.view.DisplayCutout
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import androidx.core.app.NotificationCompat

class OverlayService : Service() {
    private var windowManager: WindowManager? = null
    private var overlayView: View? = null
    private var layoutParams: WindowManager.LayoutParams? = null

    companion object {
        @Volatile
        private var instance: OverlayService? = null

        var currentWidthDp: Double = 200.0
        var currentHeightDp: Double = 36.0
        var currentOffsetXDp: Double = 0.0
        var currentOffsetYDp: Double = 12.0
        var currentCornerRadiusDp: Double = 20.0

        fun updateConfig(width: Double, height: Double, offsetX: Double, offsetY: Double, radius: Double) {
            currentWidthDp = width
            currentHeightDp = height
            currentOffsetXDp = offsetX
            currentOffsetYDp = offsetY
            currentCornerRadiusDp = radius

            instance?.applyConfigUpdate()
        }

        fun isRunning(): Boolean = instance != null
    }

    override fun onCreate() {
        super.onCreate()
        instance = this
        createNotificationChannel()
        startForeground(1001, buildForegroundNotification())
        setupOverlayWindow()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return START_STICKY
    }

    private fun setupOverlayWindow() {
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val density = resources.displayMetrics.density

        val layoutType = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE
        }

        val flags = WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                WindowManager.LayoutParams.FLAG_LAYOUT_INSET_DECOR

        layoutParams = WindowManager.LayoutParams(
            (currentWidthDp * density).toInt(),
            (currentHeightDp * density).toInt(),
            layoutType,
            flags,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.CENTER_HORIZONTAL
            x = (currentOffsetXDp * density).toInt()
            y = (currentOffsetYDp * density).toInt()

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                layoutInDisplayCutoutMode = WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES
            }
        }

        overlayView = View(this).apply {
            setBackgroundColor(Color.BLACK)
        }

        try {
            if (overlayView?.parent == null) {
                windowManager?.addView(overlayView, layoutParams)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun applyConfigUpdate() {
        val serviceView = overlayView ?: return
        val manager = windowManager ?: return
        val params = layoutParams ?: return
        val density = resources.displayMetrics.density

        params.width = (currentWidthDp * density).toInt()
        params.height = (currentHeightDp * density).toInt()
        params.x = (currentOffsetXDp * density).toInt()
        params.y = (currentOffsetYDp * density).toInt()

        try {
            manager.updateViewLayout(serviceView, params)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        // Adjust overlay position cleanly on screen rotation
        applyConfigUpdate()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "fusion_island_overlay",
                "Fusion Island Engine",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Running high-performance dynamic island floating overlay"
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    private fun buildForegroundNotification(): Notification {
        return NotificationCompat.Builder(this, "fusion_island_overlay")
            .setContentTitle("Fusion Island Active")
            .setContentText("Dynamic Island floating window is active")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(true)
            .build()
    }

    override fun onDestroy() {
        super.onDestroy()
        instance = null
        if (overlayView != null && windowManager != null) {
            try {
                windowManager?.removeView(overlayView)
            } catch (e: Exception) {
                e.printStackTrace()
            }
            overlayView = null
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
