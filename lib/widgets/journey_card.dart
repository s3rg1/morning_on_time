import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../l10n/app_localizations.dart';
import '../providers/app_state.dart';
import 'countdown_timer.dart';

/// Computes the progressive journey color from calm teal to urgent red.
/// [ratio] goes from 0.0 (wake-up) to 1.0 (arrival deadline).
Color _interpolateJourneyColor(double ratio) {
  ratio = ratio.clamp(0.0, 1.0);
  // Waypoints: teal(0.0) → green(0.3) → amber(0.5) → orange(0.75) → red(1.0)
  final waypoints = [
    (0.0, const Color(0xFF4DB6AC)),  // Calm teal
    (0.3, const Color(0xFF66BB6A)),  // Green
    (0.5, const Color(0xFFFFB300)),  // Amber
    (0.75, const Color(0xFFFF9600)), // Orange
    (1.0, const Color(0xFFE03E3E)),  // Deep red
  ];

  for (int i = 0; i < waypoints.length - 1; i++) {
    if (ratio <= waypoints[i + 1].$1) {
      final segmentRatio =
          (ratio - waypoints[i].$1) / (waypoints[i + 1].$1 - waypoints[i].$1);
      return Color.lerp(waypoints[i].$2, waypoints[i + 1].$2,
          segmentRatio)!;
    }
  }
  return waypoints.last.$2;
}

class JourneyCard extends StatefulWidget {
  final JourneyPhase phase;
  final DateTime wakeUpTime;
  final DateTime leaveTime;
  final DateTime arrivalDeadline;
  final String lastNotification;
  final VoidCallback onArrivalPressed;

  const JourneyCard({
    super.key,
    required this.phase,
    required this.wakeUpTime,
    required this.leaveTime,
    required this.arrivalDeadline,
    required this.lastNotification,
    required this.onArrivalPressed,
  });

  @override
  State<JourneyCard> createState() => _JourneyCardState();
}

class _JourneyCardState extends State<JourneyCard> {
  Timer? _ticker;
  double _ratio = 0.0;

  @override
  void initState() {
    super.initState();
    _updateRatio();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRatio();
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _updateRatio() {
    final now = DateTime.now();
    final total =
        widget.arrivalDeadline.difference(widget.wakeUpTime).inSeconds;
    if (total <= 0) return;
    final elapsed = now.difference(widget.wakeUpTime).inSeconds;
    setState(() {
      _ratio = (elapsed / total).clamp(0.0, 1.0);
    });
  }

  double get _leaveMarkerPosition {
    final total =
        widget.arrivalDeadline.difference(widget.wakeUpTime).inSeconds;
    if (total <= 0) return 0.5;
    final leaveOffset =
        widget.leaveTime.difference(widget.wakeUpTime).inSeconds;
    return (leaveOffset / total).clamp(0.0, 1.0);
  }

  /// Compute a deterministic banner message based on current time in the
  /// journey.  Used as primary display; the SharedPreferences value
  /// (written by background alarm callbacks) overrides when present.
  String _computedBanner(AppLocalizations loc) {
    final now = DateTime.now();

    if (widget.phase == JourneyPhase.onTheWay) {
      final secsToArrival = widget.arrivalDeadline.difference(now).inSeconds;
      if (secsToArrival <= 15) return loc.bannerLastChance;
      if (secsToArrival <= 45) return loc.bannerAlmostThere;
      return loc.bannerOnTheWay(DateFormat.jm().format(widget.arrivalDeadline));
    }

    // Getting Ready phase
    final minsToLeave = widget.leaveTime.difference(now).inMinutes;
    if (minsToLeave <= 5) return loc.bannerLeaveSoon;
    final sinceWakeUp = now.difference(widget.wakeUpTime).inMinutes;
    if (sinceWakeUp < 5) return loc.bannerWakeUp;
    return loc.bannerMinutesLeft(minsToLeave);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final color = _interpolateJourneyColor(_ratio);
    final colorDarker = _interpolateJourneyColor((_ratio + 0.1).clamp(0.0, 1.0));
    final isOnTheWay = widget.phase == JourneyPhase.onTheWay;

    // Use SharedPreferences notification if available (actual alarm text),
    // otherwise fall back to a computed banner based on current time.
    final bannerText = widget.lastNotification.isNotEmpty
        ? widget.lastNotification
        : _computedBanner(loc);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, colorDarker],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phase label
            Row(
              children: [
                Text(
                  isOnTheWay ? '🚗' : '🌅',
                  style: const TextStyle(fontSize: 26),
                ),
                const SizedBox(width: 10),
                Text(
                  isOnTheWay
                      ? loc.journeyOnTheWay
                      : loc.journeyGettingReady,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress bar with leave marker
            _JourneyProgressBar(
              progress: 1.0 - _ratio,
              leaveMarker: _leaveMarkerPosition,
            ),
            const SizedBox(height: 10),

            // Time context line (only during Getting Ready)
            if (!isOnTheWay)
              Text(
                '${loc.journeyLeaveBy} ${DateFormat.jm().format(widget.leaveTime)}'
                ' · ${loc.journeyArriveBy} ${DateFormat.jm().format(widget.arrivalDeadline)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),

            // Countdown timer (hero element during On the Way)
            if (isOnTheWay) ...[
              const SizedBox(height: 12),
              Center(
                child: CountdownTimer(
                  arrivalDeadline: widget.arrivalDeadline,
                  totalDuration: widget.arrivalDeadline
                      .difference(widget.leaveTime),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Last notification banner (always shown: actual alarm text or computed fallback)
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                bannerText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Arrived at School button (On the Way only)
            if (isOnTheWay) ...[
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: widget.onArrivalPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: color,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.school, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        loc.arrivedAtSchool,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Horizontal progress bar with a leave-home marker tick.
class _JourneyProgressBar extends StatelessWidget {
  final double progress; // 1.0 = full (wake-up), 0.0 = empty (arrival)
  final double leaveMarker; // 0.0–1.0 position of leave-home on the bar

  const _JourneyProgressBar({
    required this.progress,
    required this.leaveMarker,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 16,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final barWidth = constraints.maxWidth;
          final markerX = barWidth * leaveMarker;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Track
              Positioned(
                top: 4,
                left: 0,
                right: 0,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              // Fill
              Positioned(
                top: 4,
                left: 0,
                child: Container(
                  height: 8,
                  width: barWidth * progress.clamp(0.0, 1.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              // Leave-home marker tick
              Positioned(
                top: 0,
                left: markerX - 1,
                child: Container(
                  width: 2,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
