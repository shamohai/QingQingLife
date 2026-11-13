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

  PagingData<T> copyWith({PagingStatus? status, List<T>? items, bool? hasMore, int? currentPage, int? totalItems, int? totalPages, String? errorMessage}) {
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
