import 'package:hive/hive.dart';

// part 'hive_category.g.dart'; // Uncomment after running: flutter pub run build_runner build

// @HiveType(typeId: 1)
class HiveCategory {
  // @HiveField(0)
  final String id;

  // @HiveField(1)
  final String name;

  // @HiveField(2)
  final String? slug;

  // @HiveField(3)
  final String? description;

  // @HiveField(4)
  final DateTime cachedAt;

  HiveCategory({
    required this.id,
    required this.name,
    this.slug,
    this.description,
    required this.cachedAt,
  });

  /// Convert from Category model to HiveCategory
  factory HiveCategory.fromCategory(dynamic category) {
    return HiveCategory(
      id: category.id ?? '',
      name: category.name ?? 'Sans nom',
      slug: category.slug,
      description: category.description,
      cachedAt: DateTime.now(),
    );
  }

  /// Convert HiveCategory back to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'cachedAt': cachedAt.toIso8601String(),
    };
  }

  /// Create HiveCategory from JSON
  factory HiveCategory.fromJson(Map<String, dynamic> json) {
    return HiveCategory(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Sans nom',
      slug: json['slug'] as String?,
      description: json['description'] as String?,
      cachedAt: json['cachedAt'] != null
          ? DateTime.parse(json['cachedAt'] as String)
          : DateTime.now(),
    );
  }
}

// Manual TypeAdapter for HiveCategory.
class HiveCategoryAdapter extends TypeAdapter<HiveCategory> {
  @override
  final int typeId = 1;

  @override
  HiveCategory read(BinaryReader reader) {
    final map = Map<String, dynamic>.from(reader.read() as Map);
    return HiveCategory.fromJson(map);
  }

  @override
  void write(BinaryWriter writer, HiveCategory obj) {
    writer.write(obj.toJson());
  }
}
