import 'package:fasomo/features/settings/presentation/bloc/language_bloc.dart';
import 'package:fasomo/features/settings/presentation/widgets/language_tile.dart';
import 'package:fasomo/features/settings/presentation/widgets/settings_section.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// App-wide preferences, grouped into titled sections.
///
/// [extraSections] come from the app shell (usually [SettingsSection]s from
/// other features), so this feature doesn't depend on them.
class SettingsPage extends StatelessWidget {
  const new({this.extraSections = const [], super.key});

  /// Shown after the built-in sections.
  final List<Widget> extraSections;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(localization.settings)),
      body: _SaveFailureListener(
        child: ListView(
          padding: const EdgeInsetsDirectional.only(bottom: 24),
          children: [
            SettingsSection(
              title: localization.settingsAppearance,
              children: const [LanguageTile()],
            ),
            ...extraSections,
          ],
        ),
      ),
    );
  }
}

/// Tells the user when a choice applied but could not be saved.
class _SaveFailureListener extends StatelessWidget {
  const new({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<LanguageBloc, LanguageState>(
      listenWhen: (previous, current) =>
          current.failure != null && current != previous,
      listener: (context, _) => _showSaveFailed(context),
      child: child,
    );
  }
}

void _showSaveFailed(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(AppLocalizations.of(context).settingSaveFailed)),
  );
}
