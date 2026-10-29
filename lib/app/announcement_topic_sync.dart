import 'dart:async';

import 'package:fasomo/core/push/sync_announcement_topic.dart';
import 'package:flutter/widgets.dart';

/// Moves the device to the announcements topic of the language the app is
/// actually shown in: the picked language, or the device language when the
/// user follows the system, after the app's own fallback.
class AnnouncementTopicSync extends StatefulWidget {
  const new({required this.sync, required this.child, super.key});

  final SyncAnnouncementTopic sync;
  final Widget child;

  @override
  State<AnnouncementTopicSync> createState() => _AnnouncementTopicSyncState();
}

class _AnnouncementTopicSyncState extends State<AnnouncementTopicSync> {
  String? _syncedLanguage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final language = Localizations.localeOf(context).languageCode;
    if (language == _syncedLanguage) return;
    _syncedLanguage = language;
    // Failures are logged at the gateway and retried on the next launch or
    // language change; nothing here waits on the network.
    unawaited(widget.sync(language));
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
