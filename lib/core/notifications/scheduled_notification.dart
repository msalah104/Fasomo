import 'package:equatable/equatable.dart';

/// A notification the OS should hold, fully resolved.
class ScheduledNotification extends Equatable {
  const new({
    required this.id,
    required this.fireAt,
    required this.title,
    required this.body,
    required this.payload,
  });

  /// Deterministic; see `DeterministicId`.
  final int id;

  /// Local wall-clock fire time. The gateway resolves it in `tz.local`.
  final DateTime fireAt;
  final String title;
  final String body;

  /// Serializable routing hint, e.g. `reminder/whiteDays/2026-11-02`.
  final String payload;

  @override
  List<Object> get props => [id, fireAt, title, body, payload];
}
