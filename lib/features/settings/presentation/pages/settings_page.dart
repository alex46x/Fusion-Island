import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/storage/storage_service.dart';

final selectedThemeModeProvider = StateProvider<ThemeModeOption>((ref) => ThemeModeOption.dark);
final mediaModuleEnabledProvider = StateProvider<bool>((ref) => StorageService.getBool('module_media', defaultValue: true));
final notificationModuleEnabledProvider = StateProvider<bool>((ref) => StorageService.getBool('module_notification', defaultValue: true));
final callsModuleEnabledProvider = StateProvider<bool>((ref) => StorageService.getBool('module_calls', defaultValue: true));

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(selectedThemeModeProvider);
    final mediaEnabled = ref.watch(mediaModuleEnabledProvider);
    final notificationEnabled = ref.watch(notificationModuleEnabledProvider);
    final callsEnabled = ref.watch(callsModuleEnabledProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings & Configuration', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Section: Theme Engine
          Text('Theme Engine', style: GoogleFonts.outfit(color: AppTheme.primaryCyan, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          Card(
            child: RadioGroup<ThemeModeOption>(
              groupValue: themeMode,
              onChanged: (val) {
                if (val != null) {
                  ref.read(selectedThemeModeProvider.notifier).state = val;
                }
              },
              child: Column(
                children: ThemeModeOption.values.map((option) {
                  return RadioListTile<ThemeModeOption>(
                    title: Text(
                      _getThemeName(option),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    activeColor: AppTheme.primaryCyan,
                    value: option,
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Section: Plugin System (Module Toggles)
          Text('Modular Plugin System', style: GoogleFonts.outfit(color: AppTheme.primaryCyan, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Media Session Controller', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Spotify, Apple Music, YouTube Music controls', style: TextStyle(color: Colors.white38, fontSize: 12)),
                  value: mediaEnabled,
                  activeTrackColor: AppTheme.primaryCyan,
                  onChanged: (val) {
                    ref.read(mediaModuleEnabledProvider.notifier).state = val;
                    StorageService.setBool('module_media', val);
                  },
                ),
                const Divider(color: Colors.white12, height: 1),
                SwitchListTile(
                  title: const Text('Notification Listener Interceptor', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Intercept app notifications & quick actions', style: TextStyle(color: Colors.white38, fontSize: 12)),
                  value: notificationEnabled,
                  activeTrackColor: AppTheme.primaryCyan,
                  onChanged: (val) {
                    ref.read(notificationModuleEnabledProvider.notifier).state = val;
                    StorageService.setBool('module_notification', val);
                  },
                ),
                const Divider(color: Colors.white12, height: 1),
                SwitchListTile(
                  title: const Text('Phone Calls & Telephony State', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Incoming/Outgoing/Missed call pill', style: TextStyle(color: Colors.white38, fontSize: 12)),
                  value: callsEnabled,
                  activeTrackColor: AppTheme.primaryCyan,
                  onChanged: (val) {
                    ref.read(callsModuleEnabledProvider.notifier).state = val;
                    StorageService.setBool('module_calls', val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section: About & System Information
          Text('System Information', style: GoogleFonts.outfit(color: AppTheme.primaryCyan, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _InfoRow(label: 'App Version', value: '1.0.0 (Commercial Release)'),
                  Divider(color: Colors.white12, height: 16),
                  _InfoRow(label: 'Target Android SDK', value: 'Android 15 / 16 (API 35/36)'),
                  Divider(color: Colors.white12, height: 16),
                  _InfoRow(label: 'Min Supported OS', value: 'Android 10 (API 29)'),
                  Divider(color: Colors.white12, height: 16),
                  _InfoRow(label: 'Architecture', value: 'Clean Architecture (Riverpod + Native Kotlin)'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getThemeName(ThemeModeOption option) {
    switch (option) {
      case ThemeModeOption.glass:
        return 'Glassmorphism Blur';
      case ThemeModeOption.dark:
        return 'Dark High-Contrast';
      case ThemeModeOption.amoled:
        return 'AMOLED Pure Black';
      case ThemeModeOption.materialYou:
        return 'Material You Dynamic Color';
      case ThemeModeOption.rgbCyberpunk:
        return 'RGB Cyberpunk Neon';
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 13)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
