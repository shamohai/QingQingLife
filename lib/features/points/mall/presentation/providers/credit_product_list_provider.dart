/// 积分商城商品分页 Provider（调用 GetCreditProductList API）
///
/// 支持两个筛选维度：
/// 1. 积分段（左侧侧边栏）：调用 setIntegralRange() 刷新
/// 2. 商品分类（顶部 Tab）：调用 setCategoryId() 刷新
/// 两个条件叠加（AND）发送给后端。
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/providers/repository_providers.dart';
import '../../../../../core/presentation/paging/paging_list_view.dart';
import '../../../../../core/presentation/paging/paging_controller_mixin.dart';
import '../../data/models/get_credit_product_list_model.dart';

/// 解析积分段标签为 API 参数
///
/// - "我能兑换" → (0, 0, true)
/// - "0~1000"   → (0, 1000, null)
/// - "20000以上" → (20000, 0, null)
(int? min, int? max, bool? exchangeable) parseIntegralRange(String rangeLabel) {
  if (rangeLabel == '我能兑换') return (0, 0, true);
  if (rangeLabel.contains('以上')) {
    final min = int.tryParse(rangeLabel.replaceAll('以上', ''));
    return (min, 0, null);
  }
  final parts = rangeLabel.split('~');
  if (parts.length == 2) {
    final min = int.tryParse(parts[0]);
    final max = int.tryParse(parts[1]);
    return (min, max, null);
  }
  return (null, null, null);
}

/// 积分商城商品分页 Notifier
class CreditProductListNotifier extends PagingNotifier<CreditProductItem> {
  String? _activeRangeLabel;
  int? _activeCategoryId;
  String? _activeKeyword;

  /// 切换积分段，刷新列表
  void setIntegralRange(String rangeLabel) {
    _activeRangeLabel = rangeLabel;
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
    final (min, max, exchangeable) = parseIntegralRange(_activeRangeLabel ?? '我能兑换');
    final response = await repository.getCreditProductList(
      page: page,
      pageSize: pageSize,
      minIntegral: min,
      maxIntegral: max,
      exchangeable: exchangeable,
      categoryId: _activeCategoryId,
      keywords: _activeKeyword,
    );
    if (!response.success || response.data == null) {
      throw Exception(response.message);
    }
    final data = response.data!;
    return PagingResult<CreditProductItem>(items: data.products, hasMore: data.hasMore, totalItems: data.total, totalPages: (data.total / pageSize).ceil());
  }
}

final creditProductListProvider = NotifierProvider.autoDispose<CreditProductListNotifier, PagingData<CreditProductItem>>(CreditProductListNotifier.new);
