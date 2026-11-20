import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../data/models/points_credit_detail_models.dart';

/// 积分明细页面状态：流水按月份分组，余额直接取积分流水接口的 totalcredit。
class PointsDetailState {
  final int currentPoints;
  final List<PointsCreditRecord> records;
  final String selectedMonth;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? errorMessage;

  const PointsDetailState({
    this.currentPoints = 0,
    this.records = const [],
    this.selectedMonth = '',
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.errorMessage,
  });

  PointsDetailState copyWith({
    int? currentPoints,
    List<PointsCreditRecord>? records,
    String? selectedMonth,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? errorMessage,
    bool clearError = false,
  }) => PointsDetailState(
    currentPoints: currentPoints ?? this.currentPoints,
    records: records ?? this.records,
    selectedMonth: selectedMonth ?? this.selectedMonth,
    isLoading: isLoading ?? this.isLoading,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    hasMore: hasMore ?? this.hasMore,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );

  List<String> get availableMonths {
    final months = records.map(_monthKey).toSet().toList()..sort((a, b) => b.compareTo(a));
    return months;
  }

  List<PointsCreditRecord> getRecordsForMonth(String month) => records.where((record) => _monthKey(record) == month).toList(growable: false);

  static String formatMonthDisplay(String monthKey) {
    final parts = monthKey.split('-');
    return parts.length == 2 ? '${parts[0]}年${int.parse(parts[1])}月' : monthKey;
  }

  static String _monthKey(PointsCreditRecord record) {
    final parsed = DateTime.tryParse(record.actionTimeText);
    if (parsed == null) return '';
    return '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}';
  }
}

class PointsDetailNotifier extends Notifier<PointsDetailState> {
  static const _pageSize = 80;
  int _page = 1;

  @override
  PointsDetailState build() => const PointsDetailState();

  Future<void> loadRecords() => refresh();

  Future<void> refresh() async {
    _page = 1;
    state = state.copyWith(isLoading: true, isLoadingMore: false, hasMore: true, records: const [], clearError: true);
    await _fetch(reset: true);
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true, clearError: true);
    await _fetch(reset: false);
  }

  void selectMonth(String month) => state = state.copyWith(selectedMonth: month);

  Future<void> _fetch({required bool reset}) async {
    try {
      final response = await ref.read(pointsRepositoryProvider).getCreditList(page: _page, pageSize: _pageSize);
      if (!response.success || response.data == null) {
        state = state.copyWith(isLoading: false, isLoadingMore: false, errorMessage: response.message);
        return;
      }
      final data = response.data!;
      final records = reset ? data.credits : [...state.records, ...data.credits];
      final latestMonth = records.isEmpty ? '' : _latestMonth(records);
      state = state.copyWith(
        currentPoints: data.totalCredit,
        records: records,
        selectedMonth: state.selectedMonth.isEmpty ? latestMonth : state.selectedMonth,
        isLoading: false,
        isLoadingMore: false,
        hasMore: records.length < data.totalRecords,
        clearError: true,
      );
      if (data.credits.isNotEmpty) _page++;
    } catch (error) {
      state = state.copyWith(isLoading: false, isLoadingMore: false, errorMessage: error.toString());
    }
  }

  String _latestMonth(List<PointsCreditRecord> records) {
    return records.map(_monthKey).reduce((a, b) => a.compareTo(b) >= 0 ? a : b);
  }

  String _monthKey(PointsCreditRecord record) {
    final parsed = DateTime.tryParse(record.actionTimeText);
    if (parsed == null) return '';
    return '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}';
  }
}

final pointsDetailProvider = NotifierProvider.autoDispose<PointsDetailNotifier, PointsDetailState>(PointsDetailNotifier.new);
