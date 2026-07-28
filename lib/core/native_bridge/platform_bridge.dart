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
    } on MissingPluginException {
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
    } on MissingPluginException {
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
    } on MissingPluginException {
      return false;
    }
  }

  /// Request Notification Listener permission
  static Future<void> requestNotificationListenerPermission() async {
    try {
      await _overlayChannel.invokeMethod('requestNotificationListenerPermission');
    } catch (_) {}
  }

  /// Check if Battery Optimization is ignored
  static Future<bool> isBatteryOptimizationIgnored() async {
    try {
      final bool result =
          await _overlayChannel.invokeMethod('isBatteryOptimizationIgnored');
      return result;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Request to ignore Battery Optimization
  static Future<void> requestIgnoreBatteryOptimization() async {
    try {
      await _overlayChannel.invokeMethod('requestIgnoreBatteryOptimization');
    } catch (_) {}
  }

  /// Open Android Application Details Settings Page
  static Future<void> openAppSettings() async {
    try {
      await _overlayChannel.invokeMethod('openAppSettings');
    } catch (_) {}
  }

  /// Start Floating Overlay Foreground Service
  static Future<bool> startOverlayService() async {
    try {
      final bool result =
          await _overlayChannel.invokeMethod('startOverlay');
      return result;
    } catch (_) {
      return false;
    }
  }

  /// Stop Floating Overlay Foreground Service
  static Future<bool> stopOverlayService() async {
    try {
      final bool result =
          await _overlayChannel.invokeMethod('stopOverlay');
      return result;
    } catch (_) {
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
    } catch (_) {
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
    } catch (_) {}
    return {
      'batteryLevel': 85,
      'isCharging': true,
      'wifiConnected': true,
    };
  }

  /// Stream of incoming notifications from Android NotificationListenerService
  static Stream<Map<String, dynamic>> get notificationStream {
    try {
      return _notificationEventChannel
          .receiveBroadcastStream()
          .map((event) => Map<String, dynamic>.from(event as Map))
          .handleError((_) => const Stream.empty());
    } catch (_) {
      return const Stream.empty();
    }
  }
}
