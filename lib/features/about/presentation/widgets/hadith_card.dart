import 'package:flutter/material.dart';

class HadithCard extends StatelessWidget {
  const new({
    required this.title,
    required this.hadith,
    required this.icon,
    required this.color,
    required this.onColor,
    super.key,
  });
  final String title;
  final String hadith;
  final IconData icon;

  /// The fasting type's colour, used for the icon well and the quote rule.
  final Color color;

  /// The icon colour drawn on [color].
  final Color onColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsetsDirectional.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: onColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
                // Non-uniform borders cannot take a borderRadius.
                border: BorderDirectional(
                  start: BorderSide(color: color, width: 3),
                ),
              ),
              child: Text(
                hadith,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
