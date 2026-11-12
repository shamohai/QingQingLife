/// 积分商城商品分页 Provider（调用 GetCreditProductList API）
///
/// 支持两个筛选维度：
/// 1. 积分段（左侧侧边栏）：调用 setFilter() 同时刷新积分段与分类，只请求一次
/// 2. 商品分类（顶部 Tab）：调用 setCategoryId() 刷新
/// 两个条件叠加（AND）发送给后端。
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/providers/repository_providers.dart';
import '../../../../../core/providers/session_provider.dart';
import '../../../../../core/presentation/paging/paging_list_view.dart';
import '../../../../../core/presentation/paging/paging_controller_mixin.dart';
import '../../data/models/get_credit_product_list_model.dart';
import 'points_mall_providers.dart';

/// “我能兑换”标签：仅此标签依赖登录态，首次进入默认选中。
const kExchangeableRangeLabel = '我能兑换';

/// 解析积分段标签为 minintegral / maxintegral（不区分登录态）
///
/// - "0~1000"    → min 0，max 1000
/// - "20000以上" → min 20001，max 0
/// - 其他（如“我能兑换”）返回 null，由调用方按登录态单独处理
({int min, int max})? parseIntegralRange(String rangeLabel) {
  if (rangeLabel.contains('以上')) {
    final threshold = int.tryParse(rangeLabel.replaceAll('以上', ''));
    if (threshold == null) return null;
    return (min: threshold + 1, max: 0);
  }
  final parts = rangeLabel.split('~');
  if (parts.length == 2) {
    final min = int.tryParse(parts[0]);
    final max = int.tryParse(parts[1]);
    if (min == null || max == null) return null;
    return (min: min, max: max);
  }
  return null;
}

/// 积分商城商品分页 Notifier
class CreditProductListNotifier extends PagingNotifier<CreditProductItem> {
  String? _activeRangeLabel;
  int? _activeCategoryId;
  String? _activeKeyword;

  /// 同时切换积分段与商品分类，只刷新一次列表，避免先后两次请求产生旧参数请求
  void setFilter({required String rangeLabel, required int categoryId}) {
    _activeRangeLabel = rangeLabel;
    _activeCategoryId = categoryId;
    loadFirstPage();
  }

  /// 切换商品分类 Tab，刷新列表
  /// [categoryId] 为 0 表示全部分类
  void setCategoryId(int categoryId) {
    _activeCategoryId = categoryId;
    loadFirstPage();
  }

  /// 设置关键词并从第一页重新加载。
  void setKeyword(String keyword) {
    final normalizedKeyword = keyword.trim();
    _activeKeyword = normalizedKeyword.isEmpty ? null : normalizedKeyword;
    loadFirstPage();
  }

  @override
  int get pageSize => 15;

  @override
  Future<PagingResult<CreditProductItem>> fetchPage(int page, int pageSize) async {
    final repository = ref.read(pointsRepositoryProvider);
    final label = _activeRangeLabel ?? kExchangeableRangeLabel;
    final range = label == kExchangeableRangeLabel ? await _exchangeableRange() : parseIntegralRange(label);
    final response = await repository.getCreditProductList(
      page: page,
      pageSize: pageSize,
      minIntegral: range?.min ?? 0,
      maxIntegral: range?.max ?? 0,
      categoryId: _activeCategoryId,
      keywords: _activeKeyword,
    );
    if (!response.success || response.data == null) {
      throw Exception(response.message);
    }
    final data = response.data!;
    return PagingResult<CreditProductItem>(items: data.products, hasMore: data.hasMore, totalItems: data.total, totalPages: (data.total / pageSize).ceil());
  }

  /// “我能兑换”：min 为 0；已登录 max 为积分余额，未登录 max 为 0。
  Future<({int min, int max})> _exchangeableRange() async {
    final isLoggedIn = ref.read(sessionProvider) == SessionState.authenticated;
    if (!isLoggedIn) return (min: 0, max: 0);
    final balance = await ref.read(pointsMallProfilePointsProvider.future);
    return (min: 0, max: balance.points);
  }
}

final creditProductListProvider = NotifierProvider.autoDispose<CreditProductListNotifier, PagingData<CreditProductItem>>(CreditProductListNotifier.new);
