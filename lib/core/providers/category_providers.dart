import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/categories/data/repositories/category_repository_impl.dart';
import '../../features/categories/domain/entities/category.dart';
import '../../features/categories/domain/repositories/category_repository.dart';
import '../../features/categories/domain/usecases/create_category.dart';
import '../../features/categories/domain/usecases/delete_category.dart';
import '../../features/categories/domain/usecases/get_categories.dart';
import '../../features/categories/domain/usecases/update_category.dart';
import 'transaction_providers.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(ref.read(databaseHelperProvider));
});

final getCategoriesProvider = Provider<GetCategories>((ref) {
  return GetCategories(ref.read(categoryRepositoryProvider));
});

final createCategoryProvider = Provider<CreateCategory>((ref) {
  return CreateCategory(ref.read(categoryRepositoryProvider));
});

final updateCategoryProvider = Provider<UpdateCategory>((ref) {
  return UpdateCategory(ref.read(categoryRepositoryProvider));
});

final deleteCategoryProvider = Provider<DeleteCategory>((ref) {
  return DeleteCategory(ref.read(categoryRepositoryProvider));
});

/// Watched list of all categories — used in dropdowns and category screens.
final categoryListProvider = FutureProvider<List<Category>>((ref) {
  return ref.read(getCategoriesProvider).call();
});
