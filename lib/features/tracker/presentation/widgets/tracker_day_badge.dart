import 'package:fasomo/core/theme/app_colors.dart';
import 'package:fasomo/features/tracker/domain/entities/fast_log_summary.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

/// A small icon for a logged day: a check when fasted, a turn-back arrow for
/// a make-up fast and a cross for a missed Ramadan day. Each mark has its own
/// shape and label, so it never rests on colour alone.
class TrackerDayBadge extends StatelessWidget {
  const new({required this.mark, super.key});

  final DayMark mark;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final (icon, color, label) = switch (mark) {
      DayMark.fasted => (
        Icons.check_circle,
        colors.accent,
        localization.fasted,
      ),
      DayMark.makeUp => (Icons.history, colors.accent, localization.madeUp),
      DayMark.missed => (Icons.cancel, colors.danger, localization.missed),
    };
    return Semantics(
      label: label,
      child: Icon(icon, size: 14, color: color),
    );
  }
}
