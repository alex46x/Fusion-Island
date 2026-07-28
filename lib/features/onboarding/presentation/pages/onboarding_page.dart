import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/native_bridge/platform_bridge.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../overlay/presentation/widgets/dynamic_island_overlay.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Real-time Permission States
  bool _overlayGranted = false;
  bool _notificationGranted = false;
  bool _batteryIgnored = false;

  @override
  void initState() {
    super.initState();
    _refreshPermissions();
  }

  Future<void> _refreshPermissions() async {
    final overlay = await PlatformBridge.isOverlayPermissionGranted();
    final notif = await PlatformBridge.isNotificationListenerGranted();
    final battery = await PlatformBridge.isBatteryOptimizationIgnored();

    if (mounted) {
      setState(() {
        _overlayGranted = overlay;
        _notificationGranted = notif;
        _batteryIgnored = battery;
      });
    }
  }

  void _nextStep() {
    if (_currentStep < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    await StorageService.setBool('onboarding_completed', true);
    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Top Step Progress Indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                children: List.generate(5, (index) {
                  final isActive = index <= _currentStep;
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: isActive ? AppTheme.primaryCyan : Colors.white12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Page Content View
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) {
                  setState(() {
                    _currentStep = page;
                  });
                  _refreshPermissions();
                },
                children: [
                  _buildWelcomeStep(),
                  _buildFeatureOverviewStep(),
                  _buildPermissionWizardStep(),
                  _buildCalibrationStep(),
                  _buildFinishStep(),
                ],
              ),
            ),

            // Bottom Navigation Actions
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0 && _currentStep < 4)
                    TextButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text('Back', style: TextStyle(color: Colors.white54)),
                    )
                  else
                    const SizedBox(width: 60),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryCyan,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _nextStep,
                    child: Text(
                      _currentStep == 4 ? 'Get Started' : 'Continue',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Step 1: Welcome Screen
  Widget _buildWelcomeStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryCyan.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.blur_on_rounded, size: 72, color: AppTheme.primaryCyan),
          ),
          const SizedBox(height: 32),
          Text(
            AppConstants.appName,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppConstants.appTagline,
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          const DynamicIslandOverlay(),
        ],
      ),
    );
  }

  // Step 2: Feature Overview
  Widget _buildFeatureOverviewStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Designed for Android',
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Fusion Island brings fluid floating activities directly around your phone camera notch.',
            style: TextStyle(color: Colors.white60, fontSize: 14),
          ),
          const SizedBox(height: 32),
          _buildFeatureRow(
            icon: Icons.layers_rounded,
            color: AppTheme.primaryCyan,
            title: 'System-Wide Floating Overlay',
            subtitle: 'Stays accessible over any app at 120Hz refresh rate.',
          ),
          const SizedBox(height: 20),
          _buildFeatureRow(
            icon: Icons.music_note_rounded,
            color: AppTheme.primaryBlue,
            title: 'Universal Media Session',
            subtitle: 'Live controls for Spotify, YouTube Music, and Apple Music.',
          ),
          const SizedBox(height: 20),
          _buildFeatureRow(
            icon: Icons.notifications_active_rounded,
            color: AppTheme.accentPurple,
            title: 'Notification Interceptor',
            subtitle: 'Expand incoming notifications with quick reply & dismiss.',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  // Step 3: Permission Wizard Checklist
  Widget _buildPermissionWizardStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Permissions Wizard',
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'To operate smoothly in the background, Fusion Island requires a few system authorizations.',
            style: TextStyle(color: Colors.white60, fontSize: 14),
          ),
          const SizedBox(height: 24),

          // Permission 1: Overlay
          _buildPermissionCard(
            title: 'Display Over Other Apps',
            description: 'Required to draw the Dynamic Island overlay over your screen.',
            isGranted: _overlayGranted,
            onGrant: () async {
              await PlatformBridge.requestOverlayPermission();
              _refreshPermissions();
            },
          ),
          const SizedBox(height: 16),

          // Permission 2: Notification Access
          _buildPermissionCard(
            title: 'Notification Listener Access',
            description: 'Intercepts notifications & media player status to display live cards.',
            isGranted: _notificationGranted,
            onGrant: () async {
              await PlatformBridge.requestNotificationListenerPermission();
              _refreshPermissions();
            },
          ),
          const SizedBox(height: 16),

          // Permission 3: Battery Optimization
          _buildPermissionCard(
            title: 'Unrestricted Battery Execution',
            description: 'Prevents Android system from killing the floating service in background.',
            isGranted: _batteryIgnored,
            onGrant: () async {
              await PlatformBridge.requestIgnoreBatteryOptimization();
              _refreshPermissions();
            },
          ),

          const SizedBox(height: 24),
          Center(
            child: TextButton.icon(
              onPressed: () => PlatformBridge.openAppSettings(),
              icon: const Icon(Icons.settings_outlined, color: AppTheme.primaryCyan, size: 18),
              label: const Text('Open System App Settings', style: TextStyle(color: AppTheme.primaryCyan)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionCard({
    required String title,
    required String description,
    required bool isGranted,
    required VoidCallback onGrant,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isGranted ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  color: isGranted ? AppTheme.accentNeonGreen : Colors.redAccent,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isGranted ? AppTheme.accentNeonGreen.withValues(alpha: 0.15) : Colors.redAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isGranted ? 'Granted ✅' : 'Required ❌',
                    style: TextStyle(
                      color: isGranted ? AppTheme.accentNeonGreen : Colors.redAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(description, style: const TextStyle(color: Colors.white60, fontSize: 12)),
            if (!isGranted) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryCyan,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    minimumSize: const Size(80, 32),
                  ),
                  onPressed: onGrant,
                  child: const Text('Grant', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Step 4: Quick Cutout Calibration
  Widget _buildCalibrationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Punch Hole Calibration',
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Align the Dynamic Island with your physical front camera cutout.',
            style: TextStyle(color: Colors.white60, fontSize: 14),
          ),
          const SizedBox(height: 32),
          const Center(child: DynamicIslandOverlay()),
          const SizedBox(height: 32),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.touch_app_rounded, color: AppTheme.primaryCyan),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You can fine-tune exact pixel position anytime in Calibration Settings.',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Step 5: Finish Step
  Widget _buildFinishStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppTheme.accentNeonGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, size: 64, color: Colors.black),
          ),
          const SizedBox(height: 32),
          Text(
            'Setup Complete!',
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'Fusion Island is configured and ready to elevate your Android experience.',
            style: TextStyle(color: Colors.white70, fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
