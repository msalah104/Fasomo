import 'package:fasomo/core/theme/app_colors.dart';
import 'package:fasomo/features/tracker/domain/entities/qada_pace.dart';
import 'package:fasomo/features/tracker/presentation/qada_reminder_text.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

/// The suggested pace switch, with the pace it works out from the balance
/// shown even while it's off, so the user can see what it would plan.
class SuggestedPaceOption extends StatelessWidget {
  const new({
    required this.enabled,
    required this.pace,
    required this.onChanged,
    super.key,
  });

  final bool enabled;

  /// `null` when nothing is owed.
  final QadaPace? pace;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final pace = this.pace;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(localization.suggestedPace),
          subtitle: Text(localization.suggestedPaceHint),
          value: enabled,
          onChanged: onChanged,
        ),
        if (pace != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.route_outlined, color: colors.accent),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    localization.qadaPaceDescription(pace),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
