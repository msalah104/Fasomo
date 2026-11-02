import 'dart:async';

import 'package:fasomo/features/backup/presentation/backup_messages.dart';
import 'package:fasomo/features/backup/presentation/bloc/backup_bloc.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The settings tiles that export a backup and restore one, with the
/// outcome of each shown as a snackbar.
class BackupTiles extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return BlocConsumer<BackupBloc, BackupState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        final message = backupMessage(localization, state);
        if (message == null) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      },
      builder: (context, state) {
        final bloc = context.read<BackupBloc>();
        return Column(
          children: [
            ListTile(
              leading: const Icon(Icons.save_alt_outlined),
              title: Text(localization.backupExport),
              subtitle: Text(localization.backupExportSubtitle),
              trailing: state.status == BackupStatus.exporting
                  ? _Progress(label: localization.backupInProgress)
                  : null,
              enabled: !state.isBusy,
              onTap: () => bloc.add(const BackupExportRequested()),
            ),
            ListTile(
              leading: const Icon(Icons.settings_backup_restore),
              title: Text(localization.backupRestore),
              subtitle: Text(localization.backupRestoreSubtitle),
              trailing: state.status == BackupStatus.restoring
                  ? _Progress(label: localization.backupInProgress)
                  : null,
              enabled: !state.isBusy,
              onTap: () => unawaited(_confirmRestore(context)),
            ),
          ],
        );
      },
    );
  }
}

/// Names what a restore replaces before the file is picked, and starts it
/// only once the user agrees.
Future<void> _confirmRestore(BuildContext context) async {
  final bloc = context.read<BackupBloc>();
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => const RestoreConfirmationDialog(),
  );
  if (confirmed ?? false) bloc.add(const BackupRestoreRequested());
}

/// Asks before a restore replaces the user's data. Pops `true` to go ahead.
class RestoreConfirmationDialog extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(localization.backupRestoreConfirmTitle),
      content: Text(localization.backupRestoreConfirmBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(localization.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(localization.backupRestoreConfirmAction),
        ),
      ],
    );
  }
}

class _Progress extends StatelessWidget {
  const new({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 24,
      child: CircularProgressIndicator(strokeWidth: 2, semanticsLabel: label),
    );
  }
}
