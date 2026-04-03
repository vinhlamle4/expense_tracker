import '../entities/category.dart';
import '../entities/category_input.dart';

abstract interface class CategoryRepository {
  Future<List<Category>> getCategories();

  Future<Category> getCategoryById(int id);

  Future<Category> createCategory(CategoryInput input);

  Future<Category> updateCategory(int id, CategoryInput input);

  Future<void> deleteCategory(int id);
}
