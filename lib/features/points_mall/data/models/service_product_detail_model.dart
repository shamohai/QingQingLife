/// 积分商城服务商品详情数据模型（本地 mock，待 API 对接后替换）
class ServiceProductDetail {
  final String id;
  final String? heroImageUrl; // null 时使用 CSS 渐变背景
  final String title;
  final List<String> tags; // ["旅游券", "三日游"]
  final int points;
  final int remainingStock;
  final int salesCount;
  final double marketPrice; // 市场价，如 760.0
  final String mainImageUrl;
  final String description;

  const ServiceProductDetail({
    required this.id,
    this.heroImageUrl,
    required this.title,
    required this.tags,
    required this.points,
    required this.remainingStock,
    required this.salesCount,
    required this.marketPrice,
    required this.mainImageUrl,
    required this.description,
  });

  static const ServiceProductDetail mock = ServiceProductDetail(
    id: 'service_001',
    heroImageUrl: null,
    title: '天佑德电商专供青海环线三日游旅游券（青海三日游）',
    tags: ['旅游券', '三日游'],
    points: 1000,
    remainingStock: 100,
    salesCount: 90000,
    marketPrice: 760.00,
    mainImageUrl: 'assets/images/service/service_product_main.png',
    description:
        '持本旅游券即可兑换青海环线 3 天 2 晚跟团之旅，打卡青海经典核心美景，远离城市喧嚣，沉浸式感受青藏高原辽阔风光。行程轻松不赶路，适合朋友结伴、家庭出游，随团省心出行，不用费心规划路线。',
  );
}
