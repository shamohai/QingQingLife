/// 订单类型枚举
/// 用于区分商城订单、积分订单和服务订单，影响卡片展示和按钮逻辑
enum OrderType {
  /// 普通商城订单（人民币支付）
  mall('商城订单'),

  /// 积分兑换订单
  points('积分订单'),

  /// 服务预约订单
  service('服务订单');

  const OrderType(this.label);
  final String label;

  /// 从字符串解析
  static OrderType fromString(String value) {
    switch (value) {
      case 'mall':
        return OrderType.mall;
      case 'points':
        return OrderType.points;
      case 'service':
        return OrderType.service;
      default:
        return OrderType.mall;
    }
  }
}
