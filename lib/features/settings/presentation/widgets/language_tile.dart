import 'dart:async';

import 'package:fasomo/features/settings/domain/entities/app_language.dart';
import 'package:fasomo/features/settings/presentation/bloc/language_bloc.dart';
import 'package:fasomo/features/settings/presentation/widgets/settings_choice_dialog.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Settings tile showing the app language; tapping it picks another one.
class LanguageTile extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final current = context.select<LanguageBloc, AppLanguage>(
      (bloc) => bloc.state.language,
    );

    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(localization.language),
      subtitle: Text(localization.languageName(current)),
      onTap: () => unawaited(_choose(context, current)),
    );
  }

  Future<void> _choose(BuildContext context, AppLanguage current) async {
    final localization = AppLocalizations.of(context);
    final bloc = context.read<LanguageBloc>();
    final choice = await showSettingsChoice(
      context: context,
      title: localization.language,
      options: AppLanguage.values,
      selected: current,
      labelOf: localization.languageName,
    );
    if (choice != null && choice != current) bloc.add(LanguageChanged(choice));
  }
}

extension on AppLocalizations {
  String languageName(AppLanguage language) => switch (language) {
    AppLanguage.system => languageSystem,
    AppLanguage.english => languageEnglish,
    AppLanguage.arabic => languageArabic,
  };
}
