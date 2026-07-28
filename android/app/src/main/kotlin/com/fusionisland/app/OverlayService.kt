package com.fusionisland.app

import android.app.*
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import androidx.core.app.NotificationCompat

class OverlayService : Service() {
    private var windowManager: WindowManager? = null
    private var overlayView: View? = null
    private var layoutParams: WindowManager.LayoutParams? = null

    companion object {
        private var instance: OverlayService? = null
        var currentWidth: Int = 200
        var currentHeight: Int = 36
        var currentOffsetX: Int = 0
        var currentOffsetY: Int = 12

        fun updateConfig(width: Double, height: Double, offsetX: Double, offsetY: Double, radius: Double) {
            instance?.let { service ->
                val density = service.resources.displayMetrics.density
                currentWidth = (width * density).toInt()
                currentHeight = (height * density).toInt()
                currentOffsetX = (offsetX * density).toInt()
                currentOffsetY = (offsetY * density).toInt()

                service.layoutParams?.let { params ->
                    params.width = currentWidth
                    params.height = currentHeight
                    params.x = currentOffsetX
                    params.y = currentOffsetY
                    service.windowManager?.updateViewLayout(service.overlayView, params)
                }
            }
        }
    }

    override fun onCreate() {
        super.onCreate()
        instance = this
        createNotificationChannel()
        startForeground(1001, buildForegroundNotification())
        setupOverlayWindow()
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

        layoutParams = WindowManager.LayoutParams(
            (currentWidth * density).toInt(),
            (currentHeight * density).toInt(),
            layoutType,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.CENTER_HORIZONTAL
            x = (currentOffsetX * density).toInt()
            y = (currentOffsetY * density).toInt()
        }

        overlayView = View(this).apply {
            setBackgroundColor(Color.BLACK)
        }

        try {
            windowManager?.addView(overlayView, layoutParams)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "fusion_island_overlay",
                "Fusion Island Service",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Running dynamic island floating overlay"
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
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
