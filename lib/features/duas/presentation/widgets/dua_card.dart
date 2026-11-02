import 'dart:async';

import 'package:fasomo/core/presentation/arabic_text.dart';
import 'package:fasomo/features/duas/domain/entities/dua.dart';
import 'package:fasomo/features/duas/presentation/dua_text.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// One text: its title, the Arabic, and, in a non-Arabic language, the
/// transliteration and the meaning, then its sources. Everything can be
/// selected, and the copy button copies the whole text.
class DuaCard extends StatelessWidget {
  const new({required this.dua, super.key});

  final Dua dua;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final showEnglish = !_isArabic(context);
    final title = localization.duaTitle(dua.id);
    final note = localization.duaNote(dua.id);
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.secondary,
    );

    return Card(
      margin: const EdgeInsetsDirectional.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 4, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _CopyButton(dua: dua, title: title, withEnglish: showEnglish),
              ],
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ArabicText(dua.arabic, selectable: true),
                  if (showEnglish) ...[
                    if (dua.transliteration case final transliteration?) ...[
                      const SizedBox(height: 8),
                      SelectableText(
                        transliteration,
                        style: muted?.copyWith(fontStyle: FontStyle.italic),
                      ),
                    ],
                    const SizedBox(height: 8),
                    SelectableText(
                      dua.translation,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                  if (note != null) ...[
                    const SizedBox(height: 8),
                    Text(note, style: muted),
                  ],
                  const SizedBox(height: 12),
                  SelectableText(
                    localization.duaSources(
                      localization.hadithReferences(dua.sources),
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.secondary,
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

  static bool _isArabic(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'ar';
}

class _CopyButton extends StatelessWidget {
  const new({
    required this.dua,
    required this.title,
    required this.withEnglish,
  });

  final Dua dua;
  final String title;
  final bool withEnglish;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: AppLocalizations.of(context).duaCopy(title),
      icon: const Icon(Icons.copy_outlined),
      onPressed: () => unawaited(_copy(context)),
    );
  }

  Future<void> _copy(BuildContext context) async {
    final localization = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final text = [
      dua.arabic,
      if (withEnglish) ...[?dua.transliteration, dua.translation],
      localization.duaSources(localization.hadithReferences(dua.sources)),
    ].join('\n\n');
    await Clipboard.setData(ClipboardData(text: text));
    messenger.showSnackBar(SnackBar(content: Text(localization.duaCopied)));
  }
}
