import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/push/push_messaging.dart';

/// In-memory topic set that records every call.
class FakePushMessaging implements PushMessaging {
  final Set<String> topics = {};
  final List<String> calls = [];

  /// When set, calls for this topic fail.
  String? failTopic;

  @override
  Future<Result<void, PushFailure>> subscribe(String topic) async {
    calls.add('subscribe $topic');
    if (topic == failTopic) return Err(PushTopicFailed(topic));
    topics.add(topic);
    return const Ok(null);
  }

  @override
  Future<Result<void, PushFailure>> unsubscribe(String topic) async {
    calls.add('unsubscribe $topic');
    if (topic == failTopic) return Err(PushTopicFailed(topic));
    topics.remove(topic);
    return const Ok(null);
  }
}
