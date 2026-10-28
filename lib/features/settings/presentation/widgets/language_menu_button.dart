import 'package:fasomo/features/settings/domain/entities/app_language.dart';
import 'package:fasomo/features/settings/presentation/bloc/language_bloc.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// App-bar menu to pick the app language; the choice is saved.
class LanguageMenuButton extends StatelessWidget {
  const new({super.key, this.color});

  /// Icon colour; defaults to the surrounding app bar's.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final current = context.select<LanguageBloc, AppLanguage>(
      (bloc) => bloc.state.language,
    );

    return PopupMenuButton<AppLanguage>(
      icon: Icon(Icons.language, color: color),
      tooltip: localization.language,
      initialValue: current,
      onSelected: (language) =>
          context.read<LanguageBloc>().add(LanguageChanged(language)),
      itemBuilder: (context) => [
        for (final language in AppLanguage.values)
          CheckedPopupMenuItem(
            value: language,
            checked: language == current,
            child: Text(switch (language) {
              AppLanguage.system => localization.languageSystem,
              AppLanguage.english => localization.languageEnglish,
              AppLanguage.arabic => localization.languageArabic,
            }),
          ),
      ],
    );
  }
}
