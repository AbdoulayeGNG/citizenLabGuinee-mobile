import 'package:hive/hive.dart';

// part 'hive_post.g.dart'; // Uncomment after running: flutter pub run build_runner build

// @HiveType(typeId: 0)
class HivePost {
  // @HiveField(0)
  final String id;

  // @HiveField(1)
  final String title;

  // @HiveField(2)
  final String? slug;

  // @HiveField(3)
  final String? content;

  // @HiveField(4)
  final String? excerpt;

  // @HiveField(5)
  final DateTime? date;

  // @HiveField(6)
  final String? imageUrl;

  // @HiveField(7)
  final String? imageAlt;

  // @HiveField(8)
  final String? authorName;

  // @HiveField(9)
  final List<String> categories;

  // @HiveField(10)
  final DateTime cachedAt;

  HivePost({
    required this.id,
    required this.title,
    this.slug,
    this.content,
    this.excerpt,
    this.date,
    this.imageUrl,
    this.imageAlt,
    this.authorName,
    this.categories = const [],
    required this.cachedAt,
  });

  /// Convert from Post model to HivePost
  factory HivePost.fromPost(dynamic post) {
    return HivePost(
      id: post.id ?? '',
      title: post.title ?? 'Sans titre',
      slug: post.slug,
      content: post.content,
      excerpt: post.excerpt,
      date: _parseDate(post.date),
      imageUrl: post.imageUrl,
      imageAlt: post.imageAlt,
      authorName: post.authorName,
      categories: post.categories ?? [],
      cachedAt: DateTime.now(),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        // Try common fallback formats or ignore
        return null;
      }
    }
    return null;
  }

  /// Convert HivePost back to Post model
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'content': content,
      'excerpt': excerpt,
      'date': date?.toIso8601String(),
      'imageUrl': imageUrl,
      'imageAlt': imageAlt,
      'authorName': authorName,
      'categories': categories,
      'cachedAt': cachedAt.toIso8601String(),
    };
  }

  /// Create HivePost from JSON
  factory HivePost.fromJson(Map<String, dynamic> json) {
    return HivePost(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Sans titre',
      slug: json['slug'] as String?,
      content: json['content'] as String?,
      excerpt: json['excerpt'] as String?,
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : null,
      imageUrl: json['imageUrl'] as String?,
      imageAlt: json['imageAlt'] as String?,
      authorName: json['authorName'] as String?,
      categories: List<String>.from(json['categories'] as List? ?? []),
      cachedAt: json['cachedAt'] != null
          ? DateTime.parse(json['cachedAt'] as String)
          : DateTime.now(),
    );
  }
}

// Manual TypeAdapter for HivePost so we don't rely on generated code.
class HivePostAdapter extends TypeAdapter<HivePost> {
  @override
  final int typeId = 0;

  @override
  HivePost read(BinaryReader reader) {
    final map = Map<String, dynamic>.from(reader.read() as Map);
    return HivePost.fromJson(map);
  }

  @override
  void write(BinaryWriter writer, HivePost obj) {
    writer.write(obj.toJson());
  }
}
