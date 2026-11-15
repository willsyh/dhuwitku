import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Colors for the mascot: a dark cloud with light eyes in light mode, the
/// reverse in dark mode so it never disappears into the background.
({Color body, Color eyes}) _mascotColors(BuildContext context) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  return dark
      ? (body: const Color(0xFFF1F5F9), eyes: const Color(0xFF111827))
      : (body: const Color(0xFF111827), eyes: Colors.white);
}

/// The assistant's mascot: a little cloud that floats, breathes, looks around
/// and blinks. Drawn with vectors so it stays sharp at any size. Motion stops
/// when the system asks to reduce animations, or when [animate] is false.
class CloudMascot extends StatefulWidget {
  const CloudMascot({super.key, this.size = 40, this.animate = true});

  final double size;
  final bool animate;

  @override
  State<CloudMascot> createState() => _CloudMascotState();
}

class _CloudMascotState extends State<CloudMascot> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 3600));

  bool get _shouldAnimate =>
      widget.animate && !(MediaQuery.maybeDisableAnimationsOf(context) ?? false);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(CloudMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    if (_shouldAnimate) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      _controller
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = _mascotColors(context);
    return Semantics(
      label: 'Maskot Asisten Dhuwitku',
      image: true,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            size: Size.square(widget.size),
            painter: _CloudPainter(t: _controller.value, body: colors.body, eyes: colors.eyes),
          ),
        ),
      ),
    );
  }
}

class _CloudPainter extends CustomPainter {
  _CloudPainter({required this.t, required this.body, required this.eyes});

  /// Animation phase 0..1.
  final double t;
  final Color body;
  final Color eyes;

  // Cloud made of overlapping circles, in unit coordinates (x, y, radius).
  static const _lobes = [
    (0.50, 0.57, 0.31), // core
    (0.37, 0.35, 0.19), // top left bump
    (0.63, 0.37, 0.17), // top right bump
    (0.24, 0.58, 0.18), // left
    (0.77, 0.57, 0.18), // right
    (0.50, 0.73, 0.22), // bottom
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final wave = math.sin(2 * math.pi * t);

    // Float up and down, and breathe (slight squash and stretch).
    final dy = -0.035 * s * wave;
    final breathe = 0.025 * math.sin(4 * math.pi * t);
    canvas
      ..save()
      ..translate(s / 2, s / 2 + dy)
      ..scale(1 + breathe, 1 - breathe)
      ..rotate(0.04 * math.sin(2 * math.pi * t + 1))
      ..translate(-s / 2, -s / 2);

    final bodyPaint = Paint()
      ..color = body
      ..isAntiAlias = true;
    final cloud = Path();
    for (final (x, y, r) in _lobes) {
      cloud.addOval(Rect.fromCircle(center: Offset(x * s, y * s), radius: r * s));
    }
    canvas.drawPath(cloud, bodyPaint);

    // Eyes glance left and right, and blink once per loop.
    final look = 0.04 * s * math.sin(2 * math.pi * t * 2 + 0.6).clamp(-0.8, 0.8) / 0.8;
    final blink = _blinkAmount(t);
    final eyeH = 0.235 * s * (1 - 0.85 * blink);
    final eyeW = 0.14 * s;
    final eyePaint = Paint()..color = eyes;
    for (final (x, tilt) in [(0.385, -0.14), (0.625, 0.20)]) {
      canvas
        ..save()
        ..translate(x * s + look, 0.59 * s)
        ..rotate(tilt);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: eyeW, height: eyeH),
          Radius.circular(eyeW / 2),
        ),
        eyePaint,
      );
      canvas.restore();
    }
    canvas.restore();
  }

  /// 0 = open, 1 = closed; a quick blink around 70% of the loop.
  static double _blinkAmount(double t) {
    const start = 0.70, length = 0.05;
    if (t < start || t > start + length) return 0;
    final p = (t - start) / length; // 0..1
    return 1 - (2 * p - 1).abs(); // up then down
  }

  @override
  bool shouldRepaint(_CloudPainter old) => old.t != t || old.body != body || old.eyes != eyes;
}

/// Three dots bouncing one after another: "the assistant is typing".
class TypingDots extends StatefulWidget {
  const TypingDots({super.key, this.color, this.dotSize = 8});

  final Color? color;
  final double dotSize;

  @override
  State<TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<TypingDots> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduce) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? _mascotColors(context).body;
    final d = widget.dotSize;
    return Semantics(
      label: 'Asisten sedang mengetik',
      liveRegion: true,
      child: SizedBox(
        height: d * 2.2,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) SizedBox(width: d * 0.55),
                _dot(i, color, d),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot(int i, Color color, double d) {
    // Each dot rises in turn, then rests.
    final phase = (_controller.value - i * 0.16) % 1.0;
    final lift = phase < 0.5 ? math.sin(phase / 0.5 * math.pi) : 0.0;
    return Transform.translate(
      offset: Offset(0, -lift * d * 0.9),
      child: Container(
        width: d,
        height: d,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.45 + 0.55 * lift),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
