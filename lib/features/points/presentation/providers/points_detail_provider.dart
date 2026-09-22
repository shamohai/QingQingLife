import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../domain/repositories/points_repository.dart';
import '../../../points_mall/presentation/providers/points_mall_paging_providers.dart';

/// 积分明细 Provider
///
/// 管理积分记录列表、当前积分余额、月份筛选状态。
class PointsDetailState {
  final int currentPoints;
  final List<PointsExchangeRecord> records;
  final String selectedMonth; // format: 'yyyy-MM'
  final bool isLoading;
  final String? errorMessage;

  const PointsDetailState({
    this.currentPoints = 0,
    this.records = const [],
    this.selectedMonth = '',
    this.isLoading = false,
    this.errorMessage,
  });

  PointsDetailState copyWith({
    int? currentPoints,
    List<PointsExchangeRecord>? records,
    String? selectedMonth,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PointsDetailState(
      currentPoints: currentPoints ?? this.currentPoints,
      records: records ?? this.records,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// 按 selectedMonth 过滤后的记录列表
  List<PointsExchangeRecord> get filteredRecords {
    if (selectedMonth.isEmpty) return records;
    return records.where((record) {
      final monthKey = '${record.createTime.year}-${record.createTime.month.toString().padLeft(2, '0')}';
      return monthKey == selectedMonth;
    }).toList();
  }

  /// 所有可用月份列表（从最新到最旧）
  List<String> get availableMonths {
    final months = <String>{};
    for (final record in records) {
      final key = '${record.createTime.year}-${record.createTime.month.toString().padLeft(2, '0')}';
      months.add(key);
    }
    return months.toList()..sort((a, b) => b.compareTo(a));
  }

  /// 格式化月份显示文本
  static String formatMonthDisplay(String monthKey) {
    final parts = monthKey.split('-');
    if (parts.length != 2) return monthKey;
    return '${parts[0]}年${int.parse(parts[1])}月';
  }

  /// 获取选中月份的收益总额
  double getMonthlyIncome(String month) {
    final filtered = records.where((r) {
      final k = '${r.createTime.year}-${r.createTime.month.toString().padLeft(2, '0')}';
      return k == month && r.pointsDeducted > 0;
    }).toList();
    return filtered.fold(0.0, (s, r) => s + r.pointsDeducted);
  }

  /// 获取选中月份的支出总额
  double getMonthlyExpense(String month) {
    final filtered = records.where((r) {
      final k = '${r.createTime.year}-${r.createTime.month.toString().padLeft(2, '0')}';
      return k == month && r.pointsDeducted < 0;
    }).toList();
    return filtered.fold(0.0, (s, r) => s + r.pointsDeducted.abs());
  }
}

class PointsDetailNotifier extends Notifier<PointsDetailState> {
  @override
  PointsDetailState build() {
    final staticData = ref.watch(pointsMallStaticDataProvider);
    int initialPoints = 0;
    if (staticData.hasValue) {
      initialPoints = staticData.value!.currentPoints;
    }
    return PointsDetailState(currentPoints: initialPoints, selectedMonth: _getLatestMonth());
  }

  Future<void> loadRecords() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repository = ref.read(pointsRepositoryProvider);
      final response = await repository.getExchangeRecords(page: 1, pageSize: 50);
      if (!response.success || response.data == null) {
        state = state.copyWith(isLoading: false, errorMessage: '加载失败');
        return;
      }
      final records = response.data!;
      final latestMonth = _getLatestMonthFromRecords(records);
      state = state.copyWith(
        records: records,
        isLoading: false,
        selectedMonth: latestMonth,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void selectMonth(String month) {
    state = state.copyWith(selectedMonth: month);
  }

  Future<void> refresh() async {
    await loadRecords();
  }

  String _getLatestMonth() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  String _getLatestMonthFromRecords(List<PointsExchangeRecord> records) {
    if (records.isEmpty) return _getLatestMonth();
    final sorted = records
        .map((r) => '${r.createTime.year}-${r.createTime.month.toString().padLeft(2, '0')}')
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));
    return sorted.isNotEmpty ? sorted.first : _getLatestMonth();
  }
}

final pointsDetailProvider = NotifierProvider.autoDispose<PointsDetailNotifier, PointsDetailState>(
  PointsDetailNotifier.new,
);
