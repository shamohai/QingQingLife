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

    test('strips lnglat, province, accesstoken, t, and area from shareUrlForSharing', () {
      const payload = SharePayload(
        title: '酒王活动',
        url: 'https://lottery.crm.qkj.com.cn/rank//?t=1793945298395&area=beijing#/pages/index/team?aid=526497927422545920&lnglat=116.4074%2C39.9042&province=%E5%8C%97%E4%BA%AC%E5%B8%82&accesstoken=c959a90108654a6482fcd0021534760d',
      );

      expect(
        payload.shareUrlForSharing.toString(),
        'https://lottery.crm.qkj.com.cn/rank//#/pages/index/team?aid=526497927422545920',
      );
    });

    test('builds wrapped openapp share URL with drink map option', () {
      const payload = SharePayload(
        title: '酒王活动',
        url: 'https://lottery.crm.qkj.com.cn/rank//?t=1793945298395&area=beijing#/pages/index/team?aid=526497927422545920&lnglat=116.4074%2C39.9042&province=%E5%8C%97%E4%BA%AC%E5%B8%82&accesstoken=c959a90108654a6482fcd0021534760d',
        wrapWithDrinkMapOpenApp: true,
      );

      final finalShareUrl = payload.shareUrlForSharing.toString();
      print('FINAL ENCODED SHARE URL: $finalShareUrl');
      expect(finalShareUrl, startsWith('https://m.mall.qkj.com.cn/mob/common/openapp?appurl='));
    });

    test('builds wrapped openapp share URL for drink map activity', () {
      const payload = SharePayload(
        title: '微醺地图',
        url: 'https://lottery.crm.qkj.com.cn/drink/?t=1793945298395&area=beijing&lnglat=116.4074%2C39.9042&province=%E5%8C%97%E4%BA%AC%E5%B8%82&accesstoken=c959a90108654a6482fcd0021534760d#/pages/index/index?activity=26020262737526&sku=10108069B21',
        wrapWithDrinkMapOpenApp: true,
      );

      final finalShareUrl = payload.shareUrlForSharing.toString();
      print('DRINK MAP FINAL SHARE URL: $finalShareUrl');
      expect(finalShareUrl, startsWith('https://m.mall.qkj.com.cn/mob/common/openapp?appurl='));
    });
  });
}
