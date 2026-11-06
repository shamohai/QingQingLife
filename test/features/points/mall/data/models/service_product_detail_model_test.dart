import 'package:flutter_test/flutter_test.dart';
import 'package:qingqinglife/features/points/mall/data/models/service_product_detail_model.dart';

void main() {
  group('ServiceProductDetail carouselimg parsing', () {
    test('extracts the first image from carouselimg list as mainImageUrl', () {
      final json = <String, dynamic>{
        'pid': 1001,
        'name': '积分兑换服务商品',
        'price': 500,
        'carouselimg': [
          'https://img.li91.com/2021/10/500x500/n0/96e4956e3bbb22ca63d6957935eab660.jpg',
          'https://img.li91.com/2023/05/500x500/n0/17c6813f9c23d9020936babe03341d79.jpg',
        ],
      };

      final product = ServiceProductDetail.fromJson(json);

      expect(product.carouselImages.length, 2);
      expect(product.mainImageUrl, 'https://img.li91.com/2021/10/500x500/n0/96e4956e3bbb22ca63d6957935eab660.jpg');
    });

    test('mainImageUrl is empty when carouselimg is null', () {
      final json = <String, dynamic>{'pid': 1002, 'name': '无图服务商品', 'price': 200, 'carouselimg': null};

      final product = ServiceProductDetail.fromJson(json);

      expect(product.carouselImages, isEmpty);
      expect(product.mainImageUrl, '');
    });

    test('mainImageUrl is empty when carouselimg is an empty list', () {
      final json = <String, dynamic>{'pid': 1003, 'name': '空轮播图商品', 'price': 300, 'carouselimg': <String>[]};

      final product = ServiceProductDetail.fromJson(json);

      expect(product.carouselImages, isEmpty);
      expect(product.mainImageUrl, '');
    });

    test('handles JSON-encoded array string or single string in carouselimg', () {
      final jsonWithJsonString = <String, dynamic>{'pid': 1004, 'name': '字符串形式轮播图商品', 'price': 400, 'carouselimg': '["https://img.li91.com/single.jpg"]'};

      final product = ServiceProductDetail.fromJson(jsonWithJsonString);

      expect(product.carouselImages, ['https://img.li91.com/single.jpg']);
      expect(product.mainImageUrl, 'https://img.li91.com/single.jpg');
    });

    test('normalizes protocol-relative URL starting with //', () {
      final json = <String, dynamic>{
        'pid': 1005,
        'name': '协议相对路径商品',
        'price': 100,
        'carouselimg': ['//img.li91.com/image.jpg'],
      };

      final product = ServiceProductDetail.fromJson(json);

      expect(product.mainImageUrl, 'https://img.li91.com/image.jpg');
    });
  });
}
