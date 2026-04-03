class CategoryBreakdown {
  const CategoryBreakdown({
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColour,
    required this.total,
    required this.percentage,
  });

  final int categoryId;
  final String categoryName;
  final String categoryIcon;
  final String categoryColour;

  /// Total in minor currency units.
  final int total;

  /// Percentage of total expenses (0–100).
  final double percentage;
}
