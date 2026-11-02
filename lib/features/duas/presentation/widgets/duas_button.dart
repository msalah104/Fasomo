import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

/// Opens the Duas page from a fasting day.
class DuasButton extends StatelessWidget {
  const new({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.menu_book_outlined),
      label: Text(AppLocalizations.of(context).duasOpen),
    );
  }
}
