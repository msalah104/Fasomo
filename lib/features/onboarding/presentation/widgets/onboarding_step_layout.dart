import 'package:fasomo/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// The frame every onboarding step shares: an illustration, a heading, one
/// explaining paragraph and the step's controls. It scrolls, so any text
/// size fits.
class OnboardingStepLayout extends StatelessWidget {
  const new({
    required this.illustration,
    required this.title,
    required this.body,
    this.children = const [],
    super.key,
  });

  /// Decorative; hidden from screen readers.
  final Widget illustration;
  final String title;
  final String body;
  final List<Widget> children;

  /// Wide screens keep the text at a readable line length.
  static const double _maxContentWidth = 560;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = AppColors.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.fromSTEB(24, 8, 24, 24),
      child: Align(
        alignment: AlignmentDirectional.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: ExcludeSemantics(child: illustration),
              ),
              const SizedBox(height: 20),
              Semantics(
                header: true,
                child: Text(title, style: textTheme.headlineSmall),
              ),
              const SizedBox(height: 8),
              Text(
                body,
                style: textTheme.bodyLarge?.copyWith(
                  color: colors.onSurfaceMuted,
                ),
              ),
              const SizedBox(height: 24),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

/// An icon in a soft accent circle, the illustration of most steps.
class OnboardingStepIcon extends StatelessWidget {
  const new(this.icon, {super.key});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.accentContainer,
        shape: BoxShape.circle,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Icon(icon, size: 32, color: colors.onAccentContainer),
      ),
    );
  }
}
