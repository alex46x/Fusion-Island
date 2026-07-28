package com.fusionisland.app

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val OVERLAY_CHANNEL = "com.fusionisland.app/overlay"
    private val SYSTEM_CHANNEL = "com.fusionisland.app/system_status"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

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

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SYSTEM_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getSystemMetrics" -> {
                    val metrics = HashMap<String, Any>()
                    metrics["batteryLevel"] = 85
                    metrics["isCharging"] = true
                    metrics["wifiConnected"] = true
                    result.success(metrics)
                }
                else -> result.notImplemented()
            }
        }
    }
}
