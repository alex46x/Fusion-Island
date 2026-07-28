import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_constants.dart';
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
      appBar: AppBar(
        title: Text(AppConstants.appName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Hero Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: const Color(0x33FFFFFF)),
              ),
              child: Column(
                children: [
                  Text(
                    AppConstants.appTagline,
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Live Interactive Preview
                  const Center(
                    child: DynamicIslandOverlay(),
                  ),

                  const SizedBox(height: 12),
                  const Text(
                    'Tap island above to cycle through Notification, Music & Call cards',
                    style: TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Master Enable Toggle Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isRunning ? AppTheme.primaryCyan.withValues(alpha: 0.2) : Colors.white10,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.power_settings_new_rounded,
                        color: isRunning ? AppTheme.primaryCyan : Colors.white38,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dynamic Island Service',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            isRunning ? 'Active & Floating Overlay Running' : 'Service Stopped',
                            style: TextStyle(
                              color: isRunning ? AppTheme.accentNeonGreen : Colors.white38,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: isRunning,
                      activeThumbColor: AppTheme.primaryCyan,
                      onChanged: _toggleService,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Overlay Permission Warning Banner
            if (!hasOverlayPermission) ...[
              Card(
                color: const Color(0x33FF5252),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Overlay permission required to display floating Dynamic Island.',
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          final res = await PlatformBridge.requestOverlayPermission();
                          ref.read(overlayPermissionGrantedProvider.notifier).state = res;
                        },
                        child: const Text('Grant'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Notification Listener Permission Banner
            if (!hasNotifPermission) ...[
              Card(
                color: const Color(0x337F00FF),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.notifications_active_outlined, color: AppTheme.accentPurple, size: 28),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Notification Access required to intercept system alerts & music info.',
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentPurple,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          await PlatformBridge.requestNotificationListenerPermission();
                          _checkPermissions();
                        },
                        child: const Text('Enable'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Feature Quick Modules
            Text(
              'Feature Modules',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                _buildModuleCard(
                  context,
                  title: 'Cutout Calibration',
                  subtitle: 'Align island with punch hole',
                  icon: Icons.center_focus_strong,
                  color: AppTheme.primaryCyan,
                  onTap: () => context.push('/calibration'),
                ),
                _buildModuleCard(
                  context,
                  title: 'Media Controls',
                  subtitle: 'Spotify, YT Music, VLC',
                  icon: Icons.music_note_rounded,
                  color: AppTheme.primaryBlue,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Media Session Controller Active')),
                    );
                  },
                ),
                _buildModuleCard(
                  context,
                  title: 'Notifications',
                  subtitle: 'App alerts & Quick Reply',
                  icon: Icons.notifications_active_rounded,
                  color: AppTheme.accentPurple,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notification Interceptor Active')),
                    );
                  },
                ),
                _buildModuleCard(
                  context,
                  title: 'Hardware Stats',
                  subtitle: 'Battery, RAM, Wi-Fi',
                  icon: Icons.memory_rounded,
                  color: AppTheme.accentNeonGreen,
                  onTap: () async {
                    final metrics = await PlatformBridge.getSystemMetrics();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Battery: ${metrics['batteryLevel']}% | Charging: ${metrics['isCharging']} | Wi-Fi: ${metrics['wifiConnected']}',
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 10),
              Text(
                title,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white38, fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
