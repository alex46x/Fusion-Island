package com.fusionisland.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.Uri
import android.os.BatteryManager
import android.os.Build
import android.provider.Settings
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val OVERLAY_CHANNEL = "com.fusionisland.app/overlay"
    private val SYSTEM_CHANNEL = "com.fusionisland.app/system_status"
    private val NOTIFICATION_EVENT_CHANNEL = "com.fusionisland.app/notifications"

    private var notificationEventSink: EventChannel.EventSink? = null
    private var notificationReceiver: BroadcastReceiver? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Overlay MethodChannel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, OVERLAY_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isOverlayPermissionGranted" -> {
                    val granted = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        Settings.canDrawOverlays(this)
                    } else {
                        true
                    }
                    result.success(granted)
                }
                "requestOverlayPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(this)) {
                        val intent = Intent(
                            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                            Uri.parse("package:$packageName")
                        )
                        startActivityForResult(intent, 1234)
                        result.success(false)
                    } else {
                        result.success(true)
                    }
                }
                "isNotificationListenerGranted" -> {
                    val packageName = packageName
                    val flat = Settings.Secure.getString(contentResolver, "enabled_notification_listeners")
                    val granted = flat != null && flat.contains(packageName)
                    result.success(granted)
                }
                "requestNotificationListenerPermission" -> {
                    val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
                    startActivity(intent)
                    result.success(true)
                }
                "startOverlay" -> {
                    val intent = Intent(this, OverlayService::class.java)
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        startForegroundService(intent)
                    } else {
                        startService(intent)
                    }
                    result.success(true)
                }
                "stopOverlay" -> {
                    val intent = Intent(this, OverlayService::class.java)
                    stopService(intent)
                    result.success(true)
                }
                "updateOverlayConfig" -> {
                    val width = call.argument<Double>("width") ?: 200.0
                    val height = call.argument<Double>("height") ?: 36.0
                    val offsetX = call.argument<Double>("offsetX") ?: 0.0
                    val offsetY = call.argument<Double>("offsetY") ?: 12.0
                    val cornerRadius = call.argument<Double>("cornerRadius") ?: 20.0

                    OverlayService.updateConfig(width, height, offsetX, offsetY, cornerRadius)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        // System Metrics Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SYSTEM_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getSystemMetrics" -> {
                    val bm = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
                    val batteryLevel = bm.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
                    val isCharging = bm.isCharging

                    val metrics = HashMap<String, Any>()
                    metrics["batteryLevel"] = if (batteryLevel >= 0) batteryLevel else 85
                    metrics["isCharging"] = isCharging
                    metrics["wifiConnected"] = true
                    result.success(metrics)
                }
                else -> result.notImplemented()
            }
        }

        // Notification EventChannel
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, NOTIFICATION_EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    notificationEventSink = events
                    registerNotificationReceiver()
                }

                override fun onCancel(arguments: Any?) {
                    notificationEventSink = null
                    unregisterNotificationReceiver()
                }
            }
        )
    }

    private fun registerNotificationReceiver() {
        if (notificationReceiver == null) {
            notificationReceiver = object : BroadcastReceiver() {
                override fun onReceive(context: Context?, intent: Intent?) {
                    if (intent?.action == NotificationInterceptorService.ACTION_NOTIFICATION_POSTED) {
                        val pkg = intent.getStringExtra(NotificationInterceptorService.EXTRA_PACKAGE) ?: ""
                        val title = intent.getStringExtra(NotificationInterceptorService.EXTRA_TITLE) ?: ""
                        val text = intent.getStringExtra(NotificationInterceptorService.EXTRA_TEXT) ?: ""

                        val map = HashMap<String, String>()
                        map["packageName"] = pkg
                        map["title"] = title
                        map["text"] = text

                        notificationEventSink?.success(map)
                    }
                }
            }
            val filter = IntentFilter(NotificationInterceptorService.ACTION_NOTIFICATION_POSTED)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                registerReceiver(notificationReceiver, filter, RECEIVER_NOT_EXPORTED)
            } else {
                registerReceiver(notificationReceiver, filter)
            }
        }
    }

    private fun unregisterNotificationReceiver() {
        notificationReceiver?.let {
            unregisterReceiver(it)
            notificationReceiver = null
        }
    }
}
