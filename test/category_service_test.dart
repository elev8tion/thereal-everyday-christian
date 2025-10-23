import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:everyday_christian/core/services/database_service.dart';
import 'package:everyday_christian/core/services/category_service.dart';
import 'package:everyday_christian/core/models/prayer_category.dart';
import 'package:flutter/material.dart';

void main() {
  late DatabaseService databaseService;
  late CategoryService categoryService;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    DatabaseService.setTestDatabasePath(inMemoryDatabasePath);
    databaseService = DatabaseService();
    await databaseService.initialize();
    categoryService = CategoryService(databaseService);
  });

  tearDown(() async {
    await databaseService.close();
    DatabaseService.setTestDatabasePath(null);
  });

  group('CategoryService Tests', () {
    test('should get all active categories', () async {
      final categories = await categoryService.getActiveCategories();

      expect(categories, isNotEmpty);
      expect(categories.every((c) => c.isActive), isTrue);
    });

    test('should get default categories', () async {
      final categories = await categoryService.getAllCategories();

      expect(categories, isNotEmpty);
      expect(categories.where((c) => c.isDefault).length, greaterThan(0));

      // Verify default categories exist
      final defaultCategoryNames = categories.where((c) => c.isDefault).map((c) => c.name).toList();
      expect(defaultCategoryNames, contains('Family'));
      expect(defaultCategoryNames, contains('Health'));
      expect(defaultCategoryNames, contains('Work'));
    });

    test('should create custom category', () async {
      const categoryName = 'Test Category';
      final iconCodePoint = Icons.star.codePoint;
      final colorValue = Colors.purple.toARGB32();

      final category = await categoryService.createCategory(
        name: categoryName,
        iconCodePoint: iconCodePoint,
        colorValue: colorValue,
      );

      expect(category.name, equals(categoryName));
      expect(category.iconCodePoint, equals(iconCodePoint));
      expect(category.colorValue, equals(colorValue));
      expect(category.isDefault, isFalse);
      expect(category.isActive, isTrue);
    });

    test('should not create duplicate category', () async {
      const categoryName = 'Duplicate Test';
      final iconCodePoint = Icons.star.codePoint;
      final colorValue = Colors.purple.toARGB32();

      // Create first category
      await categoryService.createCategory(
        name: categoryName,
        iconCodePoint: iconCodePoint,
        colorValue: colorValue,
      );

      // Try to create duplicate
      expect(
        () => categoryService.createCategory(
          name: categoryName,
          iconCodePoint: iconCodePoint,
          colorValue: colorValue,
        ),
        throwsException,
      );
    });

    test('should get category by ID', () async {
      final categories = await categoryService.getAllCategories();
      final firstCategory = categories.first;

      final foundCategory = await categoryService.getCategoryById(firstCategory.id);

      expect(foundCategory, isNotNull);
      expect(foundCategory!.id, equals(firstCategory.id));
      expect(foundCategory.name, equals(firstCategory.name));
    });

    test('should get category by name', () async {
      final category = await categoryService.getCategoryByName('Family');

      expect(category, isNotNull);
      expect(category!.name, equals('Family'));
    });

    test('should update category', () async {
      // Create a custom category
      const categoryName = 'Update Test';
      final category = await categoryService.createCategory(
        name: categoryName,
        iconCodePoint: Icons.star.codePoint,
        colorValue: Colors.blue.toARGB32(),
      );

      // Update the category
      final updatedCategory = category.copyWith(
        name: 'Updated Category',
        iconCodePoint: Icons.favorite.codePoint,
        colorValue: Colors.red.toARGB32(),
      );

      await categoryService.updateCategory(updatedCategory);

      // Verify update
      final retrieved = await categoryService.getCategoryById(category.id);
      expect(retrieved!.name, equals('Updated Category'));
      expect(retrieved.iconCodePoint, equals(Icons.favorite.codePoint));
      expect(retrieved.colorValue, equals(Colors.red.toARGB32()));
    });

    test('should delete custom category', () async {
      // Create a custom category
      final category = await categoryService.createCategory(
        name: 'Delete Test',
        iconCodePoint: Icons.star.codePoint,
        colorValue: Colors.blue.toARGB32(),
      );

      // Delete the category
      await categoryService.deleteCategory(category.id);

      // Verify deletion
      final retrieved = await categoryService.getCategoryById(category.id);
      expect(retrieved, isNull);
    });

    test('should not delete default category', () async {
      final categories = await categoryService.getAllCategories();
      final defaultCategory = categories.firstWhere((c) => c.isDefault);

      expect(
        () => categoryService.deleteCategory(defaultCategory.id),
        throwsException,
      );
    });

    test('should toggle category active status', () async {
      // Create a custom category
      final category = await categoryService.createCategory(
        name: 'Toggle Test',
        iconCodePoint: Icons.star.codePoint,
        colorValue: Colors.blue.toARGB32(),
      );

      expect(category.isActive, isTrue);

      // Toggle to inactive
      await categoryService.toggleCategoryActive(category.id);

      final toggledCategory = await categoryService.getCategoryById(category.id);
      expect(toggledCategory!.isActive, isFalse);

      // Toggle back to active
      await categoryService.toggleCategoryActive(category.id);

      final reToggledCategory = await categoryService.getCategoryById(category.id);
      expect(reToggledCategory!.isActive, isTrue);
    });

    test('should reorder categories', () async {
      final categories = await categoryService.getAllCategories();
      final categoryIds = categories.map((c) => c.id).toList();

      // Reverse the order
      final reversedIds = categoryIds.reversed.toList();

      await categoryService.reorderCategories(reversedIds);

      // Verify new order
      final reorderedCategories = await categoryService.getAllCategories();
      for (var i = 0; i < reversedIds.length; i++) {
        expect(reorderedCategories[i].id, equals(reversedIds[i]));
      }
    });

    test('should get custom category count', () async {
      final initialCount = await categoryService.getCustomCategoryCount();

      // Create a custom category
      await categoryService.createCategory(
        name: 'Count Test',
        iconCodePoint: Icons.star.codePoint,
        colorValue: Colors.blue.toARGB32(),
      );

      final newCount = await categoryService.getCustomCategoryCount();
      expect(newCount, equals(initialCount + 1));
    });

    test('should check category name availability', () async {
      const availableName = 'Unique Category Name';
      const unavailableName = 'Family';

      final isAvailable = await categoryService.isCategoryNameAvailable(availableName);
      final isUnavailable = await categoryService.isCategoryNameAvailable(unavailableName);

      expect(isAvailable, isTrue);
      expect(isUnavailable, isFalse);
    });

    test('should reset to default categories', () async {
      // Create some custom categories
      await categoryService.createCategory(
        name: 'Custom 1',
        iconCodePoint: Icons.star.codePoint,
        colorValue: Colors.blue.toARGB32(),
      );
      await categoryService.createCategory(
        name: 'Custom 2',
        iconCodePoint: Icons.favorite.codePoint,
        colorValue: Colors.red.toARGB32(),
      );

      final customCount = await categoryService.getCustomCategoryCount();
      expect(customCount, greaterThan(0));

      // Reset to defaults
      await categoryService.resetToDefaults();

      final newCustomCount = await categoryService.getCustomCategoryCount();
      expect(newCustomCount, equals(0));
    });

    test('should get category statistics', () async {
      final categories = await categoryService.getAllCategories();
      final category = categories.first;

      final stats = await categoryService.getCategoryStatistics(category.id);

      expect(stats.categoryId, equals(category.id));
      expect(stats.categoryName, equals(category.name));
      expect(stats.totalPrayers, greaterThanOrEqualTo(0));
      expect(stats.activePrayers, greaterThanOrEqualTo(0));
      expect(stats.answeredPrayers, greaterThanOrEqualTo(0));
    });

    test('should get all category statistics', () async {
      final allStats = await categoryService.getAllCategoryStatistics();

      expect(allStats, isNotEmpty);
      expect(allStats.every((s) => s.totalPrayers >= 0), isTrue);
      expect(allStats.every((s) => s.answerRate >= 0 && s.answerRate <= 100), isTrue);
    });
  });

  group('PrayerCategory Model Tests', () {
    test('should create category from map', () async {
      final map = {
        'id': 'test_id',
        'name': 'Test Category',
        'icon': Icons.star.codePoint.toString(),
        'color': '0x${Colors.blue.toARGB32().toRadixString(16).toUpperCase()}',
        'is_default': 0,
        'is_active': 1,
        'display_order': 5,
        'date_created': DateTime.now().millisecondsSinceEpoch,
        'date_modified': null,
      };

      final category = PrayerCategoryExtension.fromMap(map);

      expect(category.id, equals('test_id'));
      expect(category.name, equals('Test Category'));
      expect(category.iconCodePoint, equals(Icons.star.codePoint));
      expect(category.colorValue, equals(Colors.blue.toARGB32()));
      expect(category.isDefault, isFalse);
      expect(category.isActive, isTrue);
      expect(category.displayOrder, equals(5));
    });

    test('should convert category to map', () async {
      final category = PrayerCategory(
        id: 'test_id',
        name: 'Test Category',
        iconCodePoint: Icons.star.codePoint,
        colorValue: Colors.blue.toARGB32(),
        isDefault: false,
        isActive: true,
        displayOrder: 5,
        dateCreated: DateTime.now(),
      );

      final map = category.toMap();

      expect(map['id'], equals('test_id'));
      expect(map['name'], equals('Test Category'));
      expect(map['icon'], equals(Icons.star.codePoint.toString()));
      expect(map['is_default'], equals(0));
      expect(map['is_active'], equals(1));
      expect(map['display_order'], equals(5));
    });

    test('should get icon as IconData', () async {
      final category = PrayerCategory(
        id: 'test_id',
        name: 'Test',
        iconCodePoint: Icons.star.codePoint,
        colorValue: Colors.blue.toARGB32(),
        dateCreated: DateTime.now(),
      );

      final icon = category.icon;

      expect(icon.codePoint, equals(Icons.star.codePoint));
    });

    test('should get color as Color object', () async {
      final category = PrayerCategory(
        id: 'test_id',
        name: 'Test',
        iconCodePoint: Icons.star.codePoint,
        colorValue: Colors.blue.toARGB32(),
        dateCreated: DateTime.now(),
      );

      final color = category.color;

      expect(color.toARGB32(), equals(Colors.blue.toARGB32()));
    });
  });

  group('CategoryStatistics Tests', () {
    test('should create statistics from category', () async {
      final category = PrayerCategory(
        id: 'test_id',
        name: 'Test Category',
        iconCodePoint: Icons.star.codePoint,
        colorValue: Colors.blue.toARGB32(),
        dateCreated: DateTime.now(),
      );

      final stats = CategoryStatistics.fromCategory(
        category,
        total: 10,
        active: 6,
        answered: 4,
        archived: 0,
      );

      expect(stats.categoryId, equals('test_id'));
      expect(stats.categoryName, equals('Test Category'));
      expect(stats.totalPrayers, equals(10));
      expect(stats.activePrayers, equals(6));
      expect(stats.answeredPrayers, equals(4));
      expect(stats.answerRate, equals(40.0));
    });

    test('should handle zero total prayers', () async {
      final category = PrayerCategory(
        id: 'test_id',
        name: 'Test Category',
        iconCodePoint: Icons.star.codePoint,
        colorValue: Colors.blue.toARGB32(),
        dateCreated: DateTime.now(),
      );

      final stats = CategoryStatistics.fromCategory(
        category,
        total: 0,
        active: 0,
        answered: 0,
        archived: 0,
      );

      expect(stats.answerRate, equals(0.0));
    });
  });
}
