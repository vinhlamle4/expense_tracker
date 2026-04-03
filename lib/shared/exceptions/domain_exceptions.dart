/// Transaction not found for the given id.
class TransactionNotFoundException implements Exception {
  const TransactionNotFoundException(this.id);
  final int id;

  @override
  String toString() => 'TransactionNotFoundException: No transaction with id $id';
}

/// Category not found for the given id.
class CategoryNotFoundException implements Exception {
  const CategoryNotFoundException(this.id);
  final int id;

  @override
  String toString() => 'CategoryNotFoundException: No category with id $id';
}

/// Operation not allowed on a system (built-in) category.
class SystemCategoryException implements Exception {
  const SystemCategoryException([this.message = 'Built-in categories cannot be modified or deleted']);
  final String message;

  @override
  String toString() => 'SystemCategoryException: $message';
}

/// Category name violates uniqueness constraint.
class CategoryNameExistsException implements Exception {
  const CategoryNameExistsException(this.name);
  final String name;

  @override
  String toString() => 'CategoryNameExistsException: "$name" already exists';
}

/// CSV export requested but no transactions match the criteria.
class EmptyExportException implements Exception {
  const EmptyExportException();

  @override
  String toString() => 'EmptyExportException: Nothing to export';
}

/// Domain-level field validation failure.
class ValidationException implements Exception {
  const ValidationException(this.field, this.message);
  final String field;
  final String message;

  @override
  String toString() => 'ValidationException[$field]: $message';
}
