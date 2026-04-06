import 'package:isar/isar.dart';

part 'transaction_model.g.dart';

@collection
class TransactionModel {
  Id id = Isar.autoIncrement;

  late double amount;

  @Index()
  late DateTime date;

  @Index()
  late String categoryId;

  String note = '';

  @Index()
  late bool isIncome;
}

