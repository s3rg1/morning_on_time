import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import '../l10n/app_localizations.dart';

class CountdownTimer extends StatefulWidget {
  final DateTime arrivalDeadline;
  final VoidCallback? onComplete;

  const CountdownTimer({
    super.key,
    required this.arrivalDeadline,
    this.onComplete,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  Duration _remaining = Duration.zero;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _updateRemainingTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemainingTime();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _updateRemainingTime() {
    final now = DateTime.now();
    final remaining = widget.arrivalDeadline.difference(now);

    if (remaining.isNegative || remaining.inSeconds == 0) {
      setState(() {
        _remaining = Duration.zero;
      });
      widget.onComplete?.call();
      _timer?.cancel();
    } else {
      setState(() {
        _remaining = remaining;
      });
    }
  }

  Color _getTimerColor() {
    final minutes = _remaining.inMinutes;
    if (minutes <= 2) {
      return Colors.red;
    } else if (minutes <= 5) {
      return Colors.orange;
    } else if (minutes <= 10) {
      return Colors.amber;
    } else {
      return Colors.green;
    }
  }

  String _formatTime() {
    if (_remaining.inHours > 0) {
      return '${_remaining.inHours}:${(_remaining.inMinutes % 60).toString().padLeft(2, '0')}:${(_remaining.inSeconds % 60).toString().padLeft(2, '0')}';
    } else {
      return '${_remaining.inMinutes}:${(_remaining.inSeconds % 60).toString().padLeft(2, '0')}';
    }
  }

  double _getProgress() {
    // Calculate total journey duration (you might want to pass this as a parameter)
    final totalSeconds = _remaining.inSeconds;
    if (totalSeconds <= 0) return 0.0;
    
    // For visual purposes, let's say max journey is 60 minutes
    final maxSeconds = 60 * 60;
    return math.min(1.0, totalSeconds / maxSeconds);
  }

  @override
  Widget build(BuildContext context) {
    final color = _getTimerColor();
    final isUrgent = _remaining.inMinutes <= 5;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = isUrgent ? 1.0 + (_pulseController.value * 0.05) : 1.0;
        
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.2),
              color.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: color.withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Circular Progress Indicator - Duolingo style
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CustomPaint(
                    painter: _CircularTimerPainter(
                      progress: _getProgress(),
                      color: color,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(),
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.timeRemaining,
                      style: TextStyle(
                        fontSize: 16,
                        color: color.withOpacity(0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Urgency message
            if (isUrgent)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.flash_on,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _remaining.inMinutes <= 2
                          ? AppLocalizations.of(context)!.hurryCritical
                          : AppLocalizations.of(context)!.hurryUp,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: color,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.onTrack,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _CircularTimerPainter extends CustomPainter {
  final double progress;
  final Color color;

  _CircularTimerPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - 8, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 8),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );

    // Glow effect when urgent
    if (progress < 0.15) {
      final glowPaint = Paint()
        ..color = color.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 8),
        startAngle,
        sweepAngle,
        false,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_CircularTimerPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
