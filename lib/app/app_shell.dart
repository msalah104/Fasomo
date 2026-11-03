import 'dart:async';

import 'package:clock/clock.dart';
import 'package:fasomo/core/calendar/calendar_days.dart';
import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/core/di/injection_container.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/presentation/localized_notification_copy.dart';
import 'package:fasomo/features/about/presentation/pages/about_page.dart';
import 'package:fasomo/features/backup/presentation/bloc/backup_bloc.dart';
import 'package:fasomo/features/backup/presentation/widgets/backup_tiles.dart';
import 'package:fasomo/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:fasomo/features/calendar/presentation/pages/calendar_page.dart';
import 'package:fasomo/features/duas/domain/usecases/get_fasting_hadith.dart';
import 'package:fasomo/features/duas/presentation/bloc/duas_bloc.dart';
import 'package:fasomo/features/duas/presentation/dua_text.dart';
import 'package:fasomo/features/duas/presentation/pages/duas_page.dart';
import 'package:fasomo/features/duas/presentation/widgets/duas_button.dart';
import 'package:fasomo/features/home/presentation/bloc/home_bloc.dart';
import 'package:fasomo/features/home/presentation/bloc/sky_bloc.dart';
import 'package:fasomo/features/home/presentation/pages/home_page.dart';
import 'package:fasomo/features/ramadan/presentation/bloc/ramadan_bloc.dart';
import 'package:fasomo/features/ramadan/presentation/bloc/suhoor_iftar_bloc.dart';
import 'package:fasomo/features/ramadan/presentation/widgets/ramadan_spotlight.dart';
import 'package:fasomo/features/ramadan/presentation/widgets/suhoor_iftar_reminders.dart';
import 'package:fasomo/features/reminders/presentation/bloc/notification_tone_bloc.dart';
import 'package:fasomo/features/reminders/presentation/bloc/reminder_bloc.dart';
import 'package:fasomo/features/reminders/presentation/pages/reminder_settings_page.dart';
import 'package:fasomo/features/reminders/presentation/widgets/notification_tone_tile.dart';
import 'package:fasomo/features/settings/presentation/bloc/hijri_adjustment_bloc.dart';
import 'package:fasomo/features/settings/presentation/bloc/language_bloc.dart';
import 'package:fasomo/features/settings/presentation/bloc/prayer_settings_bloc.dart';
import 'package:fasomo/features/settings/presentation/bloc/theme_bloc.dart';
import 'package:fasomo/features/settings/presentation/pages/settings_page.dart';
import 'package:fasomo/features/settings/presentation/widgets/settings_button.dart';
import 'package:fasomo/features/settings/presentation/widgets/settings_section.dart';
import 'package:fasomo/features/share_day/presentation/shareable_fasting_day.dart';
import 'package:fasomo/features/share_day/presentation/widgets/share_day_button.dart';
import 'package:fasomo/features/tracker/presentation/bloc/tracker_bloc.dart';
import 'package:fasomo/features/tracker/presentation/widgets/fasted_toggle.dart';
import 'package:fasomo/features/tracker/presentation/widgets/qada_reminder_tile.dart';
import 'package:fasomo/features/tracker/presentation/widgets/tracker_day_actions.dart';
import 'package:fasomo/features/tracker/presentation/widgets/tracker_day_badge.dart';
import 'package:fasomo/features/tracker/presentation/widgets/tracker_summary_card.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The bottom-navigation shell. It is the one place that composes features,
/// so features never import each other.
class AppShell extends StatefulWidget {
  const new({
    this.promptForNotifications = true,
    this.showHomeRequests,
    super.key,
  });

  /// Whether to ask for notification permission once the app shows, on the
  /// first launch only. Off when onboarding has just dealt with it.
  final bool promptForNotifications;

  /// Each event brings the user back to the Home tab, e.g. a tap on the
  /// home-screen widget while the app is open on another screen.
  final Stream<void>? showHomeRequests;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  /// The foreground sync is the reliability backbone for reminders: it
  /// refills the rolling window and repairs anything the OS dropped.
  late final AppLifecycleListener _lifecycle;

  StreamSubscription<void>? _showHomeRequests;

  @override
  void initState() {
    super.initState();
    _showHomeRequests = widget.showHomeRequests?.listen((_) => _showHome());
    _lifecycle = AppLifecycleListener(
      onResume: () {
        context.read<ReminderBloc>().add(const SyncRequested());
        // "Today" may have moved on, which changes streaks and totals.
        context.read<TrackerBloc>().add(const RefreshTracker());
      },
    );
    // Every reminder starts out on, so permission is asked once the app is
    // showing, on the first launch only.
    if (widget.promptForNotifications) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<ReminderBloc>().add(const PermissionPromptRequested());
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Runs on the first build and whenever the language changes.
    context.read<ReminderBloc>().add(
      ReminderCopyChanged(
        LocalizedNotificationCopy(AppLocalizations.of(context)),
      ),
    );
  }

  @override
  void dispose() {
    unawaited(_showHomeRequests?.cancel());
    _lifecycle.dispose();
    super.dispose();
  }

  /// Closes anything pushed over the shell and selects the Home tab.
  void _showHome() {
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
    setState(() => _selectedIndex = 0);
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final titles = [
      localization.home,
      localization.calendar,
      localization.reminders,
      localization.about,
    ];

    return MultiBlocListener(
      listeners: [
        BlocListener<TrackerBloc, TrackerState>(
          listenWhen: (previous, current) =>
              current.failure != null && current != previous,
          listener: (context, state) =>
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    switch (state.failure) {
                      _ when state.status == TrackerStatus.error =>
                        localization.fastLogLoadFailed,
                      TrackerFailure() => localization.qadaSaveFailed,
                      _ => localization.fastLogSaveFailed,
                    },
                  ),
                ),
              ),
        ),
        // The make-up reminders follow the balance and their settings, so
        // any change to either reschedules the notifications.
        BlocListener<TrackerBloc, TrackerState>(
          listenWhen: (previous, current) =>
              current.status == TrackerStatus.success &&
              (previous.summary != current.summary ||
                  previous.qadaReminders != current.qadaReminders),
          listener: (context, _) =>
              context.read<ReminderBloc>().add(const SyncRequested()),
        ),
        // The Hijri adjustment moved every Hijri date in the app: reload
        // everything built from them and reschedule the reminders.
        BlocListener<HijriAdjustmentBloc, HijriAdjustmentState>(
          listenWhen: (previous, current) => previous.offset != current.offset,
          listener: (context, _) {
            context.read<HomeBloc>().add(const RefreshHomeData());
            context.read<RamadanBloc>().add(const RamadanRefreshed());
            context.read<CalendarBloc>().add(const LoadCalendar());
            context.read<TrackerBloc>().add(const RefreshTracker());
            context.read<ReminderBloc>().add(const SyncRequested());
          },
        ),
        // New prayer settings move the Ramadan times and the suhoor and
        // iftar reminders.
        BlocListener<PrayerSettingsBloc, PrayerSettingsState>(
          listenWhen: (previous, current) =>
              previous.settings != current.settings,
          listener: (context, _) {
            context.read<RamadanBloc>().add(const RamadanRefreshed());
            context.read<ReminderBloc>().add(const SyncRequested());
          },
        ),
        BlocListener<SuhoorIftarBloc, SuhoorIftarState>(
          listenWhen: (previous, current) =>
              previous.settings != current.settings,
          listener: (context, _) =>
              context.read<ReminderBloc>().add(const SyncRequested()),
        ),
        // On Android the sound belongs to the notification channel, so a
        // new tone means rescheduling every pending reminder. The tone is
        // part of each notification id, so the sync does exactly that.
        BlocListener<NotificationToneBloc, NotificationToneState>(
          listenWhen: (previous, current) => previous.tone != current.tone,
          listener: (context, _) =>
              context.read<ReminderBloc>().add(const SyncRequested()),
        ),
        // A restore may have replaced any stored data: every bloc reads it
        // again (language and theme apply at once) and the reminders are
        // rescheduled from what was restored.
        BlocListener<BackupBloc, BackupState>(
          listenWhen: (previous, current) =>
              previous.status != current.status &&
              current.status == BackupStatus.restored,
          listener: (context, _) => _reloadAfterRestore(context),
        ),
      ],
      child: Scaffold(
        // Home draws its own sky header in place of the app bar.
        appBar: _selectedIndex == 0
            ? null
            : AppBar(
                title: Text(titles[_selectedIndex]),
                actions: [
                  SettingsButton(onPressed: () => _openSettings(context)),
                ],
              ),
        body: IndexedStack(
          index: _selectedIndex,
          children: const [
            _HomeTab(),
            _CalendarTab(),
            ReminderSettingsPage(
              extraSection: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: [QadaReminderCard(), SuhoorIftarReminderCard()],
              ),
            ),
            _AboutTab(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) =>
              setState(() => _selectedIndex = index),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: titles[0],
            ),
            NavigationDestination(
              icon: const Icon(Icons.calendar_today_outlined),
              selectedIcon: const Icon(Icons.calendar_today),
              label: titles[1],
            ),
            NavigationDestination(
              icon: const Icon(Icons.notifications_outlined),
              selectedIcon: const Icon(Icons.notifications),
              label: titles[2],
            ),
            NavigationDestination(
              icon: const Icon(Icons.info_outlined),
              selectedIcon: const Icon(Icons.info),
              label: titles[3],
            ),
          ],
        ),
      ),
    );
  }
}

void _reloadAfterRestore(BuildContext context) {
  context.read<LanguageBloc>().add(const LanguageReloaded());
  context.read<ThemeBloc>().add(const ThemeReloaded());
  context.read<HijriAdjustmentBloc>().add(const HijriOffsetReloaded());
  context.read<PrayerSettingsBloc>().add(const PrayerSettingsReloaded());
  context.read<NotificationToneBloc>().add(const NotificationToneReloaded());
  context.read<SuhoorIftarBloc>().add(const SuhoorIftarReloaded());
  context.read<HomeBloc>().add(const RefreshHomeData());
  context.read<RamadanBloc>().add(const RamadanReloaded());
  context.read<CalendarBloc>().add(const LoadCalendar());
  context.read<TrackerBloc>().add(const LoadTracker());
  // Reloads the reminders, then syncs the notifications.
  context.read<ReminderBloc>().add(const LoadReminders());
}

/// Opens the settings page, with the sections other features contribute.
void _openSettings(BuildContext context) {
  // "Today" may have moved on since the adjustment preview was computed.
  context.read<HijriAdjustmentBloc>().add(const HijriPreviewRefreshed());
  // The location may have changed, and with it the automatic method.
  context.read<PrayerSettingsBloc>().add(const PrayerSettingsRefreshed());
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) => SettingsPage(
        extraSections: [
          SettingsSection(
            title: AppLocalizations.of(context).settingsNotifications,
            children: const [NotificationToneTile()],
          ),
          SettingsSection(
            title: AppLocalizations.of(context).settingsBackup,
            children: const [BackupTiles()],
          ),
        ],
      ),
    ),
  );
}

/// Opens the duas and intentions, narrowed to [type] when one is given.
void _openDuas(BuildContext context, FastingType? type) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => BlocProvider(
        create: (_) => sl<DuasBloc>()..add(DuasFilterChanged(type)),
        child: const DuasPage(),
      ),
    ),
  );
}

/// What every fasting day offers, on Home's cards and in the calendar's day
/// sheet: its duas, and sharing it as an image with its hadith.
class _FastingDayLinks extends StatelessWidget {
  const new({
    required this.type,
    required this.hijriDate,
    required this.gregorianDate,
    required this.daysUntil,
  });

  /// The day's primary type.
  final FastingType type;
  final HijriDate hijriDate;
  final DateTime gregorianDate;
  final int daysUntil;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final hadith = sl<GetFastingHadith>()(type);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        DuasButton(onPressed: () => _openDuas(context, type)),
        ShareDayButton(
          share: sl(),
          day: ShareableFastingDay(
            type: type,
            hijriDate: hijriDate,
            gregorianDate: gregorianDate,
            daysUntil: daysUntil,
            hadith: hadith == null
                ? null
                : SharedHadith(
                    arabic: hadith.arabic,
                    translation: hadith.translation,
                    reference: localization.hadithReferences(hadith.sources),
                  ),
          ),
        ),
      ],
    );
  }
}

/// About wired to the duas feature.
class _AboutTab extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return AboutPage(onOpenDuas: () => _openDuas(context, null));
  }
}

/// Home wired to the reminders, tracker, Ramadan, duas and share features.
class _HomeTab extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final reminders = context.watch<ReminderBloc>().state;
    return BlocProvider(
      create: (_) => sl<SkyBloc>()..add(const SkyStarted()),
      // A new location moves the prayer times, and so the Ramadan card and
      // the suhoor and iftar reminders.
      child: BlocListener<SkyBloc, SkyState>(
        listenWhen: (previous, current) =>
            previous.scene.location != current.scene.location,
        listener: (context, _) {
          context.read<RamadanBloc>().add(const RamadanRefreshed());
          context.read<ReminderBloc>().add(const SyncRequested());
        },
        child: _HomeWithSlots(reminders: reminders),
      ),
    );
  }
}

class _HomeWithSlots extends StatelessWidget {
  const new({required this.reminders});

  final ReminderState reminders;

  @override
  Widget build(BuildContext context) {
    return HomePage(
      isReminderOn: reminders.isEnabledFor,
      onToggleReminder: (type) =>
          context.read<ReminderBloc>().add(ToggleReminder(type)),
      headerActionBuilder: (color) => SettingsButton(
        color: color,
        onPressed: () => _openSettings(context),
      ),
      spotlightSection: RamadanSpotlight(
        fastedActionBuilder: (date, hijri) =>
            FastedToggle(date: date, hijri: hijri),
      ),
      progressSection: const TrackerSummaryCard(),
      todayActionBuilder: (date, hijri) =>
          FastedToggle(date: date, hijri: hijri),
      dayActionBuilder: (day) => _FastingDayLinks(
        type: day.primaryType,
        hijriDate: day.hijriDate,
        gregorianDate: day.gregorianDate,
        daysUntil: day.daysUntil,
      ),
    );
  }
}

/// Calendar wired to the tracker, duas and share features.
class _CalendarTab extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final summary = context.watch<TrackerBloc>().state.summary;
    return CalendarPage(
      dayBadgeBuilder: (day) => switch (summary.markFor(day.gregorianDate)) {
        final mark? => TrackerDayBadge(mark: mark),
        null => null,
      },
      dayActionBuilder: (day) {
        final actions = [
          if (TrackerDayActions.appliesTo(
            date: day.gregorianDate,
            hijri: day.hijriDate,
            today: clock.now(),
          ))
            TrackerDayActions(date: day.gregorianDate, hijri: day.hijriDate),
          if (day.fastingTypes.firstOrNull case final type?)
            _FastingDayLinks(
              type: type,
              hijriDate: day.hijriDate,
              gregorianDate: day.gregorianDate,
              daysUntil: CalendarDays.between(clock.now(), day.gregorianDate),
            ),
        ];
        return actions.isEmpty
            ? null
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 8,
                children: actions,
              );
      },
    );
  }
}
