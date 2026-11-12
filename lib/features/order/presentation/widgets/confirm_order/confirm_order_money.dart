/// 确认订单页金额格式化：分 → ¥x.xx
String formatConfirmOrderMoney(int cents) => '¥${(cents / 100).toStringAsFixed(2)}';
