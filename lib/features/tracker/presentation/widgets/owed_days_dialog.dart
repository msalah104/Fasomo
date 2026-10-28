import 'package:fasomo/features/tracker/domain/entities/fast_log_summary.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

/// The days owed for one Ramadan, as picked in [OwedDaysDialog].
typedef OwedDays = ({int hijriYear, int days});

/// Picks a Ramadan and how many of its days are owed, pre-filled with what
/// is already entered for that year. Pops an [OwedDays], or `null` when
/// cancelled. Only shown when [QadaSummary.latestOwableYear] is known.
class OwedDaysDialog extends StatefulWidget {
  const new({required this.qada, super.key});

  /// How many Ramadans back the year list reaches.
  static const int yearsBack = 15;

  /// Most days a single Ramadan can owe.
  static const int maxDays = 30;

  final QadaSummary qada;

  @override
  State<OwedDaysDialog> createState() => _OwedDaysDialogState();
}

class _OwedDaysDialogState extends State<OwedDaysDialog> {
  late int _year = widget.qada.latestOwableYear!;
  late int _days = widget.qada.extraOwedFor(_year);

  void _pickYear(int? year) {
    if (year == null) return;
    setState(() {
      _year = year;
      _days = widget.qada.extraOwedFor(year);
    });
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final latest = widget.qada.latestOwableYear!;

    return AlertDialog(
      title: Text(localization.qadaOwedDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(localization.qadaOwedDialogHint),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            initialValue: _year,
            decoration: InputDecoration(labelText: localization.qadaOwedYear),
            items: [
              for (var offset = 0; offset < OwedDaysDialog.yearsBack; offset++)
                DropdownMenuItem(
                  value: latest - offset,
                  child: Text(localization.ramadanOfYear('${latest - offset}')),
                ),
            ],
            onChanged: _pickYear,
          ),
          const SizedBox(height: 16),
          Text(localization.qadaOwedDays, style: theme.textTheme.labelLarge),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.outlined(
                tooltip: localization.removeOneDay,
                onPressed: _days > 0 ? () => setState(() => _days--) : null,
                icon: const Icon(Icons.remove),
              ),
              SizedBox(
                width: 64,
                child: Text(
                  '$_days',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium,
                ),
              ),
              IconButton.outlined(
                tooltip: localization.addOneDay,
                onPressed: _days < OwedDaysDialog.maxDays
                    ? () => setState(() => _days++)
                    : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(localization.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop<OwedDays>(context, (
            hijriYear: _year,
            days: _days,
          )),
          child: Text(localization.save),
        ),
      ],
    );
  }
}
