import 'package:fasomo/core/presentation/fasting_type_style.dart';
import 'package:fasomo/core/presentation/fasting_type_text.dart';
import 'package:fasomo/core/theme/app_colors.dart';
import 'package:fasomo/features/tracker/domain/entities/fast_log_summary.dart';
import 'package:fasomo/features/tracker/presentation/bloc/tracker_bloc.dart';
import 'package:fasomo/features/tracker/presentation/widgets/qada_section.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The make-up (Qada) balance, then this month's and this year's totals per
/// fasting type. The streaks live on the Home card.
class TrackerPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(localization.fastingProgress)),
      body: BlocBuilder<TrackerBloc, TrackerState>(
        builder: (context, state) => switch (state.status) {
          TrackerStatus.initial || TrackerStatus.loading => const Center(
            child: CircularProgressIndicator(),
          ),
          TrackerStatus.error => _TrackerError(
            message: localization.fastLogLoadFailed,
          ),
          TrackerStatus.success => _TrackerContent(summary: state.summary),
        },
      ),
    );
  }
}

class _TrackerContent extends StatelessWidget {
  const new({required this.summary});

  final FastLogSummary summary;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        QadaSection(summary: summary),
        const SizedBox(height: 24),
        _PeriodSection(title: localization.thisMonth, totals: summary.month),
        const SizedBox(height: 24),
        _PeriodSection(title: localization.thisYear, totals: summary.year),
      ],
    );
  }
}

class _PeriodSection extends StatelessWidget {
  const new({required this.title, required this.totals});

  final String title;
  final PeriodTotals totals;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(title, style: theme.textTheme.titleLarge)),
            Text(
              localization.fastedOfDue(totals.fastedDays, totals.dueDays),
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: totals.byType.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      localization.noFastingDaysYet,
                      style: theme.textTheme.bodyMedium,
                    ),
                  )
                : Column(
                    children: [
                      for (final total in totals.byType)
                        _TypeTotalRow(total: total),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _TypeTotalRow extends StatelessWidget {
  const new({required this.total});

  final TypeTotal total;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final type = total.type;

    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: type.color(colors),
                shape: BoxShape.circle,
              ),
              child: Icon(type.icon, size: 18, color: type.onColor(colors)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          localization.fastingTypeTitle(type),
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                      Text(
                        localization.fastedOfDue(total.fasted, total.due),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ExcludeSemantics(
                    child: LinearProgressIndicator(
                      value: total.fasted / total.due,
                      color: colors.accent,
                      backgroundColor: colors.hairline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrackerError extends StatelessWidget {
  const new({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(message),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () =>
                context.read<TrackerBloc>().add(const LoadTracker()),
            child: Text(localization.retry),
          ),
        ],
      ),
    );
  }
}
