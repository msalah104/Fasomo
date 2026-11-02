import 'package:fasomo/features/ramadan/domain/entities/ramadan_checklist.dart';
import 'package:fasomo/features/ramadan/presentation/bloc/ramadan_bloc.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Today's checklist: fasted (the tracker's control), Taraweeh and the
/// Quran pages read.
class RamadanChecklistSection extends StatelessWidget {
  const new({
    required this.checklist,
    required this.failed,
    this.fastedAction,
    super.key,
  });

  final RamadanChecklist? checklist;

  /// Whether today's checklist could not be read.
  final bool failed;
  final Widget? fastedAction;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final checklist = this.checklist;
    final bloc = context.read<RamadanBloc>();

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              localization.ramadanChecklistTitle,
              style: theme.textTheme.titleSmall,
            ),
          ),
          if (fastedAction case final action?)
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 8),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: action,
              ),
            ),
          if (checklist != null) ...[
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: checklist.prayedTaraweeh,
              onChanged: (_) => bloc.add(const TaraweehToggled()),
              title: Text(localization.ramadanTaraweeh),
            ),
            _QuranPagesStepper(pages: checklist.quranPages),
          ] else if (failed)
            _ChecklistFailed(
              onRetry: () => bloc.add(const RamadanRefreshed()),
            ),
        ],
      ),
    );
  }
}

/// "Quran pages", then minus, the count and plus.
class _QuranPagesStepper extends StatelessWidget {
  const new({required this.pages});

  final int pages;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final bloc = context.read<RamadanBloc>();

    return Row(
      children: [
        Expanded(
          child: Text(
            localization.ramadanQuranPages,
            style: theme.textTheme.bodyLarge,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.remove),
          tooltip: localization.ramadanQuranPageRemove,
          onPressed: pages > 0
              ? () => bloc.add(QuranPagesChanged(pages - 1))
              : null,
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 40),
          child: Semantics(
            label: localization.ramadanQuranPagesValue(pages),
            excludeSemantics: true,
            child: Text(
              '$pages',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          tooltip: localization.ramadanQuranPageAdd,
          onPressed: pages < RamadanChecklist.maxQuranPages
              ? () => bloc.add(QuranPagesChanged(pages + 1))
              : null,
        ),
      ],
    );
  }
}

class _ChecklistFailed extends StatelessWidget {
  const new({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(child: Text(localization.ramadanChecklistLoadFailed)),
        TextButton(onPressed: onRetry, child: Text(localization.retry)),
      ],
    );
  }
}
