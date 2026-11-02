import 'package:fasomo/features/onboarding/domain/entities/onboarding_outcome.dart';
import 'package:fasomo/features/onboarding/domain/entities/onboarding_step.dart';
import 'package:fasomo/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:fasomo/features/onboarding/presentation/widgets/fasting_interests_step.dart';
import 'package:fasomo/features/onboarding/presentation/widgets/location_step.dart';
import 'package:fasomo/features/onboarding/presentation/widgets/notifications_step.dart';
import 'package:fasomo/features/onboarding/presentation/widgets/onboarding_nav_bar.dart';
import 'package:fasomo/features/onboarding/presentation/widgets/onboarding_progress.dart';
import 'package:fasomo/features/onboarding/presentation/widgets/reminder_time_step.dart';
import 'package:fasomo/features/onboarding/presentation/widgets/welcome_step.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The first-run flow, one step per page. Pages follow the reading
/// direction, so in Arabic the next step comes in from the left.
///
/// Reads an [OnboardingBloc] from the tree and calls [onDone] once, when the
/// flow is finished or skipped.
class OnboardingPage extends StatefulWidget {
  const new({required this.languagePicker, required this.onDone, super.key});

  /// The language choices on the first step, supplied by the app.
  final Widget languagePicker;

  final ValueChanged<OnboardingOutcome> onDone;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static const _pageTurn = Duration(milliseconds: 320);

  late final PageController _pages = PageController(
    initialPage: context.read<OnboardingBloc>().state.step.index,
  );

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _showStep(OnboardingStep step) {
    if (!_pages.hasClients) return;
    // With reduced motion the new step simply appears.
    if (MediaQuery.disableAnimationsOf(context)) {
      _pages.jumpToPage(step.index);
    } else {
      _pages.animateToPage(
        step.index,
        duration: _pageTurn,
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<OnboardingBloc, OnboardingState>(
          listenWhen: (previous, current) => previous.step != current.step,
          listener: (_, state) => _showStep(state.step),
        ),
        BlocListener<OnboardingBloc, OnboardingState>(
          listenWhen: (previous, current) => !previous.isDone && current.isDone,
          listener: (_, state) => widget.onDone(
            state.status == OnboardingStatus.skipped
                ? OnboardingOutcome.skipped
                : OnboardingOutcome.completed,
          ),
        ),
        BlocListener<OnboardingBloc, OnboardingState>(
          listenWhen: (previous, current) =>
              current.failure != null && previous != current,
          listener: (context, _) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).onboardingSaveFailed),
            ),
          ),
        ),
      ],
      child: BlocBuilder<OnboardingBloc, OnboardingState>(
        buildWhen: (previous, current) =>
            previous.step != current.step ||
            previous.status != current.status ||
            previous.locationStatus != current.locationStatus,
        builder: (context, state) => PopScope(
          // System back walks back through the steps before leaving.
          canPop: state.step.isFirst,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) {
              context.read<OnboardingBloc>().add(const OnboardingBackPressed());
            }
          },
          child: Scaffold(
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TopBar(state: state),
                  Expanded(
                    child: PageView(
                      controller: _pages,
                      // The buttons drive the steps, so a stray swipe
                      // never skips a choice.
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        for (final step in OnboardingStep.values)
                          switch (step) {
                            OnboardingStep.welcome => WelcomeStep(
                              languagePicker: widget.languagePicker,
                            ),
                            OnboardingStep.fastingTypes =>
                              const FastingInterestsStep(),
                            OnboardingStep.reminderTime =>
                              const ReminderTimeStep(),
                            OnboardingStep.location => const LocationStep(),
                            OnboardingStep.notifications =>
                              const NotificationsStep(),
                          },
                      ],
                    ),
                  ),
                  OnboardingNavBar(state: state),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The progress dots and, before the last step, Skip.
class _TopBar extends StatelessWidget {
  const new({required this.state});

  final OnboardingState state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(24, 12, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: OnboardingProgress(step: state.step),
            ),
          ),
          // Kept in the layout on the last step, so the header does not
          // jump; hidden from sight and from screen readers there.
          Visibility(
            visible: !state.step.isLast,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: TextButton(
              onPressed: state.status == OnboardingStatus.inProgress
                  ? () => context.read<OnboardingBloc>().add(
                      const OnboardingSkipped(),
                    )
                  : null,
              child: Text(AppLocalizations.of(context).onboardingSkip),
            ),
          ),
        ],
      ),
    );
  }
}
