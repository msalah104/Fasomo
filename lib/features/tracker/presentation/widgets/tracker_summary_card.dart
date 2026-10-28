import 'package:fasomo/core/theme/app_colors.dart';
import 'package:fasomo/features/tracker/presentation/bloc/tracker_bloc.dart';
import 'package:fasomo/features/tracker/presentation/pages/tracker_page.dart';
import 'package:fasomo/features/tracker/presentation/widgets/streak_stat.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The Home card with the current and longest streak and this month's count.
/// Tapping it opens the [TrackerPage].
class TrackerSummaryCard extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = AppColors.of(context);

    return BlocBuilder<TrackerBloc, TrackerState>(
      builder: (context, state) {
        if (state.status != TrackerStatus.success) {
          return const SizedBox.shrink();
        }
        final summary = state.summary;
        return Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const TrackerPage()),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.nightlight_outlined, color: colors.accent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          localization.yourFasting,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      Icon(Icons.chevron_right, color: colors.onSurfaceMuted),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (summary.isEmpty)
                    Text(
                      localization.trackerEmpty,
                      style: theme.textTheme.bodyMedium,
                    )
                  else ...[
                    Row(
                      children: [
                        Expanded(
                          child: StreakStat(
                            value: summary.currentStreak,
                            label: localization.currentStreak,
                          ),
                        ),
                        Expanded(
                          child: StreakStat(
                            value: summary.longestStreak,
                            label: localization.longestStreak,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      localization.monthFastedSummary(
                        summary.month.fastedDays,
                        summary.month.dueDays,
                      ),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
