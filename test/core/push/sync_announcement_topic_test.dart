import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/push/sync_announcement_topic.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_push_messaging.dart';

void main() {
  late FakePushMessaging push;
  late SyncAnnouncementTopic sync;

  setUp(() {
    push = FakePushMessaging();
    sync = SyncAnnouncementTopic(push);
  });

  group('topicFor', () {
    test('has one topic per supported language', () {
      expect(SyncAnnouncementTopic.topicFor('en'), 'announcements_en');
      expect(SyncAnnouncementTopic.topicFor('ar'), 'announcements_ar');
    });

    test('falls back to English for other languages', () {
      expect(SyncAnnouncementTopic.topicFor('fr'), 'announcements_en');
    });
  });

  test('subscribes to the language topic and leaves the others', () async {
    final result = await sync('ar');

    expect(result, isA<Ok<void, PushFailure>>());
    expect(push.topics, {'announcements_ar'});
    expect(push.calls, [
      'subscribe announcements_ar',
      'unsubscribe announcements_en',
    ]);
  });

  test('switching language moves the device to one topic', () async {
    await sync('ar');
    await sync('en');

    expect(push.topics, {'announcements_en'});
  });

  test('an unsupported language lands on the English topic', () async {
    await sync('de');

    expect(push.topics, {'announcements_en'});
  });

  test('stops at the first failure and reports its topic', () async {
    push.failTopic = 'announcements_ar';

    final result = await sync('ar');

    expect(
      result,
      isA<Err<void, PushFailure>>().having(
        (err) => err.failure,
        'failure',
        isA<PushTopicFailed>().having(
          (f) => f.topic,
          'topic',
          'announcements_ar',
        ),
      ),
    );
    expect(push.calls, ['subscribe announcements_ar']);
  });
}
