import 'package:fasomo/app/launch_gate.dart';
import 'package:fasomo/features/onboarding/domain/entities/onboarding_outcome.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late VoidCallback finishSplash;
  late ValueChanged<OnboardingOutcome> finishOnboarding;

  Future<void> pumpGate(
    WidgetTester tester, {
    required bool onboardingCompleted,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LaunchGate(
          isOnboardingCompleted: () => onboardingCompleted,
          splashBuilder: (onFinished) {
            finishSplash = onFinished;
            return const Text('splash');
          },
          onboardingBuilder: (onDone) {
            finishOnboarding = onDone;
            return const Text('onboarding');
          },
          appBuilder: ({required promptForNotifications}) =>
              Text('app, prompt: $promptForNotifications'),
        ),
      ),
    );
  }

  Future<void> settle(WidgetTester tester, void Function() action) async {
    action();
    await tester.pumpAndSettle();
  }

  testWidgets('goes from the splash straight to the app once onboarded', (
    tester,
  ) async {
    await pumpGate(tester, onboardingCompleted: true);
    expect(find.text('splash'), findsOneWidget);

    await settle(tester, () => finishSplash());

    expect(find.text('onboarding'), findsNothing);
    // The app asks for notification permission itself, as before.
    expect(find.text('app, prompt: true'), findsOneWidget);
  });

  testWidgets('shows onboarding after the splash on the first run', (
    tester,
  ) async {
    await pumpGate(tester, onboardingCompleted: false);
    await settle(tester, () => finishSplash());
    expect(find.text('onboarding'), findsOneWidget);
    expect(find.textContaining('app'), findsNothing);

    await settle(tester, () => finishOnboarding(OnboardingOutcome.completed));

    // Onboarding has dealt with notification permission.
    expect(find.text('app, prompt: false'), findsOneWidget);
    expect(find.text('onboarding'), findsNothing);
  });

  testWidgets('after skipping, the app asks for permission as before', (
    tester,
  ) async {
    await pumpGate(tester, onboardingCompleted: false);
    await settle(tester, () => finishSplash());
    await settle(tester, () => finishOnboarding(OnboardingOutcome.skipped));

    expect(find.text('app, prompt: true'), findsOneWidget);
  });

  testWidgets('reads the flag once, so finishing does not re-run it', (
    tester,
  ) async {
    var reads = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: LaunchGate(
          isOnboardingCompleted: () {
            reads++;
            return true;
          },
          splashBuilder: (onFinished) {
            finishSplash = onFinished;
            return const Text('splash');
          },
          onboardingBuilder: (_) => const Text('onboarding'),
          appBuilder: ({required promptForNotifications}) => const Text('app'),
        ),
      ),
    );
    await settle(tester, () => finishSplash());
    await tester.pumpWidget(const SizedBox());

    expect(reads, 1);
  });
}
