import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

/// The gear action that opens the settings page.
///
/// Navigation is left to [onPressed], so the app shell decides which extra
/// sections the page gets.
class SettingsButton extends StatelessWidget {
  const new({required this.onPressed, this.color, super.key});

  final VoidCallback onPressed;

  /// Icon colour; defaults to the surrounding app bar's.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.settings_outlined, color: color),
      tooltip: AppLocalizations.of(context).settings,
      onPressed: onPressed,
    );
  }
}
