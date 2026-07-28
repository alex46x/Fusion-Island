import 'package:flutter/services.dart';

class PlatformBridge {
  static const MethodChannel _overlayChannel =
      MethodChannel('com.fusionisland.app/overlay');
  static const MethodChannel _systemChannel =
      MethodChannel('com.fusionisland.app/system_status');
  static const EventChannel _notificationEventChannel =
      EventChannel('com.fusionisland.app/notifications');

  /// Check if Overlay permission is granted
  static Future<bool> isOverlayPermissionGranted() async {
    try {
      final bool result =
          await _overlayChannel.invokeMethod('isOverlayPermissionGranted');
      return result;
    } on PlatformException {
      return false;
    }
  }

  /// Request Overlay permission
  static Future<bool> requestOverlayPermission() async {
    try {
      final bool result =
          await _overlayChannel.invokeMethod('requestOverlayPermission');
      return result;
    } on PlatformException {
      return false;
    }
  }

  /// Check if Notification Listener permission is granted
  static Future<bool> isNotificationListenerGranted() async {
    try {
      final bool result =
          await _overlayChannel.invokeMethod('isNotificationListenerGranted');
      return result;
    } on PlatformException {
      return false;
    }
  }

  /// Request Notification Listener permission
  static Future<void> requestNotificationListenerPermission() async {
    try {
      await _overlayChannel.invokeMethod('requestNotificationListenerPermission');
    } on PlatformException {
      // Platform unsupported or error
    }
  }

  /// Start Floating Overlay Foreground Service
  static Future<bool> startOverlayService() async {
    try {
      final bool result =
          await _overlayChannel.invokeMethod('startOverlay');
      return result;
    } on PlatformException {
      return false;
    }
  }

  /// Stop Floating Overlay Foreground Service
  static Future<bool> stopOverlayService() async {
    try {
      final bool result =
          await _overlayChannel.invokeMethod('stopOverlay');
      return result;
    } on PlatformException {
      return false;
    }
  }

  /// Update Floating Overlay Configuration
  static Future<bool> updateOverlayConfig({
    required double width,
    required double height,
    required double offsetX,
    required double offsetY,
    required double cornerRadius,
  }) async {
    try {
      final bool result = await _overlayChannel.invokeMethod(
        'updateOverlayConfig',
        {
          'width': width,
          'height': height,
          'offsetX': offsetX,
          'offsetY': offsetY,
          'cornerRadius': cornerRadius,
        },
      );
      return result;
    } on PlatformException {
      return false;
    }
  }

  /// Fetch system battery, network, and memory metrics
  static Future<Map<String, dynamic>> getSystemMetrics() async {
    try {
      final Map<dynamic, dynamic>? result =
          await _systemChannel.invokeMethod('getSystemMetrics');
      if (result != null) {
        return Map<String, dynamic>.from(result);
      }
    } on PlatformException {
      // Fallback dummy metrics
    }
    return {
      'batteryLevel': 85,
      'isCharging': true,
      'wifiConnected': true,
    };
  }

  /// Stream of incoming notifications from Android NotificationListenerService
  static Stream<Map<String, dynamic>> get notificationStream {
    return _notificationEventChannel
        .receiveBroadcastStream()
        .map((event) => Map<String, dynamic>.from(event as Map));
  }
}
