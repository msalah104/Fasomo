import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../home/presentation/bloc/home_bloc.dart';

class CalendarHeader extends StatelessWidget {
  final int month;
  final int year;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  const CalendarHeader({
    super.key,
    required this.month,
    required this.year,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<HomeBloc>().state.locale;
    final monthNames = locale.languageCode == 'ar'
        ? AppConstants.arabicMonthNames
        : AppConstants.englishMonthNames;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(
                locale.languageCode == 'ar'
                    ? Icons.chevron_right
                    : Icons.chevron_left,
              ),
              onPressed: onPreviousMonth,
              tooltip: 'Previous Month',
            ),
            Column(
              children: [
                Text(
                  monthNames[month - 1],
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$year ${locale.languageCode == 'ar' ? 'هـ' : 'AH'}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                ),
              ],
            ),
            IconButton(
              icon: Icon(
                locale.languageCode == 'ar'
                    ? Icons.chevron_left
                    : Icons.chevron_right,
              ),
              onPressed: onNextMonth,
              tooltip: 'Next Month',
            ),
          ],
        ),
      ),
    );
  }
}
