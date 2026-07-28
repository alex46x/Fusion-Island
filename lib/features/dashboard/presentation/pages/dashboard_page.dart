import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/native_bridge/platform_bridge.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../overlay/presentation/widgets/dynamic_island_overlay.dart';

final overlayServiceRunningProvider = StateProvider<bool>((ref) => false);
final overlayPermissionGrantedProvider = StateProvider<bool>((ref) => false);
final notificationPermissionGrantedProvider = StateProvider<bool>((ref) => false);

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final overlayGranted = await PlatformBridge.isOverlayPermissionGranted();
    final notifGranted = await PlatformBridge.isNotificationListenerGranted();

    ref.read(overlayPermissionGrantedProvider.notifier).state = overlayGranted;
    ref.read(notificationPermissionGrantedProvider.notifier).state = notifGranted;
  }

  Future<void> _toggleService(bool value) async {
    if (value) {
      final granted = ref.read(overlayPermissionGrantedProvider);
      if (!granted) {
        final success = await PlatformBridge.requestOverlayPermission();
        ref.read(overlayPermissionGrantedProvider.notifier).state = success;
        if (!success) return;
      }
      await PlatformBridge.startOverlayService();
      ref.read(overlayServiceRunningProvider.notifier).state = true;
    } else {
      await PlatformBridge.stopOverlayService();
      ref.read(overlayServiceRunningProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRunning = ref.watch(overlayServiceRunningProvider);
    final hasOverlayPermission = ref.watch(overlayPermissionGrantedProvider);
    final hasNotifPermission = ref.watch(notificationPermissionGrantedProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 64,
        backgroundColor: const Color(0xFF00779B),
        elevation: 0,
        title: Text(
          'fusionIsland',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 32,
            ),
            tooltip: isRunning ? 'Stop Service' : 'Start Service',
            onPressed: () => _toggleService(!isRunning),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        children: [
          // Live Dynamic Island Interactive Header Box
          Container(
            color: const Color(0xFF00779B),
            padding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
            child: const Center(
              child: DynamicIslandOverlay(),
            ),
          ),

          const SizedBox(height: 12),

          // Permission Warning Banner if missing
          if (!hasOverlayPermission || !hasNotifPermission) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFEEBA)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFF856404)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Overlay & Notification permissions required for full service.',
                      style: TextStyle(color: Color(0xFF856404), fontSize: 12),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (!hasOverlayPermission) {
                        await PlatformBridge.requestOverlayPermission();
                      }
                      if (!hasNotifPermission) {
                        await PlatformBridge.requestNotificationListenerPermission();
                      }
                      _checkPermissions();
                    },
                    child: const Text('Grant', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
          ],

          // 1. Notifications Row
          _buildListTile(
            icon: Icons.chat_bubble_outline_rounded,
            iconBgColor: const Color(0xFF139675),
            title: 'Notifications',
            subtitle: isRunning ? 'App is enabled' : 'App is disabled',
            trailing: Switch(
              value: isRunning,
              activeTrackColor: const Color(0xFF139675),
              onChanged: _toggleService,
            ),
            onTap: () => _toggleService(!isRunning),
          ),
          const Divider(height: 1, indent: 72),

          // 2. General Row
          _buildListTile(
            icon: Icons.smartphone_rounded,
            iconBgColor: const Color(0xFFC0A000),
            title: 'General',
            subtitle: 'Display settings and interaction',
            onTap: () => context.push('/general-settings'),
          ),
          const Divider(height: 1, indent: 72),

          // 3. Appearance Row
          _buildListTile(
            icon: Icons.brush_rounded,
            iconBgColor: const Color(0xFF28A745),
            title: 'Appearance',
            subtitle: 'Icons, animations and more',
            onTap: () => context.push('/settings'),
          ),
          const Divider(height: 1, indent: 72),

          // 4. Position Row
          _buildListTile(
            icon: Icons.swap_horiz_rounded,
            iconBgColor: const Color(0xFF28A745),
            title: 'Position',
            subtitle: 'Change size and position',
            onTap: () => context.push('/calibration'),
          ),
          const Divider(height: 1, indent: 72),

          // 5. Rating Row
          _buildListTile(
            icon: Icons.star_rounded,
            iconBgColor: const Color(0xFF4285F4),
            title: 'Rating',
            subtitle: 'How do you like the app?',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Thank you for rating Fusion Island! ★★★★★')),
              );
            },
          ),
          const Divider(height: 1, indent: 72),

          // 6. Help Row
          _buildListTile(
            icon: Icons.help_outline_rounded,
            iconBgColor: const Color(0xFF28A745),
            title: 'Help',
            subtitle: 'Support & FAQ',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fusion Island FAQ & Support')),
              );
            },
          ),
          const Divider(height: 1, indent: 72),

          // 7. Get Pro Row
          _buildListTile(
            icon: Icons.lock_outline_rounded,
            iconBgColor: const Color(0xFF20639B),
            title: 'Get Pro',
            subtitle: 'Unlock Everything',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fusion Island Pro Unlocked')),
              );
            },
          ),
          const Divider(height: 1, indent: 72),

          // 8. Developer & Diagnostics Row
          _buildListTile(
            icon: Icons.tune_rounded,
            iconBgColor: const Color(0xFF00779B),
            title: 'Developer & Diagnostics',
            subtitle: 'Real-time status, memory & debug panel',
            onTap: () => _showDeveloperDebugPanel(context),
          ),
          const Divider(height: 1, indent: 72),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: iconBgColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Colors.black45,
          fontSize: 13,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  void _showDeveloperDebugPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D1117),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final isRunning = ref.read(overlayServiceRunningProvider);
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.bug_report_rounded, color: AppTheme.primaryCyan),
                  const SizedBox(width: 10),
                  Text(
                    'Internal Developer Debug Panel',
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDebugTile('Service State', isRunning ? 'Active (TYPE_APPLICATION_OVERLAY)' : 'Stopped', isRunning ? AppTheme.accentNeonGreen : Colors.redAccent),
              _buildDebugTile('Cutout Alignment Mode', 'LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES', AppTheme.primaryCyan),
              _buildDebugTile('Target Refresh Rate', '120Hz Hardware Accelerated', AppTheme.primaryBlue),
              _buildDebugTile('Notification Stream', 'Active BroadcastListener', AppTheme.accentPurple),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDebugTile(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Text(value, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
