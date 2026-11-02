import 'dart:async';

import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/presentation/fasting_type_text.dart';
import 'package:fasomo/core/share/share_widget_image.dart';
import 'package:fasomo/core/theme/app_theme.dart';
import 'package:fasomo/features/share_day/presentation/share_day_text.dart';
import 'package:fasomo/features/share_day/presentation/shareable_fasting_day.dart';
import 'package:fasomo/features/share_day/presentation/widgets/fasting_day_share_card.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

/// Shares a fasting day as an image card with a short text.
///
/// The only state it keeps is whether a share is under way, so a second tap
/// cannot open a second sheet.
class ShareDayButton extends StatefulWidget {
  const new({required this.day, required this.share, super.key});

  final ShareableFastingDay day;

  /// Draws and shares the card; the app shell injects it.
  final ShareWidgetImage share;

  @override
  State<ShareDayButton> createState() => _ShareDayButtonState();
}

class _ShareDayButtonState extends State<ShareDayButton> {
  bool _sharing = false;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return Tooltip(
      message: localization.shareDayTooltip(
        localization.fastingTypeTitle(widget.day.type),
      ),
      child: OutlinedButton.icon(
        onPressed: _sharing ? null : () => unawaited(_share()),
        icon: const Icon(Icons.share_outlined),
        label: Text(localization.shareDay),
      ),
    );
  }

  Future<void> _share() async {
    final localization = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final box = context.findRenderObject();
    final origin = box is RenderBox && box.hasSize
        ? box.localToGlobal(Offset.zero) & box.size
        : null;
    setState(() => _sharing = true);
    final result = await widget.share(
      context,
      image: _CardFrame(child: FastingDayShareCard(day: widget.day)),
      fileName: widget.day.fileName,
      text: localization.shareMessage(widget.day),
      origin: origin,
    );
    if (!mounted) return;
    setState(() => _sharing = false);
    if (result case Err()) {
      messenger.showSnackBar(
        SnackBar(content: Text(localization.shareDayFailed)),
      );
    }
  }
}

/// The card as it is drawn into the image: always on the night theme, so a
/// shared day looks the same from every phone, and at the base text size,
/// because the picture is a fixed artifact read on other people's screens,
/// not text this device's reader settings apply to.
class _CardFrame extends StatelessWidget {
  const new({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.withNoTextScaling(
      child: Theme(data: buildAppTheme(Brightness.dark), child: child),
    );
  }
}
