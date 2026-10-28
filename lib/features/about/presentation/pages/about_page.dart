import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/constants/app_constants.dart';
import 'package:fasomo/core/presentation/fasting_type_style.dart';
import 'package:fasomo/core/presentation/fasting_type_text.dart';
import 'package:fasomo/features/about/presentation/widgets/hadith_card.dart';
import 'package:fasomo/features/about/presentation/widgets/info_section.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _AppHeader(),
        const SizedBox(height: 24),
        Text(localization.aboutApp, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 12),
        InfoSection(
          icon: Icons.info_outline,
          title: localization.aboutApp,
          content: localization.aboutDesc,
        ),
        const SizedBox(height: 24),
        Text(
          localization.islamicReferences,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        for (final (type, hadith) in [
          (FastingType.whiteDays, localization.hadithWhiteDays),
          (FastingType.mondayThursday, localization.hadithMondayThursday),
          (FastingType.arafah, localization.hadithArafah),
          (FastingType.ashura, localization.hadithAshura),
        ])
          HadithCard(
            title: localization.fastingTypeTitle(type),
            hadith: hadith,
            icon: type.icon,
            color: type.color,
          ),
        const SizedBox(height: 24),
        Text(localization.features, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 12),
        InfoSection(
          icon: Icons.calendar_today,
          title: localization.featureCalendarTitle,
          content: localization.featureCalendarDesc,
        ),
        InfoSection(
          icon: Icons.notifications,
          title: localization.reminders,
          content: localization.featureRemindersDesc,
        ),
        InfoSection(
          icon: Icons.language,
          title: localization.featureLanguagesTitle,
          content: localization.featureLanguagesDesc,
        ),
        const SizedBox(height: 24),
        Text(localization.contactSupport, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 12),
        const _ContactCard(),
        const SizedBox(height: 24),
        const _CreditsCard(),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _AppHeader extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
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
              localization.version(AppConstants.appVersion),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final iconColor = Theme.of(context).colorScheme.primary;
    return Card(
      child: Column(
        children: [
          for (final (icon, label, value) in [
            (Icons.email, localization.email, AppConstants.supportEmail),
            (Icons.language, localization.website, AppConstants.website),
            (Icons.code, localization.sourceCode, AppConstants.sourceCode),
          ])
            ListTile(
              leading: Icon(icon, color: iconColor),
              title: Text(label),
              // Addresses are always left-to-right, even in Arabic.
              subtitle: Text(value, textDirection: TextDirection.ltr),
            ),
        ],
      ),
    );
  }
}

class _CreditsCard extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(localization.credits, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Text(localization.creditsText, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            Text(
              localization.copyright,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
