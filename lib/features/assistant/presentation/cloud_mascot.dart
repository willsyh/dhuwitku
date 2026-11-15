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

/// The mascot's expression, matching what the assistant is saying.
enum MascotMood {
  /// Floating cloud, glancing around and blinking.
  idle,

  /// Winks: something was saved or done.
  happy,

  /// Wide eyes: didn't understand.
  surprised,

  /// Turns into a swaying "!": warnings, confirmations, errors.
  alert,
}

/// The assistant's mascot: a little cloud that floats, breathes, looks around
/// and blinks, and changes expression with [mood]. Drawn with vectors so it
/// stays sharp at any size. Motion stops when the system asks to reduce
/// animations, or when [animate] is false.
class CloudMascot extends StatefulWidget {
  const CloudMascot({super.key, this.size = 40, this.animate = true, this.mood = MascotMood.idle});

  final double size;
  final bool animate;
  final MascotMood mood;

  @override
  State<CloudMascot> createState() => _CloudMascotState();
}

class _CloudMascotState extends State<CloudMascot> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 3600));

  bool get _reduceMotion => MediaQuery.maybeDisableAnimationsOf(context) ?? false;
  bool get _shouldAnimate => widget.animate && !_reduceMotion;

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
    final mood = widget.mood;
    return Semantics(
      label: 'Maskot Asisten Dhuwitku',
      image: true,
      child: RepaintBoundary(
        child: SizedBox.square(
          dimension: widget.size,
          // A mood change "pops" the new expression in, like the morphs in
          // the original animation.
          child: AnimatedSwitcher(
            duration: _reduceMotion || !widget.animate
                ? Duration.zero
                : const Duration(milliseconds: 420),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: Tween(begin: 0.55, end: 1.0)
                  .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack)),
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: AnimatedBuilder(
              key: ValueKey(mood),
              animation: _controller,
              builder: (context, _) => CustomPaint(
                size: Size.square(widget.size),
                painter: _MascotPainter(
                  t: _controller.value,
                  mood: mood,
                  body: colors.body,
                  eyes: colors.eyes,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MascotPainter extends CustomPainter {
  _MascotPainter({required this.t, required this.mood, required this.body, required this.eyes});

  /// Animation phase 0..1.
  final double t;
  final MascotMood mood;
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
    if (mood == MascotMood.alert) {
      _paintExclamation(canvas, size.width);
    } else {
      _paintCloud(canvas, size.width);
    }
  }

  void _paintCloud(Canvas canvas, double s) {
    final wave = math.sin(2 * math.pi * t);
    // Happy bounces a little more; surprised "breathes" bigger.
    final bob = mood == MascotMood.happy ? 0.05 : 0.035;
    final breatheAmp = mood == MascotMood.surprised ? 0.04 : 0.025;
    final dy = -bob * s * wave;
    final breathe = breatheAmp * math.sin(4 * math.pi * t);
    canvas
      ..save()
      ..translate(s / 2, s / 2 + dy)
      ..scale(1 + breathe, 1 - breathe)
      ..rotate(0.04 * math.sin(2 * math.pi * t + 1))
      ..translate(-s / 2, -s / 2);

    final cloud = Path();
    for (final (x, y, r) in _lobes) {
      cloud.addOval(Rect.fromCircle(center: Offset(x * s, y * s), radius: r * s));
    }
    canvas.drawPath(cloud, Paint()..color = body);

    final eyePaint = Paint()..color = eyes;
    void pill(double x, double y, double w, double h, double tilt) {
      canvas
        ..save()
        ..translate(x * s, y * s)
        ..rotate(tilt);
      final ww = w * s, hh = h * s;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: ww, height: hh),
          Radius.circular(math.min(ww, hh) / 2),
        ),
        eyePaint,
      );
      canvas.restore();
    }

    switch (mood) {
      case MascotMood.idle:
        // Glance left and right, blink once per loop.
        final look = 0.04 * math.sin(2 * math.pi * t * 2 + 0.6).clamp(-0.8, 0.8) / 0.8;
        final open = 1 - 0.85 * _blinkAmount(t);
        pill(0.385 + look, 0.59, 0.14, 0.235 * open, -0.14);
        pill(0.625 + look, 0.59, 0.14, 0.235 * open, 0.20);
      case MascotMood.happy:
        // Wink: one short eye, one closed (a dash) that twitches.
        final twitch = 0.06 * math.sin(4 * math.pi * t);
        pill(0.39, 0.585, 0.115, 0.155, -0.10);
        pill(0.63, 0.585, 0.18, 0.048, -0.08 + twitch);
      case MascotMood.surprised:
        // Wide, tall eyes leaning together, with a little wobble.
        final wobble = 0.05 * math.sin(2 * math.pi * t * 2);
        pill(0.375, 0.565, 0.155, 0.30, 0.30 + wobble);
        pill(0.635, 0.565, 0.155, 0.30, 0.30 + wobble);
      case MascotMood.alert:
        break;
    }
    canvas.restore();
  }

  /// A tapered "!" that sways from tilted to upright, standing on its dot.
  void _paintExclamation(Canvas canvas, double s) {
    final sway = 0.30 * math.sin(2 * math.pi * t);
    final hop = -0.04 * s * math.sin(4 * math.pi * t).abs();
    final paint = Paint()..color = body;
    canvas
      ..save()
      ..translate(0.5 * s, 0.84 * s + hop)
      ..rotate(sway)
      ..translate(-0.5 * s, -0.84 * s);

    // Bar: wide rounded top tapering to a narrow rounded bottom.
    const cx = 0.5, topY = 0.22, topR = 0.075, botY = 0.58, botR = 0.045;
    final bar = Path()
      ..addOval(Rect.fromCircle(center: Offset(cx * s, topY * s), radius: topR * s))
      ..addOval(Rect.fromCircle(center: Offset(cx * s, botY * s), radius: botR * s))
      ..addPolygon([
        Offset((cx - topR) * s, topY * s),
        Offset((cx + topR) * s, topY * s),
        Offset((cx + botR) * s, botY * s),
        Offset((cx - botR) * s, botY * s),
      ], true);
    canvas
      ..drawPath(bar, paint)
      ..drawCircle(Offset(cx * s, 0.76 * s), 0.065 * s, paint)
      ..restore();
  }

  /// 0 = open, 1 = closed; a quick blink around 70% of the loop.
  static double _blinkAmount(double t) {
    const start = 0.70, length = 0.05;
    if (t < start || t > start + length) return 0;
    final p = (t - start) / length; // 0..1
    return 1 - (2 * p - 1).abs(); // up then down
  }

  @override
  bool shouldRepaint(_MascotPainter old) =>
      old.t != t || old.mood != mood || old.body != body || old.eyes != eyes;
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
