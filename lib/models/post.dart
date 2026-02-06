/// Modèle pour un article de blog/actualité
class Post {
  final String id;
  final String title;
  final String slug;
  final String content;
  final String? excerpt;
  final String date;
  final String? imageUrl;
  final String? imageAlt;
  final String? authorName;
  final List<String>? categories; // Noms des catégories

  Post({
    required this.id,
    required this.title,
    required this.slug,
    required this.content,
    this.excerpt,
    required this.date,
    this.imageUrl,
    this.imageAlt,
    this.authorName,
    this.categories,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    List<String>? extractCategories(dynamic categoriesData) {
      if (categoriesData == null) return null;
      if (categoriesData is List) {
        return (categoriesData)
            .map(
              (cat) =>
                  cat is Map ? cat['name']?.toString() ?? '' : cat.toString(),
            )
            .where((name) => name.isNotEmpty)
            .toList();
      }
      return null;
    }

    return Post(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      content: json['content'] ?? '',
      excerpt: json['excerpt'],
      date: json['date'] ?? '',
      imageUrl: json['featuredImage']?['node']?['sourceUrl'],
      imageAlt: json['featuredImage']?['node']?['altText'],
      authorName: json['author']?['node']?['name'],
      categories: extractCategories(json['categories']?['edges']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'content': content,
      'excerpt': excerpt,
      'date': date,
      'imageUrl': imageUrl,
      'imageAlt': imageAlt,
      'authorName': authorName,
      'categories': categories,
    };
  }
}
