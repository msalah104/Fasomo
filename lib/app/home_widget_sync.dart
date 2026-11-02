import 'dart:async';

import 'package:fasomo/core/presentation/localized_home_widget_copy.dart';
import 'package:fasomo/core/widget/sync_home_widget.dart';
import 'package:fasomo/features/settings/presentation/bloc/hijri_adjustment_bloc.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Keeps the home-screen widget's snapshot current: publishes it when the
/// app starts and resumes ("today" may have moved on), when the language
/// changes, and when the Hijri adjustment moves every date.
class HomeWidgetSync extends StatefulWidget {
  const new({required this.sync, required this.child, super.key});

  final SyncHomeWidget sync;
  final Widget child;

  @override
  State<HomeWidgetSync> createState() => _HomeWidgetSyncState();
}

class _HomeWidgetSyncState extends State<HomeWidgetSync> {
  late final AppLifecycleListener _lifecycle;
  LocalizedHomeWidgetCopy? _copy;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _publish);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Runs on the first build and whenever the language changes; the copy is
    // equal per language, so other dependency changes publish nothing.
    final copy = LocalizedHomeWidgetCopy(AppLocalizations.of(context));
    if (copy == _copy) return;
    _copy = copy;
    _publish();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  void _publish() {
    final copy = _copy;
    if (copy == null) return;
    // The gateway logs and returns its failures; the next trigger retries.
    unawaited(widget.sync(copy));
  }

  @override
  Widget build(BuildContext context) =>
      BlocListener<HijriAdjustmentBloc, HijriAdjustmentState>(
        listenWhen: (previous, current) => previous.offset != current.offset,
        listener: (_, _) => _publish(),
        child: widget.child,
      );
}
