import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/data/models/category_model.dart';

void main() {
  group('CategoryModel', () {
    // ── Happy paths ─────────────────────────────────────────────────────────

    test('creates category with required fields', () {
      final c = CategoryModel()
        ..id = 'food'
        ..name = 'Food & Drink'
        ..icon = 'e56c'
        ..colorValue = Colors.orange.toARGB32()
        ..isDefault = false;

      expect(c.id, 'food');
      expect(c.name, 'Food & Drink');
      expect(c.icon, 'e56c');
      expect(c.isDefault, false);
    });

    test('isDefault flag is false by default', () {
      final c = CategoryModel()
        ..id = 'custom'
        ..name = 'Custom'
        ..icon = 'e8b8'
        ..colorValue = 0xFF9E9E9E;

      expect(c.isDefault, false);
    });

    test('marks system category as default', () {
      final c = CategoryModel()
        ..id = 'uncategorized'
        ..name = 'Uncategorized'
        ..icon = 'e8ef'
        ..colorValue = Colors.grey.toARGB32()
        ..isDefault = true;

      expect(c.isDefault, true);
    });

    // ── fastHash ─────────────────────────────────────────────────────────────

    test('fastHash produces same result for same input', () {
      expect(fastHash('food'), fastHash('food'));
      expect(fastHash('transport'), fastHash('transport'));
    });

    test('fastHash produces different results for different inputs', () {
      expect(fastHash('food'), isNot(fastHash('transport')));
      expect(fastHash('food'), isNot(fastHash('Food')));
    });

    test('fastHash for empty string does not throw', () {
      expect(() => fastHash(''), returnsNormally);
    });

    test('isarId equals fastHash(id)', () {
      final c = CategoryModel()
        ..id = 'transport'
        ..name = 'Transport'
        ..icon = 'e531'
        ..colorValue = Colors.blue.toARGB32();

      expect(c.isarId, fastHash('transport'));
    });

    // ── CategoryModelFactory ──────────────────────────────────────────────────

    test('CategoryModelFactory.custom creates non-default category', () {
      final c = CategoryModelFactory.custom(
        id: 'my_cat',
        name: 'My Category',
      );

      expect(c.id, 'my_cat');
      expect(c.name, 'My Category');
      expect(c.isDefault, false);
    });

    test('CategoryModelFactory.custom uses default icon and color when omitted', () {
      final c = CategoryModelFactory.custom(id: 'x', name: 'X');

      expect(c.icon, 'e8b8');        // Icons.label
      expect(c.colorValue, 0xFF9E9E9E); // Colors.grey
    });

    test('CategoryModelFactory.custom respects custom icon and color', () {
      final c = CategoryModelFactory.custom(
        id: 'custom',
        name: 'Custom',
        icon: 'e56c',
        colorValue: Colors.red.toARGB32(),
      );

      expect(c.icon, 'e56c');
      expect(c.colorValue, Colors.red.toARGB32());
    });

    // ── Edge cases ────────────────────────────────────────────────────────────

    test('supports unicode characters in name', () {
      final c = CategoryModel()
        ..id = 'food_vn'
        ..name = 'Ăn uống'
        ..icon = 'e56c'
        ..colorValue = Colors.orange.toARGB32();

      expect(c.name, 'Ăn uống');
    });
  });
}

