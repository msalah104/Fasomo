import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/push/push_messaging.dart';
import 'package:fasomo/core/usecases/usecase.dart';

/// Keeps the device on exactly one announcements topic: the one for the
/// language the app is shown in, so each broadcast arrives in that language.
class SyncAnnouncementTopic
    implements UseCase<Future<Result<void, PushFailure>>, String> {
  const new(this.push);

  final PushMessaging push;

  /// Languages with their own topic; anything else gets [fallbackLanguage].
  static const supportedLanguages = ['en', 'ar'];
  static const fallbackLanguage = 'en';

  /// The topic for [languageCode], e.g. `announcements_ar`.
  static String topicFor(String languageCode) {
    final language = supportedLanguages.contains(languageCode)
        ? languageCode
        : fallbackLanguage;
    return 'announcements_$language';
  }

  /// Subscribes to the topic for [params] (a language code) and leaves the
  /// other languages' topics. Stops at the first failure; the next call
  /// retries the whole set.
  @override
  Future<Result<void, PushFailure>> call(String params) async {
    final wanted = topicFor(params);
    final subscribed = await push.subscribe(wanted);
    if (subscribed is Err) return subscribed;

    for (final language in supportedLanguages) {
      final topic = topicFor(language);
      if (topic == wanted) continue;
      final left = await push.unsubscribe(topic);
      if (left is Err) return left;
    }
    return const Ok(null);
  }
}
