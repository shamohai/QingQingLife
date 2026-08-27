import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'paging_controller_mixin.dart';

/// 分页数据控制器基类 (适用于 Riverpod 3.x)
abstract class PagingNotifier<T> extends Notifier<PagingData<T>> {
  /// 子类需实现：加载指定页数据
  Future<PagingResult<T>> fetchPage(int page, int pageSize);

  /// 每页大小
  int get pageSize => 20;

  @override
  PagingData<T> build() {
    return const PagingData(items: [], hasMore: true, currentPage: 1);
  }

  Future<void> loadFirstPage() async {
    if (state.status == PagingStatus.loading && state.items.isEmpty) return;

    state = state.copyWith(status: PagingStatus.loading, errorMessage: null);
    try {
      final result = await fetchPage(1, pageSize);
      state = PagingData<T>(
        status: result.items.isEmpty ? PagingStatus.empty : PagingStatus.loaded,
        items: result.items,
        hasMore: result.hasMore,
        currentPage: 1,
        totalItems: result.totalItems,
        totalPages: result.totalPages,
      );
    } catch (e) {
      state = state.copyWith(status: PagingStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.status == PagingStatus.loading || !state.hasMore) return;

    final nextPage = state.currentPage + 1;
    state = state.copyWith(status: PagingStatus.loading, errorMessage: null);

    try {
      final result = await fetchPage(nextPage, pageSize);
      final newItems = [...state.items, ...result.items];
      state = PagingData<T>(
        status: PagingStatus.loaded,
        items: newItems,
        hasMore: result.hasMore,
        currentPage: nextPage,
        totalItems: result.totalItems,
        totalPages: result.totalPages,
      );
    } catch (e) {
      state = state.copyWith(status: PagingStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> refresh() => loadFirstPage();
}

/// 通用分页列表 Widget
class PagingListView<T> extends ConsumerStatefulWidget {
  /// 分页数据 Provider
  final dynamic provider;

  /// 构建列表项
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// 分隔符
  final Widget? separatorBuilder;

  /// 初始加载 Widget
  final Widget? loadingWidget;

  /// 初始错误 Widget
  final Widget? errorWidget;

  /// 空数据 Widget
  final Widget? emptyWidget;

  /// 加载更多失败 Widget
  final Widget? loadMoreErrorWidget;

  /// 没有更多数据 Widget
  final Widget? noMoreWidget;

  /// 是否 shrinkWrap
  final bool shrinkWrap;

  /// 滚动物理效果
  final ScrollPhysics? physics;

  /// 内边距
  final EdgeInsetsGeometry? padding;

  /// 外部 ScrollController
  final ScrollController? controller;

  /// 是否启用下拉刷新
  final bool enablePullToRefresh;

  const PagingListView({
    required this.provider,
    required this.itemBuilder,
    this.separatorBuilder,
    this.loadingWidget,
    this.errorWidget,
    this.emptyWidget,
    this.loadMoreErrorWidget,
    this.noMoreWidget,
    this.shrinkWrap = false,
    this.physics,
    this.padding = const EdgeInsets.all(0),
    this.controller,
    this.enablePullToRefresh = true,
    super.key,
  });

  @override
  ConsumerState<PagingListView<T>> createState() => _PagingListViewState<T>();
}

class _PagingListViewState<T> extends ConsumerState<PagingListView<T>> {
  late ScrollController _scrollController;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _triggerFirstLoad();
    });
  }

  void _triggerFirstLoad() {
    final pagingData = ref.read(widget.provider) as PagingData<T>;
    if (pagingData.status == PagingStatus.initial || (pagingData.status == PagingStatus.empty && pagingData.items.isEmpty)) {
      _getNotifier()?.loadFirstPage();
    }
  }

  dynamic _getNotifier() {
    try {
      return ref.read(widget.provider.notifier);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_onScroll);
    }
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter < 200 && !_isLoadingMore) {
      final pagingData = ref.read(widget.provider) as PagingData<T>;
      if (pagingData.hasMore && !pagingData.isLoading && !pagingData.isError) {
        final notifier = _getNotifier();
        if (notifier != null) {
          _isLoadingMore = true;
          notifier.loadMore().whenComplete(() {
            if (mounted) _isLoadingMore = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pagingData = ref.watch(widget.provider) as PagingData<T>;

    // 初始加载状态
    if (pagingData.status == PagingStatus.loading && pagingData.items.isEmpty) {
      return widget.loadingWidget ?? const Center(child: CircularProgressIndicator());
    }

    // 初始错误状态
    if (pagingData.status == PagingStatus.error && pagingData.items.isEmpty) {
      return widget.errorWidget ??
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(pagingData.errorMessage ?? '加载失败'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _getNotifier()?.refresh(),
                  child: const Text('重试'),
                ),
              ],
            ),
          );
    }

    // 空状态
    if (pagingData.status == PagingStatus.empty || (pagingData.status == PagingStatus.loaded && pagingData.items.isEmpty)) {
      return widget.emptyWidget ?? const Center(child: Text('暂无数据'));
    }

    Widget listView = ListView.separated(
      controller: _scrollController,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      padding: widget.padding,
      itemCount: pagingData.items.length + (pagingData.hasMore ? 1 : (pagingData.items.isNotEmpty ? 1 : 0)),
      separatorBuilder: (context, index) => widget.separatorBuilder ?? const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (index == pagingData.items.length) {
          return _buildFooter(pagingData);
        }
        return widget.itemBuilder(context, pagingData.items[index], index);
      },
    );

    if (widget.enablePullToRefresh) {
      return RefreshIndicator(
        onRefresh: () async => await _getNotifier()?.refresh(),
        child: listView,
      );
    }

    return listView;
  }

  Widget _buildFooter(PagingData<T> pagingData) {
    if (pagingData.status == PagingStatus.loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (pagingData.status == PagingStatus.error) {
      return widget.loadMoreErrorWidget ??
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: InkWell(
                onTap: () => _getNotifier()?.loadMore(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(pagingData.errorMessage ?? '加载更多失败，点击重试', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 4),
                    const Icon(Icons.refresh, color: Colors.grey, size: 20),
                  ],
                ),
              ),
            ),
          );
    }

    if (!pagingData.hasMore && pagingData.items.isNotEmpty) {
      return widget.noMoreWidget ??
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text('没有更多数据了', style: TextStyle(fontSize: 14, color: Colors.grey)),
            ),
          );
    }

    return const SizedBox.shrink();
  }
}
