import 'package:fasomo/core/di/injection_container.dart';
import 'package:fasomo/features/onboarding/domain/entities/onboarding_outcome.dart';
import 'package:fasomo/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:fasomo/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:fasomo/features/reminders/presentation/bloc/reminder_bloc.dart';
import 'package:fasomo/features/settings/domain/entities/app_language.dart';
import 'package:fasomo/features/settings/presentation/bloc/language_bloc.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Onboarding wired to the settings feature (the language, live) and the
/// reminders feature (reloaded with the saved choices when it ends).
class AppOnboarding extends StatelessWidget {
  const new({required this.onDone, super.key});

  final ValueChanged<OnboardingOutcome> onDone;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OnboardingBloc>()..add(const OnboardingStarted()),
      child: OnboardingPage(
        languagePicker: const OnboardingLanguagePicker(),
        onDone: (outcome) {
          // The choices were saved behind the reminder bloc's back.
          context.read<ReminderBloc>().add(const LoadReminders());
          onDone(outcome);
        },
      ),
    );
  }
}

/// English, Arabic or the device language. A choice applies to the whole
/// app at once, onboarding included.
class OnboardingLanguagePicker extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final language = context.select<LanguageBloc, AppLanguage>(
      (bloc) => bloc.state.language,
    );
    return RadioGroup<AppLanguage>(
      groupValue: language,
      onChanged: (value) {
        if (value != null) {
          context.read<LanguageBloc>().add(LanguageChanged(value));
        }
      },
      child: Column(
        children: [
          for (final option in const [
            AppLanguage.english,
            AppLanguage.arabic,
            AppLanguage.system,
          ])
            RadioListTile<AppLanguage>(
              contentPadding: EdgeInsetsDirectional.zero,
              value: option,
              title: Text(switch (option) {
                AppLanguage.english => localization.languageEnglish,
                AppLanguage.arabic => localization.languageArabic,
                AppLanguage.system => localization.languageSystem,
              }),
            ),
        ],
      ),
    );
  }
}
