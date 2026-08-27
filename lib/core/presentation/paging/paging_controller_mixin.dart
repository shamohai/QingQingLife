import 'package:flutter/material.dart';

/// 分页状态枚举
enum PagingStatus { initial, loading, loaded, error, empty }

/// 分页数据模型
class PagingData<T> {
  final PagingStatus status;
  final List<T> items;
  final bool hasMore;
  final int currentPage;
  final int totalItems;
  final int totalPages;
  final String? errorMessage;

  const PagingData({
    this.status = PagingStatus.initial,
    required this.items,
    this.hasMore = false,
    this.currentPage = 1,
    this.totalItems = 0,
    this.totalPages = 1,
    this.errorMessage,
  });

  bool get isLoading => status == PagingStatus.loading;
  bool get isLoaded => status == PagingStatus.loaded;
  bool get isError => status == PagingStatus.error;
  bool get isEmpty => status == PagingStatus.empty;

  PagingData<T> copyWith({
    PagingStatus? status,
    List<T>? items,
    bool? hasMore,
    int? currentPage,
    int? totalItems,
    int? totalPages,
    String? errorMessage,
  }) {
    return PagingData<T>(
      status: status ?? this.status,
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      totalItems: totalItems ?? this.totalItems,
      totalPages: totalPages ?? this.totalPages,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// 分页结果封装
class PagingResult<T> {
  final List<T> items;
  final bool hasMore;
  final int totalItems;
  final int totalPages;

  const PagingResult({required this.items, required this.hasMore, required this.totalItems, required this.totalPages});
}

/// 分页控制器 Mixin - 用于 StatefulWidget 页面（非 Riverpod 场景）
mixin PagingControllerMixin<T> on State<StatefulWidget> {
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  final List<T> _items = [];
  String? _errorMessage;
  PagingStatus _pagingStatus = PagingStatus.initial;

  List<T> get pagingItems => _items;
  bool get pagingHasMore => _hasMore;
  bool get pagingIsLoading => _pagingStatus == PagingStatus.loading;
  PagingStatus get pagingStatus => _pagingStatus;
  String? get pagingErrorMessage => _errorMessage;

  /// 子类实现：加载指定页数据
  Future<PagingResult<T>> fetchPage(int page, int pageSize);

  Future<void> loadFirstPage({int pageSize = 20}) async {
    if (!mounted) return;
    setState(() {
      _pagingStatus = PagingStatus.loading;
      _items.clear();
      _currentPage = 1;
      _hasMore = true;
      _errorMessage = null;
    });
    try {
      final result = await fetchPage(1, pageSize);
      if (!mounted) return;
      setState(() {
        _items.addAll(result.items);
        _hasMore = result.hasMore;
        _currentPage = 1;
        _pagingStatus = result.items.isEmpty ? PagingStatus.empty : PagingStatus.loaded;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _pagingStatus = PagingStatus.error;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> loadMorePage({int pageSize = 20}) async {
    if (_isLoadingMore || !_hasMore || _pagingStatus == PagingStatus.loading) return;
    _isLoadingMore = true;
    final nextPage = _currentPage + 1;
    try {
      final result = await fetchPage(nextPage, pageSize);
      if (!mounted) return;
      setState(() {
        _items.addAll(result.items);
        _hasMore = result.hasMore;
        _currentPage = nextPage;
        _pagingStatus = PagingStatus.loaded;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      _isLoadingMore = false;
    }
  }

  Widget buildPagingFooter(BuildContext context) {
    if (!_hasMore) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: Text('已加载全部', style: TextStyle(color: Colors.grey, fontSize: 12))),
      );
    }
    if (_isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return const SizedBox.shrink();
  }
}
