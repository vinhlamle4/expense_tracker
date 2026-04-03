import '../entities/category.dart';
import '../entities/category_input.dart';
import '../repositories/category_repository.dart';
import 'create_category.dart';

class UpdateCategory {
  const UpdateCategory(this._repository);

  final CategoryRepository _repository;

  Future<Category> call(int id, CategoryInput input) async {
    validateCategoryInput(input);
    return _repository.updateCategory(id, input);
  }
}
