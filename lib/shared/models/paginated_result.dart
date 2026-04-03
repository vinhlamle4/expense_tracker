/// Generic paginated result returned by repository list operations.
class PaginatedResult<T> {
  const PaginatedResult({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
  });

  final List<T> items;
  final int totalCount;

  /// 1-indexed current page number.
  final int page;
  final int pageSize;

  int get totalPages => pageSize == 0 ? 0 : (totalCount / pageSize).ceil();
  bool get hasMore => page < totalPages;

  bool get isEmpty => items.isEmpty;
}
