import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';

/// The port to the remote push service. Announcements are broadcast to topics,
/// so the app never registers a user or uploads a device token anywhere else.
abstract interface class PushMessaging {
  Future<Result<void, PushFailure>> subscribe(String topic);
  Future<Result<void, PushFailure>> unsubscribe(String topic);
}

/// Shows an announcement that arrived while the app was in the foreground,
/// where Android does not display push notifications by itself.
abstract interface class AnnouncementPresenter {
  Future<void> showAnnouncement({
    required int id,
    required String title,
    required String body,
  });
}
