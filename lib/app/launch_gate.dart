import 'package:fasomo/features/onboarding/domain/entities/onboarding_outcome.dart';
import 'package:flutter/material.dart';

/// What the launch shows: the splash, then onboarding on the first run, then
/// the app.
enum LaunchStage { splash, onboarding, app }

/// Plays the splash once per launch, then cross-fades into onboarding when
/// it is not done yet, and from there (or straight away) into the app.
class LaunchGate extends StatefulWidget {
  const new({
    required this.isOnboardingCompleted,
    required this.splashBuilder,
    required this.onboardingBuilder,
    required this.appBuilder,
    super.key,
  });

  /// Read once, when the gate first builds.
  final bool Function() isOnboardingCompleted;

  /// The splash; it calls `onFinished` once when it ends.
  final Widget Function(VoidCallback onFinished) splashBuilder;

  /// The first-run flow; it calls `onDone` once when it ends.
  final Widget Function(ValueChanged<OnboardingOutcome> onDone)
  onboardingBuilder;

  /// The app. `promptForNotifications` is false when onboarding has just
  /// dealt with notification permission.
  final Widget Function({required bool promptForNotifications}) appBuilder;

  @override
  State<LaunchGate> createState() => _LaunchGateState();
}

class _LaunchGateState extends State<LaunchGate> {
  static const _fade = Duration(milliseconds: 600);

  late final bool _needsOnboarding = !widget.isOnboardingCompleted();
  LaunchStage _stage = LaunchStage.splash;
  bool _promptForNotifications = true;

  void _onSplashFinished() => setState(
    () => _stage = _needsOnboarding ? LaunchStage.onboarding : LaunchStage.app,
  );

  void _onOnboardingDone(OnboardingOutcome outcome) => setState(() {
    _stage = LaunchStage.app;
    // Skipping leaves the permission question to the app, as before
    // onboarding existed.
    _promptForNotifications = outcome == OnboardingOutcome.skipped;
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : _fade,
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: KeyedSubtree(
        key: ValueKey(_stage),
        child: switch (_stage) {
          LaunchStage.splash => widget.splashBuilder(_onSplashFinished),
          LaunchStage.onboarding => widget.onboardingBuilder(
            _onOnboardingDone,
          ),
          LaunchStage.app => widget.appBuilder(
            promptForNotifications: _promptForNotifications,
          ),
        },
      ),
    );
  }
}
