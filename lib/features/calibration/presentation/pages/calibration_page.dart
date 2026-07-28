import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/native_bridge/platform_bridge.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../core/theme/app_theme.dart';

final islandWidthProvider = StateProvider<double>((ref) => StorageService.getDouble('island_width', defaultValue: 200.0));
final islandHeightProvider = StateProvider<double>((ref) => StorageService.getDouble('island_height', defaultValue: 36.0));
final islandOffsetXProvider = StateProvider<double>((ref) => StorageService.getDouble('island_offset_x', defaultValue: 0.0));
final islandOffsetYProvider = StateProvider<double>((ref) => StorageService.getDouble('island_offset_y', defaultValue: 12.0));
final islandRadiusProvider = StateProvider<double>((ref) => StorageService.getDouble('island_radius', defaultValue: 20.0));

class CalibrationPage extends ConsumerWidget {
  const CalibrationPage({super.key});

  Future<void> _updateOverlay(WidgetRef ref) async {
    final width = ref.read(islandWidthProvider);
    final height = ref.read(islandHeightProvider);
    final offsetX = ref.read(islandOffsetXProvider);
    final offsetY = ref.read(islandOffsetYProvider);
    final radius = ref.read(islandRadiusProvider);

    await StorageService.setDouble('island_width', width);
    await StorageService.setDouble('island_height', height);
    await StorageService.setDouble('island_offset_x', offsetX);
    await StorageService.setDouble('island_offset_y', offsetY);
    await StorageService.setDouble('island_radius', radius);

    await PlatformBridge.updateOverlayConfig(
      width: width,
      height: height,
      offsetX: offsetX,
      offsetY: offsetY,
      cornerRadius: radius,
    );
  }

  void _applyPreset(WidgetRef ref, double width, double height, double x, double y, double r) {
    ref.read(islandWidthProvider.notifier).state = width;
    ref.read(islandHeightProvider.notifier).state = height;
    ref.read(islandOffsetXProvider.notifier).state = x;
    ref.read(islandOffsetYProvider.notifier).state = y;
    ref.read(islandRadiusProvider.notifier).state = r;
    _updateOverlay(ref);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = ref.watch(islandWidthProvider);
    final height = ref.watch(islandHeightProvider);
    final offsetX = ref.watch(islandOffsetXProvider);
    final offsetY = ref.watch(islandOffsetYProvider);
    final radius = ref.watch(islandRadiusProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Camera Cutout Calibration', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live Cutout Calibration Visualizer Box
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0x33FFFFFF)),
              ),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  // Grid background guidelines
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.1,
                      child: GridPaper(
                        color: AppTheme.primaryCyan,
                        interval: 20,
                        divisions: 1,
                        subdivisions: 1,
                      ),
                    ),
                  ),
                  // Scaled Dynamic Island Preview representation
                  Positioned(
                    top: offsetY.clamp(0.0, 100.0),
                    left: (MediaQuery.of(context).size.width / 2 - (width / 2) + offsetX).clamp(0.0, MediaQuery.of(context).size.width - width),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      width: width,
                      height: height,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryCyan.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(radius),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryCyan.withValues(alpha: 0.4),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'PUNCH HOLE',
                          style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Presets Selector
            Text('Quick Cutout Presets', style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _presetChip(context, 'Center Punch Hole', () => _applyPreset(ref, 200, 36, 0, 12, 20)),
                  _presetChip(context, 'Left Punch Hole', () => _applyPreset(ref, 180, 36, -80, 12, 20)),
                  _presetChip(context, 'Right Punch Hole', () => _applyPreset(ref, 180, 36, 80, 12, 20)),
                  _presetChip(context, 'Dual Pill Camera', () => _applyPreset(ref, 240, 42, 0, 10, 24)),
                  _presetChip(context, 'Waterdrop Notch', () => _applyPreset(ref, 160, 32, 0, 6, 16)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Adjustment Sliders
            Text('Manual Alignment Controls', style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            _sliderCard('Width', width, 120, 320, (v) {
              ref.read(islandWidthProvider.notifier).state = v;
              _updateOverlay(ref);
            }),
            _sliderCard('Height', height, 24, 70, (v) {
              ref.read(islandHeightProvider.notifier).state = v;
              _updateOverlay(ref);
            }),
            _sliderCard('Horizontal Offset (X)', offsetX, -120, 120, (v) {
              ref.read(islandOffsetXProvider.notifier).state = v;
              _updateOverlay(ref);
            }),
            _sliderCard('Vertical Offset (Y)', offsetY, 0, 80, (v) {
              ref.read(islandOffsetYProvider.notifier).state = v;
              _updateOverlay(ref);
            }),
            _sliderCard('Corner Radius', radius, 8, 35, (v) {
              ref.read(islandRadiusProvider.notifier).state = v;
              _updateOverlay(ref);
            }),
          ],
        ),
      ),
    );
  }

  Widget _presetChip(BuildContext context, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        backgroundColor: Colors.white10,
        side: const BorderSide(color: Color(0x33FFFFFF)),
        label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        onPressed: onTap,
      ),
    );
  }

  Widget _sliderCard(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
                Text('${value.toStringAsFixed(0)} px', style: const TextStyle(color: AppTheme.primaryCyan, fontWeight: FontWeight.bold)),
              ],
            ),
            Slider(
              value: value,
              min: min,
              max: max,
              activeColor: AppTheme.primaryCyan,
              inactiveColor: Colors.white12,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
