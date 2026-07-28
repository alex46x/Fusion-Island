import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class StorageService {
  static late Box _settingsBox;
  static late Box _calibrationBox;
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static Future<void> init() async {
    await Hive.initFlutter();
    _settingsBox = await Hive.openBox(AppConstants.settingsBox);
    _calibrationBox = await Hive.openBox(AppConstants.calibrationBox);
  }

  // General Settings
  static Future<void> setString(String key, String value) async => await _settingsBox.put(key, value);
  static String? getString(String key) => _settingsBox.get(key) as String?;

  static Future<void> setBool(String key, bool value) async => await _settingsBox.put(key, value);
  static bool getBool(String key, {bool defaultValue = false}) => (_settingsBox.get(key) as bool?) ?? defaultValue;

  static Future<void> setDouble(String key, double value) async => await _settingsBox.put(key, value);
  static double getDouble(String key, {double defaultValue = 0.0}) => (_settingsBox.get(key) as double?) ?? defaultValue;

  // Calibration Profile Storage
  static Future<void> saveCalibrationProfile(String profileName, Map<String, dynamic> data) async {
    await _calibrationBox.put(profileName, data);
  }

  static Map<String, dynamic>? getCalibrationProfile(String profileName) {
    final res = _calibrationBox.get(profileName);
    if (res != null) {
      return Map<String, dynamic>.from(res as Map);
    }
    return null;
  }

  // Secure Storage
  static Future<void> setSecureString(String key, String value) async => await _secureStorage.write(key: key, value: value);
  static Future<String?> getSecureString(String key) async => await _secureStorage.read(key: key);
}
