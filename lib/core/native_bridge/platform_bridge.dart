import 'dart:async';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';

class PlatformBridge {
  static const MethodChannel _overlayChannel = MethodChannel(AppConstants.overlayChannel);
  static const MethodChannel _systemChannel = MethodChannel(AppConstants.systemStatusChannel);
  static const EventChannel _notificationEventChannel = EventChannel('${AppConstants.notificationChannel}/stream');
  static const EventChannel _mediaEventChannel = EventChannel('${AppConstants.mediaChannel}/stream');

  /// Check if Overlay permission (SYSTEM_ALERT_WINDOW) is granted
  static Future<bool> isOverlayPermissionGranted() async {
    try {
      final bool result = await _overlayChannel.invokeMethod('isOverlayPermissionGranted');
      return result;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Request Overlay permission
  static Future<bool> requestOverlayPermission() async {
    try {
      final bool result = await _overlayChannel.invokeMethod('requestOverlayPermission');
      return result;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Start Floating Dynamic Island Overlay Service
  static Future<bool> startOverlayService() async {
    try {
      final bool result = await _overlayChannel.invokeMethod('startOverlay');
      return result;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Stop Floating Dynamic Island Overlay Service
  static Future<bool> stopOverlayService() async {
    try {
      final bool result = await _overlayChannel.invokeMethod('stopOverlay');
      return result;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Update Floating Dynamic Island Parameters (Width, Height, OffsetX, OffsetY, CornerRadius)
  static Future<void> updateOverlayConfig({
    required double width,
    required double height,
    required double offsetX,
    required double offsetY,
    required double cornerRadius,
  }) async {
    try {
      await _overlayChannel.invokeMethod('updateOverlayConfig', {
        'width': width,
        'height': height,
        'offsetX': offsetX,
        'offsetY': offsetY,
        'cornerRadius': cornerRadius,
      });
    } on PlatformException catch (_) {}
  }

  /// Stream of notification events from native NotificationListenerService
  static Stream<Map<String, dynamic>> get notificationStream {
    return _notificationEventChannel
        .receiveBroadcastStream()
        .map((dynamic event) => Map<String, dynamic>.from(event as Map));
  }

  /// Stream of media session events (playing track, cover art, state)
  static Stream<Map<String, dynamic>> get mediaStream {
    return _mediaEventChannel
        .receiveBroadcastStream()
        .map((dynamic event) => Map<String, dynamic>.from(event as Map));
  }

  /// Get hardware metrics (battery, memory, wifi)
  static Future<Map<String, dynamic>> getSystemMetrics() async {
    try {
      final Map<dynamic, dynamic> result = await _systemChannel.invokeMethod('getSystemMetrics');
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (_) {
      return {};
    }
  }
}
