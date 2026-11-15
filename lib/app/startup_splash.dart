import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../l10n/l10n.dart';
import 'walking_cloud.dart';

/// Loading screen shown once when the app starts: the cloud mascot skips
/// along while star coins float and a progress bar fills up, then it fades
/// into the app. The app underneath is already built (and loading its data)
/// while this plays. Tap to skip. Not shown when the system asks to reduce
/// animations.
class StartupSplash extends StatefulWidget {
  const StartupSplash({super.key, required this.child});

  final Widget child;

  /// Only the first start of the process plays it (not hot restarts of the
  /// widget tree, theme or language changes).
  static bool _played = false;

  /// Lets tests play it again.
  @visibleForTesting
  static void resetForTest() => _played = false;

  @override
  State<StartupSplash> createState() => _StartupSplashState();
}

class _StartupSplashState extends State<StartupSplash> with TickerProviderStateMixin {
  static const _fillTime = Duration(milliseconds: 1700);
  static const _holdTime = Duration(milliseconds: 350);
  static const _fadeTime = Duration(milliseconds: 420);

  /// 0 → 1 while the bar fills.
  late final AnimationController _progress;

  /// Repeating beat for the sparkles and shimmer.
  late final AnimationController _beat;

  /// One stride of the walking mascot.
  late final AnimationController _walk;

  /// 0 → 1 while the splash fades out.
  late final AnimationController _exit;

  @override
  void initState() {
    super.initState();
    _progress = AnimationController(vsync: this, duration: _fillTime);
    _beat = AnimationController(vsync: this, duration: const Duration(milliseconds: 1900));
    _walk = AnimationController(vsync: this, duration: const Duration(milliseconds: 1050));
    _exit = AnimationController(vsync: this, duration: _fadeTime);
  }

  bool _visible = !StartupSplash._played;
  bool _decided = false;
  bool _leaving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_decided) return;
    _decided = true;
    StartupSplash._played = true;
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (!_visible || reduceMotion) {
      _visible = false;
      return;
    }
    _beat.repeat();
    _walk.repeat();
    _progress.forward().whenComplete(() {
      if (!mounted) return;
      setState(() {}); // mascot winks at 100%
      Future<void>.delayed(_holdTime, _leave);
    });
  }

  void _leave() {
    if (!mounted || _leaving) return;
    _leaving = true;
    _progress.stop();
    _exit.forward().whenComplete(() {
      if (!mounted) return;
      _beat.stop();
      _walk.stop();
      setState(() => _visible = false);
    });
  }

  @override
  void dispose() {
    _progress.dispose();
    _beat.dispose();
    _walk.dispose();
    _exit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return widget.child;
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        AnimatedBuilder(
          animation: _exit,
          builder: (context, child) {
            final t = Curves.easeIn.transform(_exit.value);
            return Opacity(
              opacity: 1 - t,
              child: Transform.scale(scale: 1 + 0.06 * t, child: child),
            );
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _leave,
            child: _SplashView(
              progress: _progress,
              beat: _beat,
              walk: _walk,
              done: _progress.isCompleted,
            ),
          ),
        ),
      ],
    );
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView({required this.progress, required this.beat, required this.walk, required this.done});

  final Animation<double> progress;
  final Animation<double> beat;
  final Animation<double> walk;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    // Edges match the native Android splash colour so there is no flash.
    final background = dark
        ? const [Color(0xFF1C2540), Color(0xFF111729), Color(0xFF0B0F19)]
        : const [Color(0xFFFFFFFF), Color(0xFFF8FAFC), Color(0xFFE3EDFD)];

    return Material(
      type: MaterialType.transparency,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.16),
            radius: 1.05,
            colors: background,
            stops: const [0, 0.5, 1],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _MascotStage(beat: beat, walk: walk, progress: progress, done: done),
                  const SizedBox(height: 8),
                  Text(
                    AppInfo.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          color: scheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 22),
                  _ProgressBlock(progress: progress, beat: beat),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---- Mascot, coins and sparkles ---------------------------------------------

const _gold = Color(0xFFFFC83D);
const _skyBlue = Color(0xFF60A5FA);

class _MascotStage extends StatelessWidget {
  const _MascotStage({required this.beat, required this.walk, required this.progress, required this.done});

  final Animation<double> beat;
  final Animation<double> walk;
  final Animation<double> progress;
  final bool done;

  /// 0 = eyes open, 1 = winking. Winks once while loading and keeps the wink
  /// once everything is ready.
  double _wink() {
    if (done) return 1;
    double ramp(double from, double to) => ((progress.value - from) / (to - from)).clamp(0.0, 1.0);
    return ramp(0.32, 0.38) - ramp(0.5, 0.56);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.mascotA11y,
      image: true,
      child: SizedBox(
        width: 270,
        height: 250,
        child: AnimatedBuilder(
          animation: Listenable.merge([beat, walk, progress]),
          builder: (context, _) {
            final t = beat.value;
            return Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                WalkingCloud(walk: walk.value, wink: _wink(), width: 260),
                _Sparkle(left: 28, top: 18, size: 18, color: _gold, phase: 0, t: t),
                _Sparkle(right: 18, top: 6, size: 14, color: _skyBlue, phase: 0.3, t: t),
                _Sparkle(right: 0, bottom: 96, size: 14, color: _gold, phase: 0.6, t: t),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Sparkle extends StatelessWidget {
  const _Sparkle({
    this.left,
    this.right,
    this.top,
    this.bottom,
    required this.size,
    required this.color,
    required this.phase,
    required this.t,
  });

  final double? left;
  final double? right;
  final double? top;
  final double? bottom;
  final double size;
  final Color color;
  final double phase;
  final double t;

  @override
  Widget build(BuildContext context) {
    // 0 → 1 → 0 once per beat.
    final pulse = (1 - math.cos((t + phase) * 2 * math.pi)) / 2;
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Opacity(
        opacity: 0.35 + 0.65 * pulse,
        child: Transform.rotate(
          angle: pulse * 22 * math.pi / 180,
          child: Transform.scale(
            scale: 0.55 + 0.6 * pulse,
            child: CustomPaint(size: Size.square(size), painter: _SparklePainter(color)),
          ),
        ),
      ),
    );
  }
}

class _SparklePainter extends CustomPainter {
  const _SparklePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) =>
      canvas.drawPath(_starPath(size.center(Offset.zero), size.width / 2), Paint()..color = color);

  @override
  bool shouldRepaint(_SparklePainter oldDelegate) => oldDelegate.color != color;
}

/// Four-pointed star centred on [c] with points [r] away.
Path _starPath(Offset c, double r) {
  final inner = r * 0.28;
  return Path()
    ..moveTo(c.dx, c.dy - r)
    ..lineTo(c.dx + inner, c.dy - inner)
    ..lineTo(c.dx + r, c.dy)
    ..lineTo(c.dx + inner, c.dy + inner)
    ..lineTo(c.dx, c.dy + r)
    ..lineTo(c.dx - inner, c.dy + inner)
    ..lineTo(c.dx - r, c.dy)
    ..lineTo(c.dx - inner, c.dy - inner)
    ..close();
}

// ---- Progress bar -----------------------------------------------------------

class _ProgressBlock extends StatelessWidget {
  const _ProgressBlock({required this.progress, required this.beat});

  final Animation<double> progress;
  final Animation<double> beat;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final statuses = [l.splashStatus1, l.splashStatus2, l.splashStatus3, l.splashStatus4];
    return SizedBox(
      width: 280,
      child: AnimatedBuilder(
        animation: Listenable.merge([progress, beat]),
        builder: (context, _) {
          // Fast at first, slowing down near the end.
          final value = Curves.easeOutCubic.transform(progress.value);
          final pct = (value * 100).round();
          final status = statuses[pct >= 78 ? 3 : pct >= 50 ? 2 : pct >= 24 ? 1 : 0];
          return Column(
            children: [
              _Bar(value: value, shimmer: beat.value, color: scheme.primary),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      layoutBuilder: (current, previous) => Stack(
                        alignment: Alignment.centerLeft,
                        children: [...previous, ?current],
                      ),
                      child: Text(
                        status,
                        key: ValueKey(status),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurface.withValues(alpha: 0.75),
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$pct%',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: scheme.primary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.value, required this.shimmer, required this.color});

  final double value;
  final double shimmer;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      value: '${(value * 100).round()}%',
      child: Container(
        height: 10,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: value.clamp(0.0, 1.0),
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    color,
                    Color.lerp(color, Colors.white, 0.3)!,
                    _gold,
                  ]),
                ),
                // A soft light sweeping across the filled part.
                child: LayoutBuilder(
                  builder: (context, box) {
                    final w = box.maxWidth * 0.45;
                    final x = -w + (box.maxWidth + w) * shimmer;
                    return Stack(
                      clipBehavior: Clip.hardEdge,
                      children: [
                        Positioned(
                          left: x,
                          top: 0,
                          bottom: 0,
                          width: w,
                          child: const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                Color(0x00FFFFFF),
                                Color(0x99FFFFFF),
                                Color(0x00FFFFFF),
                              ]),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
