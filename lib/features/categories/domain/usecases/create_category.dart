import '../../../../shared/exceptions/domain_exceptions.dart';
import '../entities/category.dart';
import '../entities/category_input.dart';
import '../repositories/category_repository.dart';

void validateCategoryInput(CategoryInput input) {
  if (input.name.trim().isEmpty) {
    throw const ValidationException('name', 'Category name is required');
  }
  if (input.name.trim().length > 50) {
    throw const ValidationException(
        'name', 'Category name cannot exceed 50 characters');
  }
  if (input.icon.isEmpty) {
    throw const ValidationException('icon', 'Icon is required');
  }
  if (input.colour.isEmpty) {
    throw const ValidationException('colour', 'Colour is required');
  }
}

class CreateCategory {
  const CreateCategory(this._repository);

  final CategoryRepository _repository;

  Future<Category> call(CategoryInput input) async {
    validateCategoryInput(input);
    return _repository.createCategory(input);
  }
}
