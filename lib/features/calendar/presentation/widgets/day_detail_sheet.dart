import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_localizations.dart';
import '../../../../core/utils/hijri_utils.dart';
import '../../../home/domain/entities/fasting_day.dart';
import '../../../home/presentation/bloc/home_bloc.dart';
import '../../domain/entities/calendar_day.dart';

class DayDetailSheet extends StatelessWidget {
  final CalendarDay day;

  const DayDetailSheet({
    super.key,
    required this.day,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final locale = context.watch<HomeBloc>().state.locale;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Header
          Text(
            HijriUtils.formatHijriDate(day.hijriDate, locale.languageCode),
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            HijriUtils.formatGregorianDate(
                day.gregorianDate, locale.languageCode),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 24),

          // Fasting Information
          if (day.isFastingDay) ...[
            Text(
              localization.fastingDay,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...day.fastingTypes.map((type) => _buildFastingTypeCard(
                  context,
                  type,
                  localization,
                )),
          ] else ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        locale.languageCode == 'ar'
                            ? 'لا توجد أيام صيام محددة'
                            : 'No specific fasting day',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(localization.cancel),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFastingTypeCard(
    BuildContext context,
    FastingType type,
    AppLocalizations localization,
  ) {
    final theme = Theme.of(context);

    String title = '';
    String description = '';

    switch (type) {
      case FastingType.whiteDays:
        title = localization.whiteDays;
        description = localization.whiteDaysDesc;
        break;
      case FastingType.mondayThursday:
        title = localization.mondayThursday;
        description = localization.mondayThursdayDesc;
        break;
      case FastingType.arafah:
        title = localization.dayOfArafah;
        description = localization.arafahDesc;
        break;
      case FastingType.ashura:
        title = localization.dayOfAshura;
        description = localization.ashuraDesc;
        break;
      case FastingType.tasua:
        title = localization.dayOfTasua;
        description = localization.tasuaDesc;
        break;
      case FastingType.ramadan:
        title = localization.ramadan;
        description = localization.ramadanDesc;
        break;
      case FastingType.shawwal:
        title = localization.shawwalSixDays;
        description = localization.shawwalDesc;
        break;
      default:
        title = 'Fasting Day';
        description = 'Recommended fasting day';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: _getColorForType(type).withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getIconForType(type),
                  color: _getColorForType(type),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: _getColorForType(type),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForType(FastingType type) {
    switch (type) {
      case FastingType.ramadan:
        return Colors.purple;
      case FastingType.arafah:
      case FastingType.ashura:
      case FastingType.tasua:
        return Colors.blue;
      case FastingType.whiteDays:
        return Colors.green;
      case FastingType.mondayThursday:
        return Colors.orange;
      default:
        return Colors.teal;
    }
  }

  IconData _getIconForType(FastingType type) {
    switch (type) {
      case FastingType.ramadan:
        return Icons.mosque;
      case FastingType.arafah:
        return Icons.terrain;
      case FastingType.ashura:
      case FastingType.tasua:
        return Icons.favorite;
      case FastingType.whiteDays:
        return Icons.brightness_3;
      case FastingType.mondayThursday:
        return Icons.calendar_view_week;
      default:
        return Icons.star;
    }
  }
}
