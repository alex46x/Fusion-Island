import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';

enum IslandState {
  compact,
  expandedMedia,
  expandedNotification,
  expandedCall,
}

class DynamicIslandOverlay extends StatefulWidget {
  final double compactWidth;
  final double compactHeight;
  final double expandedWidth;
  final double expandedHeight;
  final double cornerRadius;
  final VoidCallback? onTap;

  const DynamicIslandOverlay({
    super.key,
    this.compactWidth = 200,
    this.compactHeight = 36,
    this.expandedWidth = 350,
    this.expandedHeight = 160,
    this.cornerRadius = 20,
    this.onTap,
  });

  @override
  State<DynamicIslandOverlay> createState() => _DynamicIslandOverlayState();
}

class _DynamicIslandOverlayState extends State<DynamicIslandOverlay> {
  IslandState _state = IslandState.compact;

  void _toggleExpanded() {
    setState(() {
      _state = _state == IslandState.compact
          ? IslandState.expandedMedia
          : IslandState.compact;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isExpanded = _state != IslandState.compact;
    final double targetWidth = isExpanded ? widget.expandedWidth : widget.compactWidth;
    final double targetHeight = isExpanded ? widget.expandedHeight : widget.compactHeight;

    return GestureDetector(
      onTap: () {
        _toggleExpanded();
        if (widget.onTap != null) widget.onTap!();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
        width: targetWidth,
        height: targetHeight,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(
            isExpanded ? widget.cornerRadius + 8 : widget.cornerRadius,
          ),
          border: Border.all(
            color: const Color(0x33FFFFFF),
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 20,
              spreadRadius: 2,
              offset: Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isExpanded ? _buildExpandedContent() : _buildCompactContent(),
        ),
      ),
    );
  }

  Widget _buildCompactContent() {
    return KeyedSubtree(
      key: const ValueKey('compact'),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Icon
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: AppTheme.primaryCyan,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.music_note, size: 14, color: Colors.black),
          ).animate().scale(duration: 200.ms),

          // Center Indicator Text
          const Expanded(
            child: Text(
              'Fusion Island',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Right Waveform / Visualizer
          Row(
            children: List.generate(
              3,
              (index) => Container(
                margin: const EdgeInsets.only(left: 2),
                width: 3,
                height: (index % 2 == 0) ? 14 : 8,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent() {
    return KeyedSubtree(
      key: const ValueKey('expanded'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryCyan, AppTheme.primaryBlue],
                  ),
                ),
                child: const Icon(Icons.music_note, color: Colors.black, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Midnight City',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'M83 — Hurry Up, We\'re Dreaming',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.favorite_border, color: AppTheme.primaryCyan),
                onPressed: () {},
              ),
            ],
          ),
          const Spacer(),

          // Media Progress Bar
          LinearProgressIndicator(
            value: 0.45,
            backgroundColor: Colors.white12,
            color: AppTheme.primaryCyan,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 12),

          // Action Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 28),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.pause_circle_filled_rounded, color: AppTheme.primaryCyan, size: 36),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 28),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ).animate().fade(duration: 250.ms).slideY(begin: 0.1, end: 0),
    );
  }
}
