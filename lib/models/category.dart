/// Modèle pour les catégories
class Category {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final int? count; // number of posts in this category (may be null)

  Category({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.count,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'],
      count: json['count'] is int ? json['count'] as int : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'slug': slug, 'description': description};
  }
}
