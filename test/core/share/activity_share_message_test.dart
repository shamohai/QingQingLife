import 'package:flutter_test/flutter_test.dart';
import 'package:qingqinglife/core/share/activity_share_message.dart';

void main() {
  group('ActivityShareMessage', () {
    test('parses H5 share data and trims string values', () {
      final message = ActivityShareMessage.tryParse(
        '{"title":" 活动标题 ","description":" 活动说明 ","url":"https://example.com/event","imageUrl":"https://example.com/cover.png"}',
      );

      expect(message, isNotNull);
      expect(message!.title, '活动标题');
      expect(message.description, '活动说明');
      expect(message.url, 'https://example.com/event');
      expect(message.imageUrl, 'https://example.com/cover.png');
    });

    test('ignores malformed JSON and non-object messages', () {
      expect(ActivityShareMessage.tryParse('not-json'), isNull);
      expect(ActivityShareMessage.tryParse('[]'), isNull);
    });

    test('uses current page URL if H5 omits or provides an invalid URL', () {
      final missingUrl = ActivityShareMessage.tryParse('{"title":"活动"}')!;
      expect(missingUrl.toSharePayload(fallbackTitle: '活动详情', fallbackUrl: 'https://example.com/current').url, 'https://example.com/current');

      final invalidUrl = ActivityShareMessage.tryParse('{"url":"javascript:alert(1)"}')!;
      expect(invalidUrl.toSharePayload(fallbackTitle: '活动详情', fallbackUrl: 'https://example.com/current').url, 'https://example.com/current');
    });

    test('does not pass non-web fallback URLs to the share payload', () {
      final message = ActivityShareMessage.tryParse('{"url":"file:///private/event"}')!;
      expect(message.toSharePayload(fallbackTitle: '活动详情', fallbackUrl: null).url, isNull);
    });
  });
}
