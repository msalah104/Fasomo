import 'package:fasomo/core/calendar/fasting_rules.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/core/presentation/date_formatter.dart';
import 'package:fasomo/core/theme/app_colors.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

/// Where today falls in the Hijri month: one segment per day, with today
/// tallest and the White Days taller than ordinary days.
class MonthProgressBar extends StatelessWidget {
  const new({required this.today, required this.daysInMonth, super.key});

  final HijriDate today;
  final int daysInMonth;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final monthName = localization.hijriMonthName(today.month);
    final progress = localization.monthProgress(today.day, daysInMonth);

    return Semantics(
      label: '$monthName, $progress',
      excludeSemantics: true,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      monthName,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(progress, style: textTheme.bodySmall),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 14,
                child: Row(
                  children: [
                    for (var day = 1; day <= daysInMonth; day++)
                      Expanded(
                        child: _Segment(day: day, today: today.day),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const new({required this.day, required this.today});

  final int day;
  final int today;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isWhiteDay = FastingRules.whiteDays.contains(day);
    final (height, color) = switch (day) {
      _ when day == today => (14.0, colors.accent),
      _ when isWhiteDay => (10.0, colors.onSurfaceMuted),
      _ when day < today => (6.0, colors.tint(colors.onSurfaceMuted)),
      _ => (6.0, colors.hairline),
    };

    return Align(
      child: Container(
        height: height,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(height / 2),
        ),
      ),
    );
  }
}
