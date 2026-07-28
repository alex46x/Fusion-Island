import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/native_bridge/platform_bridge.dart';
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
  StreamSubscription<Map<String, dynamic>>? _notificationSub;

  // Active Notification State Data
  String _notificationTitle = 'WhatsApp';
  String _notificationText = 'Alex: Hey! Is the new update live?';
  String _notificationPackage = 'com.whatsapp';

  // Active Call State Data
  final String _callerName = 'Sarah Connor';
  final String _callDuration = '01:42';

  @override
  void initState() {
    super.initState();
    _listenToNotifications();
  }

  void _listenToNotifications() {
    _notificationSub = PlatformBridge.notificationStream.listen((event) {
      if (mounted) {
        setState(() {
          _notificationPackage = event['packageName'] ?? 'com.android.systemui';
          _notificationTitle = event['title'] ?? 'Notification';
          _notificationText = event['text'] ?? '';
          _state = IslandState.expandedNotification;
        });

        // Auto collapse after 5 seconds
        Timer(const Duration(seconds: 5), () {
          if (mounted && _state == IslandState.expandedNotification) {
            setState(() {
              _state = IslandState.compact;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _notificationSub?.cancel();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      switch (_state) {
        case IslandState.compact:
          _state = IslandState.expandedNotification;
          break;
        case IslandState.expandedNotification:
          _state = IslandState.expandedMedia;
          break;
        case IslandState.expandedMedia:
          _state = IslandState.expandedCall;
          break;
        case IslandState.expandedCall:
          _state = IslandState.compact;
          break;
      }
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
            color: const Color(0x40FFFFFF),
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x88000000),
              blurRadius: 20,
              spreadRadius: 2,
              offset: Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _buildCurrentContent(),
        ),
      ),
    );
  }

  Widget _buildCurrentContent() {
    switch (_state) {
      case IslandState.compact:
        return _buildCompactContent();
      case IslandState.expandedMedia:
        return _buildExpandedMediaContent();
      case IslandState.expandedNotification:
        return _buildExpandedNotificationContent();
      case IslandState.expandedCall:
        return _buildExpandedCallContent();
    }
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
            child: const Icon(Icons.notifications_active, size: 13, color: Colors.black),
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

  Widget _buildExpandedNotificationContent() {
    return KeyedSubtree(
      key: const ValueKey('notification'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppTheme.accentPurple,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _notificationTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _notificationPackage,
                      style: const TextStyle(color: Colors.white38, fontSize: 10),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 20),
                onPressed: () {
                  setState(() {
                    _state = IslandState.compact;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _notificationText,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {},
                child: const Text('Reply', style: TextStyle(color: AppTheme.primaryCyan, fontSize: 12)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white10,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  minimumSize: const Size(60, 28),
                ),
                onPressed: () {
                  setState(() {
                    _state = IslandState.compact;
                  });
                },
                child: const Text('Dismiss', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ).animate().fade(duration: 200.ms).slideY(begin: 0.1, end: 0),
    );
  }

  Widget _buildExpandedMediaContent() {
    return KeyedSubtree(
      key: const ValueKey('media'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryCyan, AppTheme.primaryBlue],
                  ),
                ),
                child: const Icon(Icons.music_note, color: Colors.black, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Midnight City',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'M83 — Hurry Up, We\'re Dreaming',
                      style: TextStyle(color: Colors.white60, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.favorite_rounded, color: AppTheme.primaryCyan, size: 22),
            ],
          ),
          const Spacer(),
          LinearProgressIndicator(
            value: 0.6,
            backgroundColor: Colors.white12,
            color: AppTheme.primaryCyan,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 26),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.pause_circle_filled_rounded, color: AppTheme.primaryCyan, size: 34),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 26),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ).animate().fade(duration: 200.ms).slideY(begin: 0.1, end: 0),
    );
  }

  Widget _buildExpandedCallContent() {
    return KeyedSubtree(
      key: const ValueKey('call'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppTheme.accentNeonGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.call, color: Colors.black, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _callerName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Ongoing Call • $_callDuration',
                      style: const TextStyle(color: AppTheme.accentNeonGreen, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.mic_off_rounded, color: Colors.white70),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.volume_up_rounded, color: Colors.white70),
                onPressed: () {},
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _state = IslandState.compact;
                  });
                },
                icon: const Icon(Icons.call_end_rounded, size: 18),
                label: const Text('Hang Up'),
              ),
            ],
          ),
        ],
      ).animate().fade(duration: 200.ms).slideY(begin: 0.1, end: 0),
    );
  }
}
