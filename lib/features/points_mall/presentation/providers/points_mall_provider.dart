import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 积分商城数据 Provider
/// 一期使用 Mock 数据，后续接入真实 API 时替换
final pointsMallDataProvider = Provider<PointsMallDataProvider>((ref) => const PointsMallDataProvider());

class PointsMallDataProvider {
  const PointsMallDataProvider();

  // 当前用户积分余额
  int get currentPoints => 3580;

  // 积分即将过期的数量
  int get expiringPoints => 800;

  // 积分商城 Banner
  String get bannerUrl => 'https://picsum.photos/750/240?random=30';

  // 积分规则
  String get rulesText =>
      '积分规则：每日签到得10积分，消费1元得1积分，积分有效期12个月，到期前30天短信提醒。';

  // 积分商品列表
  List<Map<String, dynamic>> get products => [
    {'id': 'p1', 'imageUrl': 'https://picsum.photos/300/300?random=40', 'name': '天佑德青稞酒 500ml', 'points': 2000, 'stock': 56},
    {'id': 'p2', 'imageUrl': 'https://picsum.photos/300/300?random=41', 'name': '青海牛肉干 100g', 'points': 1500, 'stock': 128},
    {'id': 'p3', 'imageUrl': 'https://picsum.photos/300/300?random=42', 'name': '有机菜籽油 5L', 'points': 3000, 'stock': 32},
    {'id': 'p4', 'imageUrl': 'https://picsum.photos/300/300?random=43', 'name': '枸杞礼盒 250g', 'points': 800, 'stock': 200},
    {'id': 'p5', 'imageUrl': 'https://picsum.photos/300/300?random=44', 'name': '青稞饼干 500g', 'points': 500, 'stock': 300},
    {'id': 'p6', 'imageUrl': 'https://picsum.photos/300/300?random=45', 'name': '红酒 750ml', 'points': 5000, 'stock': 15},
  ];
}