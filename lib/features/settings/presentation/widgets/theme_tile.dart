import 'dart:async';

import 'package:fasomo/features/settings/domain/entities/app_theme_mode.dart';
import 'package:fasomo/features/settings/presentation/bloc/theme_bloc.dart';
import 'package:fasomo/features/settings/presentation/widgets/settings_choice_dialog.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Settings tile showing System / Light / Dark; tapping it picks another one.
class ThemeTile extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final current = context.select<ThemeBloc, AppThemeMode>(
      (bloc) => bloc.state.mode,
    );

    return ListTile(
      leading: Icon(switch (current) {
        AppThemeMode.system => Icons.brightness_auto_outlined,
        AppThemeMode.light => Icons.light_mode_outlined,
        AppThemeMode.dark => Icons.dark_mode_outlined,
      }),
      title: Text(localization.theme),
      subtitle: Text(localization.themeModeName(current)),
      onTap: () => unawaited(_choose(context, current)),
    );
  }

  Future<void> _choose(BuildContext context, AppThemeMode current) async {
    final localization = AppLocalizations.of(context);
    final bloc = context.read<ThemeBloc>();
    final choice = await showSettingsChoice(
      context: context,
      title: localization.theme,
      options: AppThemeMode.values,
      selected: current,
      labelOf: localization.themeModeName,
    );
    if (choice != null && choice != current) bloc.add(ThemeModeChanged(choice));
  }
}

extension on AppLocalizations {
  String themeModeName(AppThemeMode mode) => switch (mode) {
    AppThemeMode.system => themeSystem,
    AppThemeMode.light => themeLight,
    AppThemeMode.dark => themeDark,
  };
}
