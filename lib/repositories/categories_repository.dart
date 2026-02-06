import 'package:hive/hive.dart';
import '../models/hive_category.dart';
import '../models/category.dart';

class CategoriesRepository {
  static const String _boxName = 'categoriesBox';
  static const String _lastSyncKey = 'categories_last_sync';

  /// Get the categories box
  Box<HiveCategory> get _box => Hive.box<HiveCategory>(_boxName);

  /// Get metadata box for sync timestamps
  Box get _metadataBox => Hive.box('metadataBox');

  /// Get all categories from local cache
  Future<List<HiveCategory>> getAllCategoriesFromCache() async {
    try {
      return _box.values.toList();
    } catch (e) {
      print('Erreur lors de la lecture des catégories du cache: $e');
      return [];
    }
  }

  /// Save categories to local cache (Hive only)
  Future<void> saveCategories(List<Category> categories) async {
    try {
      await _box.clear();
      final hiveCategories = categories
          .map((category) => HiveCategory.fromCategory(category))
          .toList();

      for (int i = 0; i < hiveCategories.length; i++) {
        await _box.put(hiveCategories[i].id, hiveCategories[i]);
      }

      // Update last sync time
      await _metadataBox.put(_lastSyncKey, DateTime.now().toIso8601String());

      // Debug log
      print(
        'CategoriesRepository: saved ${hiveCategories.length} categories to Hive',
      );
    } catch (e) {
      print('Erreur lors de la sauvegarde des catégories: $e');
    }
  }

  /// Save a single category to cache (Hive only)
  Future<void> saveCategory(Category category) async {
    try {
      final hiveCategory = HiveCategory.fromCategory(category);
      await _box.put(category.id, hiveCategory);

      // Debug log
      print('CategoriesRepository: saved category ${category.id} to Hive');
    } catch (e) {
      print('Erreur lors de la sauvegarde de la catégorie: $e');
    }
  }

  /// Get a category by ID from cache
  Future<HiveCategory?> getCategoryById(String categoryId) async {
    try {
      return _box.get(categoryId);
    } catch (e) {
      print('Erreur lors de la lecture de la catégorie: $e');
      return null;
    }
  }

  /// Get a category by slug from cache
  Future<HiveCategory?> getCategoryBySlug(String slug) async {
    try {
      final allCategories = _box.values.toList();
      for (var cat in allCategories) {
        if (cat.slug == slug) {
          return cat;
        }
      }
      return null;
    } catch (e) {
      print('Erreur lors de la recherche de catégorie par slug: $e');
      return null;
    }
  }

  /// Clear all categories from cache
  Future<void> clearAllCategories() async {
    try {
      await _box.clear();
      await _metadataBox.delete(_lastSyncKey);
    } catch (e) {
      print('Erreur lors du vidage du cache des catégories: $e');
    }
  }

  /// Get the last sync time
  Future<DateTime?> getLastSyncTime() async {
    try {
      final syncTimeStr = _metadataBox.get(_lastSyncKey) as String?;
      if (syncTimeStr != null) {
        return DateTime.parse(syncTimeStr);
      }
    } catch (e) {
      print('Erreur lors de la lecture du timestamp de synchro: $e');
    }
    return null;
  }

  /// Check if cache needs refresh (older than X minutes)
  Future<bool> needsRefresh({int minutesThreshold = 120}) async {
    try {
      final lastSync = await getLastSyncTime();
      if (lastSync == null) return true;

      final now = DateTime.now();
      final difference = now.difference(lastSync).inMinutes;
      return difference > minutesThreshold;
    } catch (e) {
      return true;
    }
  }
}
