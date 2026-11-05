import 'package:flutter_test/flutter_test.dart';
import 'package:qingqinglife/core/share/share_payload.dart';

void main() {
  group('SharePayload', () {
    test('recognizes only absolute HTTP(S) links as shareable URLs', () {
      expect(const SharePayload(title: '服务', url: 'https://example.com/item').hasShareableUrl, isTrue);
      expect(const SharePayload(title: '服务', url: '/points/service/1').hasShareableUrl, isFalse);
      expect(const SharePayload(title: '服务', url: 'javascript:alert(1)').hasShareableUrl, isFalse);
      expect(const SharePayload(title: '服务').hasShareableUrl, isFalse);
    });

    test('builds the mall openapp URL with an encoded App deep link', () {
      final openAppUrl = SharePayload.buildOpenAppUrl(appUrl: 'qingqinglife:///points/service/123');

      expect(openAppUrl.toString(), 'https://m.mall.qkj.com.cn/mob/common/openapp?appurl=qingqinglife%3A%2F%2F%2Fpoints%2Fservice%2F123');
      expect(openAppUrl.queryParameters['appurl'], 'qingqinglife:///points/service/123');
    });

    test('rejects app URLs without a URI scheme', () {
      expect(() => SharePayload.buildOpenAppUrl(appUrl: '/points/service/123'), throwsArgumentError);
    });

    test('creates plain text without inventing a URL', () {
      expect(const SharePayload(title: '商品', description: '商品描述').plainText, '商品\n商品描述');
      expect(const SharePayload(title: '商品', url: 'https://example.com').plainText, '商品\nhttps://example.com');
    });
  });
}
