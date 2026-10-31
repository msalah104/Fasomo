import 'dart:async';

import 'package:fasomo/core/presentation/logo_mark.dart';
import 'package:fasomo/core/theme/sky_cycle.dart';
import 'package:fasomo/features/splash/presentation/splash_timeline.dart';
import 'package:fasomo/features/splash/presentation/widgets/sky_cycle_painter.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The launch animation: day turns to night, the new moon becomes the dot
/// of the ف, and the app name is typed out. Calls [onFinished] once, when
/// it ends or when the user taps to skip.
///
/// With reduced motion the finished scene is shown briefly instead.
class SplashPage extends StatefulWidget {
  const new({required this.onFinished, super.key});

  final VoidCallback onFinished;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  static const _reducedMotionHold = Duration(milliseconds: 900);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: SplashTimeline.total,
  );

  Timer? _hold;
  bool _started = false;
  bool _finished = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
      _hold = Timer(_reducedMotionHold, _finish);
    } else {
      // A TickerFuture never completes when cancelled, so disposing
      // mid-animation does not call onFinished.
      unawaited(_controller.forward().then((_) => _finish()));
    }
  }

  void _finish() {
    if (_finished) return;
    _finished = true;
    widget.onFinished();
  }

  @override
  void dispose() {
    _hold?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appName = AppLocalizations.of(context).appName;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _finish,
      child: Semantics(
        label: appName,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final layout = SplashLayout(constraints.biggest);
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final t = _controller.value;
                return AnnotatedRegion(
                  value: t < SplashTimeline.darkSkyFrom
                      ? SystemUiOverlayStyle.dark
                      : SystemUiOverlayStyle.light,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ExcludeSemantics(
                          child: CustomPaint(
                            painter: SkyCyclePainter(progress: _controller),
                          ),
                        ),
                      ),
                      Positioned.fromRect(
                        rect: layout.logoRect,
                        child: ExcludeSemantics(
                          child: LogoMark(
                            color: SkyCycle.logoInk,
                            dotColor: SkyCycle.moon,
                            semanticLabel: appName,
                            size: layout.logoRect.width,
                            strokeProgress: SplashTimeline.letter.transform(t),
                            // The painter's moon is the dot.
                            showDot: false,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 24,
                        right: 24,
                        top: layout.logoRect.bottom + 20,
                        child: ExcludeSemantics(
                          child: _TypedName(
                            name: appName,
                            progress: SplashTimeline.name.transform(t),
                            caretOn: _caretOn(t),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  /// The caret shows while typing and blinks until the splash ends.
  bool _caretOn(double t) {
    if (t < SplashTimeline.name.begin || t >= 0.98) return false;
    if (t < SplashTimeline.name.end) return true;
    final elapsedMs = t * SplashTimeline.total.inMilliseconds;
    return (elapsedMs ~/ 260).isEven;
  }
}

/// [name] typed letter by letter from the reading start, with a caret.
///
/// The full name is laid out invisibly underneath, so the typed part grows
/// in place instead of re-centring on every letter.
class _TypedName extends StatelessWidget {
  const new({
    required this.name,
    required this.progress,
    required this.caretOn,
  });

  final String name;
  final double progress;
  final bool caretOn;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.displayLarge!.copyWith(
      color: SkyCycle.nameInk,
      letterSpacing: 1.2,
    );
    final typed = name.substring(0, (name.length * progress).round());
    return Center(
      child: Stack(
        alignment: AlignmentDirectional.centerStart,
        children: [
          Opacity(
            opacity: 0,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(end: 10),
              child: Text(name, style: style),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(typed, style: style),
              const SizedBox(width: 4),
              Opacity(
                opacity: caretOn ? 1 : 0,
                child: Container(
                  width: 3,
                  height: style.fontSize,
                  color: SkyCycle.logoInk,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
