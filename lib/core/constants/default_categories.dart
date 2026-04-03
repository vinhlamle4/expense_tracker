/// Seed data for the 8 built-in categories.
/// These rows are inserted on first launch and must never be deleted (is_system = 1).
const List<Map<String, Object>> defaultCategories = [
  {'name': 'Food', 'icon': 'restaurant', 'colour': '#FF7043', 'is_system': 1},
  {'name': 'Transport', 'icon': 'directions_car', 'colour': '#42A5F5', 'is_system': 1},
  {'name': 'Shopping', 'icon': 'shopping_bag', 'colour': '#AB47BC', 'is_system': 1},
  {'name': 'Health', 'icon': 'local_hospital', 'colour': '#26A69A', 'is_system': 1},
  {'name': 'Entertainment', 'icon': 'movie', 'colour': '#FFA726', 'is_system': 1},
  {'name': 'Bills', 'icon': 'receipt_long', 'colour': '#78909C', 'is_system': 1},
  {'name': 'Income', 'icon': 'payments', 'colour': '#66BB6A', 'is_system': 1},
  {'name': 'Uncategorized', 'icon': 'help_outline', 'colour': '#BDBDBD', 'is_system': 1},
];
