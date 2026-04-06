import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/models/category_model.dart';
import 'database_provider.dart';

export 'database_provider.dart' show categoryRepoProvider;

/// Live stream of all categories.
final categoryListProvider = StreamProvider<List<CategoryModel>>((ref) {
  final repo = ref.watch(categoryRepoProvider);
  return repo.watchAll();
});
