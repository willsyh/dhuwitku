import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The cloud mascot walking with a coin and a wallet, drawn with vectors
/// (from the 320×295 "maskot awan berjalan" design).
///
/// [walk] is the step phase (0 → 1 = one full stride, repeat it to walk).
/// [wink] goes 0 → 1: the right eye closes, then turns into a "<" wink.
class WalkingCloud extends StatelessWidget {
  const WalkingCloud({super.key, required this.walk, this.wink = 0, this.width = 260});

  final double walk;
  final double wink;
  final double width;

  static const _viewBox = Size(320, 295);

  @override
  Widget build(BuildContext context) {
    final height = width * _viewBox.height / _viewBox.width;
    return CustomPaint(
      size: Size(width, height),
      painter: _WalkingCloudPainter(walk: walk, wink: wink, shadow: Theme.of(context).colorScheme.primary),
    );
  }
}

/// Keyframes eased in-out between stops, like a CSS animation.
double _kf(double t, List<double> stops, List<double> values) {
  for (var i = 0; i < stops.length - 1; i++) {
    if (t <= stops[i + 1]) {
      final local = ((t - stops[i]) / (stops[i + 1] - stops[i])).clamp(0.0, 1.0);
      return values[i] + (values[i + 1] - values[i]) * Curves.easeInOut.transform(local);
    }
  }
  return values.last;
}

const _quarters = [0.0, 0.25, 0.5, 0.75, 1.0];
const _halves = [0.0, 0.5, 1.0];
double _deg(double d) => d * math.pi / 180;

class _WalkingCloudPainter extends CustomPainter {
  _WalkingCloudPainter({required this.walk, required this.wink, required this.shadow});

  final double walk;
  final double wink;
  final Color shadow;

  static const _ink = Color(0xFF1E2554);
  static const _hand = Color(0xFFEEF4FF);
  static const _leg = Color(0xFFDBE7FF);
  static const _coinRim = Color(0xFFFFB820);
  static const _coinStar = Color(0xFFFFEFA6);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / WalkingCloud._viewBox.width;
    canvas.save();
    canvas.scale(s);
    final t = walk % 1;

    _shadow(canvas, t);
    _trail(canvas, t);
    // Legs: the right one is half a stride ahead of the left.
    _withTransform(canvas, const Offset(185, 212), _legMotion((t + 0.5) % 1), () {
      _paintLeg(canvas, _rightLeg, const Offset(158, 224), 0, _rightShoeSole, _rightShoe);
    });
    _withTransform(canvas, const Offset(130, 212), _legMotion(t), () {
      _paintLeg(canvas, _leftLeg, const Offset(101, 222), 8, _leftShoeSole, _leftShoe);
    });

    final body = (
      dx: 0.0,
      dy: _kf(t, _quarters, [2, -7, 2, -7, 2]),
      rot: _kf(t, _quarters, [-2.4, 0, 2.4, 0, -2.4]),
      sx: _kf(t, _quarters, [1.02, 0.99, 1.02, 0.99, 1.02]),
      sy: _kf(t, _quarters, [0.98, 1.02, 0.98, 1.02, 0.98]),
    );
    _withTransform(canvas, const Offset(160, 150), body, () {
      _paintBody(canvas, t);
    });
    canvas.restore();
  }

  ({double dx, double dy, double rot, double sx, double sy}) _legMotion(double t) => (
        dx: _kf(t, _quarters, [-6, 7, 13, -3, -6]),
        dy: _kf(t, _quarters, [2, 1, -7, -15, 2]),
        rot: _kf(t, _quarters, [11, -13, -22, 18, 11]),
        sx: 1,
        sy: 1,
      );

  /// CSS-style transform around [origin]: translate, rotate (degrees), scale.
  void _withTransform(Canvas canvas, Offset origin,
      ({double dx, double dy, double rot, double sx, double sy}) m, VoidCallback draw) {
    canvas
      ..save()
      ..translate(origin.dx + m.dx, origin.dy + m.dy)
      ..rotate(_deg(m.rot))
      ..scale(m.sx, m.sy)
      ..translate(-origin.dx, -origin.dy);
    draw();
    canvas.restore();
  }

  void _shadow(Canvas canvas, double t) {
    final dx = _kf(t, _quarters, [-3, 0, 3, 0, -3]);
    final sx = _kf(t, _quarters, [1.05, 0.84, 1.05, 0.84, 1.05]);
    final opacity = _kf(t, _quarters, [0.28, 0.16, 0.28, 0.16, 0.28]);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(160 + dx, 265), width: 136 * sx, height: 22),
      Paint()
        ..color = shadow.withValues(alpha: opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
  }

  void _trail(Canvas canvas, double t) {
    final dx = -56 + 112 * t;
    final opacity = t < 0.25 ? t / 0.25 : (t > 0.75 ? (1 - t) / 0.25 : 1.0);
    canvas.drawLine(
      Offset(110 + dx, 274),
      Offset(140 + dx, 274),
      Paint()
        ..color = const Color(0xFF4A80F0).withValues(alpha: 0.3 * 0.55 * opacity)
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round,
    );
  }

  void _paintLeg(Canvas canvas, Path leg, Offset shoeAt, double shoeTilt, Path sole, Path shoe) {
    canvas.drawPath(leg, Paint()..color = _leg);
    canvas
      ..save()
      ..translate(shoeAt.dx, shoeAt.dy)
      ..rotate(_deg(shoeTilt));
    canvas.drawPath(sole, Paint()..color = Colors.white);
    canvas.drawPath(
      shoe,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4F88FF), Color(0xFF214DB8)],
        )
            .createShader(shoe.getBounds()),
    );
    canvas.restore();
  }

  void _paintBody(Canvas canvas, double t) {
    final bounds = _body.getBounds();
    canvas.drawPath(
      _body,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.28, -0.44), // 36% / 28% of the box
          radius: 0.72,
          colors: const [Colors.white, Color(0xFFF3F7FF), Color(0xFFB4CCFF)],
          stops: const [0, 0.6, 1],
        ).createShader(bounds),
    );

    // Coin on the head.
    canvas
      ..save()
      ..translate(208, 76)
      ..rotate(_deg(32));
    _coin(canvas, 22, 17, 10);
    canvas.restore();

    // Left eye.
    canvas.drawOval(Rect.fromCenter(center: const Offset(134, 136), width: 23, height: 30), Paint()..color = _ink);
    canvas.drawCircle(const Offset(130, 129.5), 4.2, Paint()..color = Colors.white);
    _rightEye(canvas);

    final blush = Paint()..color = const Color(0xFFFFB5C0);
    canvas.drawOval(Rect.fromCenter(center: const Offset(110, 155), width: 26, height: 17), blush);
    canvas.drawOval(Rect.fromCenter(center: const Offset(216, 155), width: 26, height: 17), blush);

    canvas.drawPath(_mouth, Paint()..color = const Color(0xFF8A2F46));
    canvas.drawPath(_tongue, Paint()..color = const Color(0xFFFF788A));

    // Arm with the wallet.
    _withTransform(
      canvas,
      const Offset(222, 160),
      (
        dx: _kf(t, _halves, [-2, 2, -2]),
        dy: _kf(t, _halves, [-3, 3, -3]),
        rot: _kf(t, _halves, [7, -7, 7]),
        sx: 1,
        sy: 1,
      ),
      () {
        canvas
          ..save()
          ..translate(216, 172)
          ..rotate(_deg(-14));
        canvas.drawRRect(RRect.fromLTRBR(-26, -24, 24, 22, const Radius.circular(11)),
            Paint()..color = const Color(0xFF2957C2));
        canvas.drawRRect(RRect.fromLTRBR(-17, -22, 29, 22, const Radius.circular(10)),
            Paint()..color = const Color(0xFF4A80F0));
        canvas.restore();
        canvas.drawPath(_walletHand, Paint()..color = _hand);
      },
    );

    // Arm raising a coin.
    _withTransform(
      canvas,
      const Offset(96, 152),
      (
        dx: _kf(t, _halves, [2, -3, 2]),
        dy: _kf(t, _halves, [3, -4, 3]),
        rot: _kf(t, _halves, [-8, 10, -8]),
        sx: 1,
        sy: 1,
      ),
      () {
        canvas
          ..save()
          ..translate(56, 118);
        _coin(canvas, 28, 22, 13);
        canvas.restore();
        canvas.drawPath(_coinHand, Paint()..color = _hand);
      },
    );
  }

  /// Open eye that closes as [wink] goes to 0.5, then a "<" that pops in.
  void _rightEye(Canvas canvas) {
    if (wink < 0.5) {
      final open = 1 - wink * 2;
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(196, 136), width: 23, height: math.max(3, 30 * open)),
        Paint()..color = _ink,
      );
      if (open > 0.45) {
        canvas.drawCircle(Offset(192, 136 - 6.5 * open), 4.2 * open, Paint()..color = Colors.white);
      }
      return;
    }
    final pop = Curves.easeOutBack.transform((wink - 0.5) * 2);
    canvas
      ..save()
      ..translate(196, 136)
      ..scale(0.6 + 0.4 * pop)
      ..translate(-196, -136);
    canvas.drawPath(
      Path()
        ..moveTo(206, 125)
        ..lineTo(186, 136)
        ..lineTo(206, 147),
      Paint()
        ..color = _ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.restore();
  }

  void _coin(Canvas canvas, double outer, double inner, double star) {
    canvas.drawCircle(Offset.zero, outer, Paint()..color = _coinRim);
    final face = Rect.fromCircle(center: Offset.zero, radius: inner);
    canvas.drawCircle(
      Offset.zero,
      inner,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.24, -0.32),
          radius: 0.7,
          colors: [Color(0xFFFFE173), Color(0xFFF7A718)],
        ).createShader(face),
    );
    final i = star * 0.3;
    canvas.drawPath(
      Path()
        ..moveTo(0, -star)
        ..lineTo(i, -i)
        ..lineTo(star, 0)
        ..lineTo(i, i)
        ..lineTo(0, star)
        ..lineTo(-i, i)
        ..lineTo(-star, 0)
        ..lineTo(-i, -i)
        ..close(),
      Paint()..color = _coinStar,
    );
  }

  @override
  bool shouldRepaint(_WalkingCloudPainter old) =>
      old.walk != walk || old.wink != wink || old.shadow != shadow;
}

// ---- Shapes (SVG path data from the design) ---------------------------------

final _body = Path()
  ..moveTo(110, 100)
  ..cubicTo(110, 72, 142, 54, 168, 62)
  ..cubicTo(178, 44, 212, 40, 228, 64)
  ..cubicTo(246, 72, 252, 94, 244, 112)
  ..cubicTo(268, 122, 276, 156, 256, 178)
  ..cubicTo(252, 204, 224, 218, 196, 216)
  ..cubicTo(182, 224, 152, 224, 136, 215)
  ..cubicTo(106, 218, 84, 198, 84, 172)
  ..cubicTo(66, 156, 70, 120, 94, 108)
  ..cubicTo(96, 102, 102, 100, 110, 100)
  ..close();

final _rightLeg = Path()
  ..moveTo(174, 205)
  ..cubicTo(174, 222, 175, 232, 184, 236)
  ..cubicTo(194, 236, 198, 224, 196, 205)
  ..close();

final _leftLeg = Path()
  ..moveTo(122, 204)
  ..cubicTo(120, 222, 121, 232, 130, 236)
  ..cubicTo(140, 236, 144, 224, 142, 204)
  ..close();

final _rightShoeSole = Path()
  ..moveTo(5, 20)
  ..cubicTo(5, 27, 14, 29, 28, 29)
  ..cubicTo(41, 29, 48, 26, 48, 20)
  ..close();

final _rightShoe = Path()
  ..moveTo(6, 21)
  ..cubicTo(4, 10, 14, 2, 29, 2)
  ..cubicTo(41, 2, 49, 10, 48, 21)
  ..cubicTo(41, 24, 15, 24, 6, 21)
  ..close();

final _leftShoeSole = Path()
  ..moveTo(4, 20)
  ..cubicTo(4, 27, 14, 30, 28, 30)
  ..cubicTo(40, 30, 47, 26, 47, 20)
  ..close();

final _leftShoe = Path()
  ..moveTo(5, 21)
  ..cubicTo(3, 10, 14, 2, 28, 2)
  ..cubicTo(41, 2, 48, 10, 47, 21)
  ..cubicTo(40, 24, 14, 24, 5, 21)
  ..close();

final _mouth = Path()
  ..moveTo(152, 146)
  ..quadraticBezierTo(165, 148, 176, 146)
  ..cubicTo(176, 162, 152, 162, 152, 146)
  ..close();

final _tongue = Path()
  ..moveTo(155, 154)
  ..cubicTo(159, 149, 169, 149, 173, 154)
  ..cubicTo(170, 160, 158, 160, 155, 154)
  ..close();

final _walletHand = Path()
  ..moveTo(218, 178)
  ..cubicTo(216, 168, 228, 164, 236, 170)
  ..cubicTo(245, 170, 249, 182, 242, 190)
  ..cubicTo(234, 196, 220, 190, 218, 178)
  ..close();

final _coinHand = Path()
  ..moveTo(96, 146)
  ..cubicTo(84, 156, 66, 158, 52, 152)
  ..cubicTo(36, 148, 30, 132, 42, 124)
  ..cubicTo(50, 120, 62, 128, 68, 134)
  ..cubicTo(78, 138, 90, 134, 98, 136)
  ..close();
