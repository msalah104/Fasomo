import 'dart:async';

import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/notifications/notification_tone.dart';
import 'package:fasomo/features/reminders/presentation/bloc/notification_tone_bloc.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Settings tile showing the reminder sound; tapping it opens a picker where
/// each sound can be played before it is chosen.
class NotificationToneTile extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final current = context.select<NotificationToneBloc, NotificationTone>(
      (bloc) => bloc.state.tone,
    );

    return BlocListener<NotificationToneBloc, NotificationToneState>(
      listenWhen: (previous, current) =>
          (current.failure != null || current.permissionDenied) &&
          current != previous,
      listener: _showProblem,
      child: ListTile(
        leading: Icon(_iconOf(current)),
        title: Text(localization.notificationTone),
        subtitle: Text(localization.toneName(current, context)),
        onTap: () => unawaited(_choose(context, current)),
      ),
    );
  }

  Future<void> _choose(BuildContext context, NotificationTone current) async {
    final bloc = context.read<NotificationToneBloc>();
    final choice = await showDialog<NotificationTone>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: _TonePickerDialog(selected: current),
      ),
    );
    if (choice != null && choice != current) {
      bloc.add(NotificationToneChanged(choice));
    }
  }
}

void _showProblem(BuildContext context, NotificationToneState state) {
  final localization = AppLocalizations.of(context);
  final message = state.permissionDenied
      ? localization.notificationsDenied
      : switch (state.failure) {
          NotificationFailure() => localization.notificationTonePreviewFailed,
          StorageFailure() ||
          CalendarFailure() ||
          TrackerFailure() ||
          PushFailure() ||
          ShareFailure() ||
          LocationFailure() ||
          HomeWidgetFailure() ||
          null => localization.settingSaveFailed,
        };
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

IconData _iconOf(NotificationTone tone) => switch (tone) {
  NotificationTone.vibrateOnly => Icons.vibration,
  NotificationTone.systemDefault ||
  NotificationTone.softChime ||
  NotificationTone.bell ||
  NotificationTone.gentle => Icons.music_note_outlined,
};

/// Lists every sound with the current one ticked. Tapping a row chooses it;
/// the play button beside it previews it without choosing.
class _TonePickerDialog extends StatelessWidget {
  const new({required this.selected});

  final NotificationTone selected;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(AppLocalizations.of(context).notificationTone),
      children: [
        for (final tone in NotificationTone.values)
          _ToneOption(tone: tone, isSelected: tone == selected),
      ],
    );
  }
}

class _ToneOption extends StatelessWidget {
  const new({required this.tone, required this.isSelected});

  final NotificationTone tone;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final name = localization.toneName(tone, context);

    // The tick, not only the highlight colour, marks the current choice.
    return ListTile(
      contentPadding: const EdgeInsetsDirectional.only(start: 24, end: 12),
      leading: isSelected
          ? const Icon(Icons.check)
          : const SizedBox.square(dimension: 24),
      title: Text(name),
      selected: isSelected,
      trailing: IconButton(
        icon: Icon(
          tone == NotificationTone.vibrateOnly
              ? Icons.vibration
              : Icons.play_circle_outline,
        ),
        tooltip: localization.notificationTonePlay(name),
        onPressed: () => context.read<NotificationToneBloc>().add(
          NotificationTonePreviewRequested(
            tone,
            title: localization.notificationTonePreviewTitle,
            body: localization.notificationTonePreviewBody(name),
          ),
        ),
      ),
      onTap: () => Navigator.of(context).pop(tone),
    );
  }
}

extension on AppLocalizations {
  String toneName(NotificationTone tone, BuildContext context) =>
      switch (tone) {
        NotificationTone.systemDefault => notificationToneSystem,
        NotificationTone.softChime => notificationToneSoftChime,
        NotificationTone.bell => notificationToneBell,
        NotificationTone.gentle => notificationToneGentle,
        // iOS can't vibrate for an app's notification without a sound, so
        // there the choice is honestly called silent.
        NotificationTone.vibrateOnly => switch (Theme.of(context).platform) {
          TargetPlatform.iOS => notificationToneSilent,
          TargetPlatform.android ||
          TargetPlatform.fuchsia ||
          TargetPlatform.linux ||
          TargetPlatform.macOS ||
          TargetPlatform.windows => notificationToneVibrateOnly,
        },
      };
}
