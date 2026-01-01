import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../home/presentation/bloc/home_bloc.dart';
import '../widgets/hadith_card.dart';
import '../widgets/info_section.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final locale = context.watch<HomeBloc>().state.locale;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App Icon and Name
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.mosque,
                      size: 64,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localization.appName,
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${localization.version} ${AppConstants.appVersion}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // About Section
          Text(
            localization.aboutApp,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),

          InfoSection(
            icon: Icons.info_outline,
            title: localization.aboutApp,
            content: localization.aboutDesc,
          ),

          const SizedBox(height: 24),

          // Islamic References Section
          Text(
            localization.islamicReferences,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),

          HadithCard(
            title: localization.whiteDays,
            hadith: localization.hadithWhiteDays,
            icon: Icons.brightness_3,
            color: Colors.green,
          ),

          HadithCard(
            title: localization.mondayThursday,
            hadith: localization.hadithMondayThursday,
            icon: Icons.calendar_view_week,
            color: Colors.orange,
          ),

          HadithCard(
            title: localization.dayOfArafah,
            hadith: localization.hadithArafah,
            icon: Icons.terrain,
            color: Colors.blue,
          ),

          HadithCard(
            title: localization.dayOfAshura,
            hadith: localization.hadithAshura,
            icon: Icons.favorite,
            color: Colors.red,
          ),

          const SizedBox(height: 24),

          // Features Section
          Text(
            'Features',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),

          InfoSection(
            icon: Icons.calendar_today,
            title: 'Hijri Calendar',
            content: locale.languageCode == 'ar'
                ? 'تقويم هجري كامل مع عرض أيام الصيام المستحبة'
                : 'Full Hijri calendar with recommended fasting days marked',
          ),

          InfoSection(
            icon: Icons.notifications,
            title: locale.languageCode == 'ar' ? 'التذكيرات' : 'Reminders',
            content: locale.languageCode == 'ar'
                ? 'تنبيهات ذكية لأيام الصيام القادمة'
                : 'Smart notifications for upcoming fasting days',
          ),

          InfoSection(
            icon: Icons.language,
            title: locale.languageCode == 'ar'
                ? 'دعم اللغات'
                : 'Language Support',
            content: locale.languageCode == 'ar'
                ? 'دعم كامل للغتين العربية والإنجليزية'
                : 'Full support for Arabic and English languages',
          ),

          const SizedBox(height: 24),

          // Contact Section
          Text(
            localization.contactSupport,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.email,
                      color: theme.colorScheme.primary,
                    ),
                    title: const Text('Email'),
                    subtitle: const Text('support@fasomo.app'),
                    onTap: () {
                      // Launch email
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(
                      Icons.language,
                      color: theme.colorScheme.primary,
                    ),
                    title: const Text('Website'),
                    subtitle: const Text('www.fasomo.app'),
                    onTap: () {
                      // Launch website
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(
                      Icons.code,
                      color: theme.colorScheme.primary,
                    ),
                    title: const Text('GitHub'),
                    subtitle: const Text('github.com/fasomo'),
                    onTap: () {
                      // Launch GitHub
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Credits
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Credits',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    locale.languageCode == 'ar'
                        ? 'تم تطوير هذا التطبيق لمساعدة المسلمين على متابعة أيام الصيام المستحبة وفقاً للسنة النبوية الشريفة.'
                        : 'This app was developed to help Muslims track recommended fasting days according to the Sunnah of Prophet Muhammad (PBUH).',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '© 2024 Fasomo. All rights reserved.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
