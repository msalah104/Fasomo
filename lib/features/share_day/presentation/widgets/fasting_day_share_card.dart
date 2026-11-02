import 'package:fasomo/core/presentation/arabic_text.dart';
import 'package:fasomo/core/presentation/date_formatter.dart';
import 'package:fasomo/core/presentation/fasting_type_style.dart';
import 'package:fasomo/core/presentation/logo_mark.dart';
import 'package:fasomo/core/theme/app_colors.dart';
import 'package:fasomo/features/share_day/presentation/share_day_text.dart';
import 'package:fasomo/features/share_day/presentation/shareable_fasting_day.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

/// The image a fasting day is shared as: the ف mark on the night-blue brand
/// colour, the headline, both dates and the day's hadith.
///
/// It is drawn into a picture rather than shown, so it is sized by its
/// width and grows to fit its text.
class FastingDayShareCard extends StatelessWidget {
  const new({required this.day, super.key});

  final ShareableFastingDay day;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final muted = colors.onBrand.withValues(alpha: 0.8);

    return Material(
      color: colors.brand,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                LogoMark(
                  color: colors.accent,
                  dotColor: colors.onBrand,
                  semanticLabel: localization.appName,
                  size: 40,
                ),
                const SizedBox(width: 8),
                Text(
                  localization.appName,
                  style: textTheme.titleLarge?.copyWith(color: colors.onBrand),
                ),
              ],
            ),
            const SizedBox(height: 28),
            _Headline(day: day),
            const SizedBox(height: 16),
            Text(
              localization.formatHijri(day.hijriDate),
              style: textTheme.titleLarge?.copyWith(color: colors.onBrand),
            ),
            const SizedBox(height: 4),
            Text(
              localization.formatGregorian(day.gregorianDate),
              style: textTheme.bodyLarge?.copyWith(color: muted),
            ),
            if (day.hadith case final hadith?) ...[
              const SizedBox(height: 24),
              _Quote(hadith: hadith),
            ],
          ],
        ),
      ),
    );
  }
}

/// The type's icon well and the headline.
class _Headline extends StatelessWidget {
  const new({required this.day});

  final ShareableFastingDay day;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final type = day.type;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: type.color(colors),
            shape: BoxShape.circle,
          ),
          child: Icon(type.icon, color: type.onColor(colors), size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            AppLocalizations.of(context).shareHeadline(day),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: colors.onBrand,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

/// The hadith in Arabic, its meaning outside Arabic, and its reference,
/// behind a gold rule.
class _Quote extends StatelessWidget {
  const new({required this.hadith});

  final SharedHadith hadith;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final showTranslation =
        Localizations.localeOf(context).languageCode != 'ar';
    return Container(
      padding: const EdgeInsetsDirectional.only(start: 14),
      decoration: BoxDecoration(
        border: BorderDirectional(
          start: BorderSide(color: colors.accent, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ArabicText(
            hadith.arabic,
            style: TextStyle(color: colors.onBrand),
          ),
          if (showTranslation) ...[
            const SizedBox(height: 8),
            Text(
              hadith.translation,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onBrand,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            hadith.reference,
            style: textTheme.bodySmall?.copyWith(color: colors.accent),
          ),
        ],
      ),
    );
  }
}
