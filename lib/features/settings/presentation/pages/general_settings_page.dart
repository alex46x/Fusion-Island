import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/storage/storage_service.dart';
import '../../../../core/theme/app_theme.dart';

// Riverpod State Providers for General Settings
final allowTwoPopupsProvider = StateProvider<bool>((ref) => StorageService.getBool('gen_allow_two_popups', defaultValue: true));
final autoExpandProvider = StateProvider<bool>((ref) => StorageService.getBool('gen_auto_expand', defaultValue: false));
final sendRepliesProvider = StateProvider<bool>((ref) => StorageService.getBool('gen_send_replies', defaultValue: true));

final hideInForegroundProvider = StateProvider<bool>((ref) => StorageService.getBool('gen_hide_foreground', defaultValue: true));
final showInLandscapeProvider = StateProvider<bool>((ref) => StorageService.getBool('gen_show_landscape', defaultValue: true));
final showAlwaysProvider = StateProvider<bool>((ref) => StorageService.getBool('gen_show_always', defaultValue: false));
final showOnLockscreenProvider = StateProvider<bool>((ref) => StorageService.getBool('gen_show_lockscreen', defaultValue: true));
final hideNotificationPanelProvider = StateProvider<bool>((ref) => StorageService.getBool('gen_hide_notif_panel', defaultValue: true));
final hideStatusbarProvider = StateProvider<bool>((ref) => StorageService.getBool('gen_hide_statusbar', defaultValue: false));

final notifCountOptionProvider = StateProvider<int>((ref) => StorageService.getInt('gen_notif_count_option', defaultValue: 0));

final autoHideSmallTimerProvider = StateProvider<double>((ref) => StorageService.getDouble('gen_autohide_small', defaultValue: 15.0));
final autoHideExpandedTimerProvider = StateProvider<double>((ref) => StorageService.getDouble('gen_autohide_expanded', defaultValue: 10.0));
final touchOutsideCollapseProvider = StateProvider<bool>((ref) => StorageService.getBool('gen_touch_outside', defaultValue: true));

final singleTapActionProvider = StateProvider<String>((ref) => StorageService.getString('gen_single_tap_action') ?? 'Expand popup');
final longPressActionProvider = StateProvider<String>((ref) => StorageService.getString('gen_long_press_action') ?? 'Open app');
final swipeToClearProvider = StateProvider<bool>((ref) => StorageService.getBool('gen_swipe_clear', defaultValue: true));

class GeneralSettingsPage extends ConsumerWidget {
  const GeneralSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int notifCountOption = ref.watch(notifCountOptionProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'General Settings',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.primaryCyan),
            tooltip: 'Reset All',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('General Settings Reset to Default')),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // SECTION 1: Popup Settings
          _buildSectionHeader('Popup Settings'),
          Card(
            child: Column(
              children: [
                _buildSwitchTile(
                  ref,
                  title: 'Allow two popups',
                  subtitle: 'Show a second popup if multiple notifications arrive simultaneously',
                  provider: allowTwoPopupsProvider,
                  storageKey: 'gen_allow_two_popups',
                ),
                const Divider(height: 1, color: Colors.white12),
                _buildSwitchTile(
                  ref,
                  title: 'Auto expand',
                  subtitle: 'Automatically expand notifications from selected apps',
                  provider: autoExpandProvider,
                  storageKey: 'gen_auto_expand',
                ),
                const Divider(height: 1, color: Colors.white12),
                _buildSwitchTile(
                  ref,
                  title: 'Send replies',
                  subtitle: 'Allow sending short replies directly from the popup if supported',
                  provider: sendRepliesProvider,
                  storageKey: 'gen_send_replies',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // SECTION 2: Display Settings
          _buildSectionHeader('Display Settings'),
          Card(
            child: Column(
              children: [
                _buildSwitchTile(
                  ref,
                  title: 'Hide in foreground',
                  subtitle: 'Hide popup if the same app is currently in foreground',
                  provider: hideInForegroundProvider,
                  storageKey: 'gen_hide_foreground',
                ),
                const Divider(height: 1, color: Colors.white12),
                _buildSwitchTile(
                  ref,
                  title: 'Show in landscape',
                  subtitle: 'Allow floating popup when screen is in landscape mode',
                  provider: showInLandscapeProvider,
                  storageKey: 'gen_show_landscape',
                ),
                const Divider(height: 1, color: Colors.white12),
                _buildSwitchTile(
                  ref,
                  title: 'Show always',
                  subtitle: 'Always show small compact popup to simulate camera cutout',
                  provider: showAlwaysProvider,
                  storageKey: 'gen_show_always',
                ),
                const Divider(height: 1, color: Colors.white12),
                _buildSwitchTile(
                  ref,
                  title: 'Show on lockscreen',
                  subtitle: 'Display floating overlay on device lockscreen',
                  provider: showOnLockscreenProvider,
                  storageKey: 'gen_show_lockscreen',
                ),
                const Divider(height: 1, color: Colors.white12),
                _buildSwitchTile(
                  ref,
                  title: 'Notification panel',
                  subtitle: 'Hide popup when system notification panel is open',
                  provider: hideNotificationPanelProvider,
                  storageKey: 'gen_hide_notif_panel',
                ),
                const Divider(height: 1, color: Colors.white12),
                _buildSwitchTile(
                  ref,
                  title: 'Hide statusbar',
                  subtitle: 'Hide statusbar when system event popup opens',
                  provider: hideStatusbarProvider,
                  storageKey: 'gen_hide_statusbar',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // SECTION 3: Notification Count
          _buildSectionHeader('Notification Count'),
          Card(
            child: RadioGroup<int>(
              groupValue: notifCountOption,
              onChanged: (val) {
                if (val != null) {
                  ref.read(notifCountOptionProvider.notifier).state = val;
                  StorageService.setInt('gen_notif_count_option', val);
                }
              },
              child: const Column(
                children: [
                  RadioListTile<int>(
                    title: Text('Show latest notification', style: TextStyle(color: Colors.white, fontSize: 14)),
                    value: 0,
                    activeColor: AppTheme.primaryCyan,
                  ),
                  Divider(height: 1, color: Colors.white12),
                  RadioListTile<int>(
                    title: Text('Show all notifications', style: TextStyle(color: Colors.white, fontSize: 14)),
                    value: 1,
                    activeColor: AppTheme.primaryCyan,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // SECTION 4: Auto Hide Timers
          _buildSectionHeader('Auto Hide Timers'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Auto hide - Small popup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text('${ref.watch(autoHideSmallTimerProvider).round()} seconds', style: const TextStyle(color: AppTheme.primaryCyan, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Slider(
                    value: ref.watch(autoHideSmallTimerProvider),
                    min: 1,
                    max: 60,
                    divisions: 59,
                    activeColor: AppTheme.primaryCyan,
                    onChanged: (val) {
                      ref.read(autoHideSmallTimerProvider.notifier).state = val;
                      StorageService.setDouble('gen_autohide_small', val);
                    },
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Auto hide - Expanded popup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text('${ref.watch(autoHideExpandedTimerProvider).round()} seconds', style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Slider(
                    value: ref.watch(autoHideExpandedTimerProvider),
                    min: 1,
                    max: 60,
                    divisions: 59,
                    activeColor: AppTheme.primaryBlue,
                    onChanged: (val) {
                      ref.read(autoHideExpandedTimerProvider.notifier).state = val;
                      StorageService.setDouble('gen_autohide_expanded', val);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // SECTION 5: Interaction - Small Popup
          _buildSectionHeader('Interaction - Small Popup'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildDropdownRow(
                    ref,
                    title: 'Single Tap',
                    value: ref.watch(singleTapActionProvider),
                    items: const ['Expand popup', 'Open app', 'Dismiss', 'Pause / Play', 'Next song'],
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(singleTapActionProvider.notifier).state = val;
                        StorageService.setString('gen_single_tap_action', val);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 12),
                  _buildDropdownRow(
                    ref,
                    title: 'Long Press',
                    value: ref.watch(longPressActionProvider),
                    items: const ['Open app', 'Expand popup', 'Take screenshot', 'Lock screen'],
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(longPressActionProvider.notifier).state = val;
                        StorageService.setString('gen_long_press_action', val);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // SECTION 6: Interaction - Expanded Popup
          _buildSectionHeader('Interaction - Expanded Popup'),
          Card(
            child: Column(
              children: [
                _buildSwitchTile(
                  ref,
                  title: 'Swipe to clear / collapse',
                  subtitle: 'Swipe up or sideways to collapse expanded popup',
                  provider: swipeToClearProvider,
                  storageKey: 'gen_swipe_clear',
                ),
                const Divider(height: 1, color: Colors.white12),
                _buildSwitchTile(
                  ref,
                  title: 'When touching outside',
                  subtitle: 'Collapse popup when user touches outside the island bounds',
                  provider: touchOutsideCollapseProvider,
                  storageKey: 'gen_touch_outside',
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          color: AppTheme.primaryCyan,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    WidgetRef ref, {
    required String title,
    required String subtitle,
    required StateProvider<bool> provider,
    required String storageKey,
  }) {
    final bool value = ref.watch(provider);
    return SwitchListTile(
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      value: value,
      activeTrackColor: AppTheme.primaryCyan,
      onChanged: (val) {
        ref.read(provider.notifier).state = val;
        StorageService.setBool(storageKey, val);
      },
    );
  }

  Widget _buildDropdownRow(
    WidgetRef ref, {
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        DropdownButton<String>(
          value: value,
          dropdownColor: const Color(0xFF161B22),
          style: const TextStyle(color: AppTheme.primaryCyan, fontWeight: FontWeight.bold),
          underline: const SizedBox(),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
