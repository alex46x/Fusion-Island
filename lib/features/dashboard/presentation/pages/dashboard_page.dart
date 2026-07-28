import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/native_bridge/platform_bridge.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../calibration/presentation/pages/calibration_page.dart';
import '../../../overlay/presentation/widgets/dynamic_island_overlay.dart';
import '../../../settings/presentation/pages/settings_page.dart';

final overlayServiceRunningProvider = StateProvider<bool>((ref) => false);
final overlayPermissionGrantedProvider = StateProvider<bool>((ref) => false);
final notificationPermissionGrantedProvider = StateProvider<bool>((ref) => false);
final batteryOptimizationIgnoredProvider = StateProvider<bool>((ref) => false);

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final overlayGranted = await PlatformBridge.isOverlayPermissionGranted();
    final notifGranted = await PlatformBridge.isNotificationListenerGranted();
    final batteryIgnored = await PlatformBridge.isBatteryOptimizationIgnored();

    ref.read(overlayPermissionGrantedProvider.notifier).state = overlayGranted;
    ref.read(notificationPermissionGrantedProvider.notifier).state = notifGranted;
    ref.read(batteryOptimizationIgnoredProvider.notifier).state = batteryIgnored;
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
    final isBatteryIgnored = ref.watch(batteryOptimizationIgnoredProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryCyan,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.blur_on_rounded, color: Colors.black, size: 18),
                ),
                const SizedBox(width: 8),
                Text(
                  AppConstants.appName,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              AppConstants.appTagline,
              style: GoogleFonts.outfit(color: Colors.white54, fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.white70),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.bug_report_outlined, color: AppTheme.primaryCyan),
            tooltip: 'Developer Debug Panel',
            onPressed: () => _showDeveloperDebugPanel(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () => context.push('/settings'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _currentTab,
        children: [
          _buildHomeDashboardTab(isRunning, hasOverlayPermission, hasNotifPermission, isBatteryIgnored),
          const CalibrationPage(),
          _buildLiveActivitiesTab(),
          _buildThemesTab(),
          const SettingsPage(),
        ],
      ),
      bottomNavigationBar: _buildModernBottomNavBar(),
    );
  }

  // TAB 1: Home Flagship Dashboard
  Widget _buildHomeDashboardTab(bool isRunning, bool hasOverlayPermission, bool hasNotifPermission, bool isBatteryIgnored) {
    final bool allGreen = isRunning && hasOverlayPermission && hasNotifPermission;
    final bool partialOrange = isRunning && (!hasNotifPermission || !isBatteryIgnored);

    Color statusColor = Colors.redAccent;
    String statusTitle = 'Service Stopped';
    String statusDesc = 'Enable Dynamic Island floating overlay service';

    if (allGreen) {
      statusColor = AppTheme.accentNeonGreen;
      statusTitle = 'Dynamic Island Active';
      statusDesc = 'Floating window active at 120Hz liquid motion';
    } else if (partialOrange) {
      statusColor = Colors.orangeAccent;
      statusTitle = 'Partially Configured';
      statusDesc = 'Grant notification & battery permissions for best performance';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dynamic Island Live Interactive Artwork Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: const Color(0x33FFFFFF)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x40000000),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                const Center(child: DynamicIslandOverlay()),
                const SizedBox(height: 12),
                const Text(
                  'Tap island above to preview Notification, Music & Call cards',
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ).animate().fade().scale(duration: 250.ms),
          const SizedBox(height: 20),

          // FLAGSHIP HERO STATUS CARD
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: statusColor.withValues(alpha: 0.1),
              border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1.5),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isRunning ? Icons.play_arrow_rounded : Icons.power_settings_new_rounded,
                        color: statusColor,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            statusTitle,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            statusDesc,
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
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
                const SizedBox(height: 16),
                const Divider(color: Colors.white12, height: 1),
                const SizedBox(height: 12),

                // Real-time Permission Status Badges
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatusChip('Overlay', hasOverlayPermission, () async {
                      final res = await PlatformBridge.requestOverlayPermission();
                      ref.read(overlayPermissionGrantedProvider.notifier).state = res;
                    }),
                    _buildStatusChip('Notifications', hasNotifPermission, () async {
                      await PlatformBridge.requestNotificationListenerPermission();
                      _checkPermissions();
                    }),
                    _buildStatusChip('Battery', isBatteryIgnored, () async {
                      await PlatformBridge.requestIgnoreBatteryOptimization();
                      _checkPermissions();
                    }),
                  ],
                ),
              ],
            ),
          ).animate().slideY(begin: 0.1, end: 0, duration: 300.ms),
          const SizedBox(height: 24),

          // DASHBOARD STATS METRICS GRID
          Text(
            'System Metrics & Activity',
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.1,
            children: [
              _buildStatCard('Battery', '85%', Icons.battery_charging_full_rounded, AppTheme.accentNeonGreen),
              _buildStatCard('Alerts Today', '14', Icons.notifications_none_rounded, AppTheme.accentPurple),
              _buildStatCard('Refresh Rate', '120Hz', Icons.speed_rounded, AppTheme.primaryCyan),
            ],
          ),
          const SizedBox(height: 24),

          // QUICK ACTION SETTINGS CATEGORIES (BENTO GRID)
          Text(
            'Quick Action Modules',
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: [
              _buildBentoCategoryCard(
                title: 'Cutout Calibration',
                subtitle: 'Align with punch hole',
                icon: Icons.center_focus_strong_rounded,
                color: AppTheme.primaryCyan,
                onTap: () => setState(() => _currentTab = 1),
              ),
              _buildBentoCategoryCard(
                title: 'Live Activities',
                subtitle: 'Timers, Music, Calls',
                icon: Icons.graphic_eq_rounded,
                color: AppTheme.primaryBlue,
                onTap: () => setState(() => _currentTab = 2),
              ),
              _buildBentoCategoryCard(
                title: 'Theme Engine',
                subtitle: 'AMOLED, Glass, Material You',
                icon: Icons.palette_outlined,
                color: AppTheme.accentPurple,
                onTap: () => setState(() => _currentTab = 3),
              ),
              _buildBentoCategoryCard(
                title: 'Gestures & Touch',
                subtitle: 'Tap, Swipe, Long Press',
                icon: Icons.gesture_rounded,
                color: AppTheme.accentNeonGreen,
                onTap: () => context.push('/settings'),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // TAB 3: Live Activities Tab
  Widget _buildLiveActivitiesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Live Activities & Widgets',
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Configure dynamic widgets rendered inside the expanded island.',
            style: TextStyle(color: Colors.white60, fontSize: 14),
          ),
          const SizedBox(height: 24),
          _buildActivityCard('Media Session Controller', 'Spotify, YouTube Music, Apple Music', Icons.music_note_rounded, true),
          const SizedBox(height: 12),
          _buildActivityCard('Telephony & Phone Calls', 'Incoming, Ongoing, & Missed calls pill', Icons.call_rounded, true),
          const SizedBox(height: 12),
          _buildActivityCard('Notification Interceptor', 'System-wide notification popups & quick reply', Icons.notifications_active_rounded, true),
          const SizedBox(height: 12),
          _buildActivityCard('Timer & Stopwatch Activity', 'Live countdown timer inside floating pill', Icons.timer_rounded, false),
        ],
      ),
    );
  }

  Widget _buildActivityCard(String title, String subtitle, IconData icon, bool enabled) {
    return Card(
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        secondary: Icon(icon, color: AppTheme.primaryCyan),
        value: enabled,
        activeTrackColor: AppTheme.primaryCyan,
        onChanged: (val) {},
      ),
    );
  }

  // TAB 4: Themes Tab
  Widget _buildThemesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Modular Theme Engine',
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select visual theme style & color tokens.',
            style: TextStyle(color: Colors.white60, fontSize: 14),
          ),
          const SizedBox(height: 24),
          _buildThemeStyleCard('Dark Theme', 'Default sleek dark surface', AppTheme.darkCard, true),
          const SizedBox(height: 12),
          _buildThemeStyleCard('AMOLED Theme', 'Pure black #000000 for battery savings', AppTheme.amoledCard, false),
          const SizedBox(height: 12),
          _buildThemeStyleCard('Glassmorphism', 'Translucent blur with subtle border', const Color(0x33000000), false),
        ],
      ),
    );
  }

  Widget _buildThemeStyleCard(String title, String subtitle, Color color, bool selected) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white24),
          ),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        trailing: selected
            ? const Icon(Icons.check_circle_rounded, color: AppTheme.primaryCyan)
            : const Icon(Icons.circle_outlined, color: Colors.white24),
        onTap: () {},
      ),
    );
  }

  // Status Chip Badge
  Widget _buildStatusChip(String label, bool isGranted, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isGranted ? AppTheme.accentNeonGreen.withValues(alpha: 0.15) : Colors.redAccent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isGranted ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
              color: isGranted ? AppTheme.accentNeonGreen : Colors.redAccent,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isGranted ? AppTheme.accentNeonGreen : Colors.redAccent,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Stat Card Widget
  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  // Bento Category Card
  Widget _buildBentoCategoryCard({
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

  // Modern Bottom Navigation Bar
  Widget _buildModernBottomNavBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(top: BorderSide(color: Colors.white12, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (index) {
          setState(() {
            _currentTab = index;
          });
        },
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryCyan,
        unselectedItemColor: Colors.white38,
        selectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: GoogleFonts.outfit(fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.center_focus_strong_rounded), label: 'Calibrate'),
          BottomNavigationBarItem(icon: Icon(Icons.graphic_eq_rounded), label: 'Live'),
          BottomNavigationBarItem(icon: Icon(Icons.palette_outlined), label: 'Themes'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }

  // Developer Debug Panel Modal Sheet
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
