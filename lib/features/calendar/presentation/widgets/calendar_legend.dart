import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/presentation/fasting_type_style.dart';
import 'package:fasomo/core/presentation/fasting_type_text.dart';
import 'package:fasomo/core/theme/app_colors.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

/// What each fasting colour on the calendar means.
class CalendarLegend extends StatelessWidget {
  const new({super.key});

  static const List<FastingType> _types = [
    FastingType.whiteDays,
    FastingType.mondayThursday,
    FastingType.ramadan,
    FastingType.shawwal,
    FastingType.arafah,
  ];

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            for (final type in _types)
              _LegendItem(
                type: type,
                label: type == FastingType.arafah
                    ? localization.specialDays
                    : localization.fastingTypeTitle(type),
              ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const new({required this.type, required this.label});

  final FastingType type;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: type.color(colors),
            shape: BoxShape.circle,
            border: Border.all(color: colors.onSurfaceMuted),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
