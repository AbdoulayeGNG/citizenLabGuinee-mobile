/// Modèle pour une page statique ou article
class Page {
  final String id;
  final String title;
  final String content;
  final String? excerpt;
  final String date;
  final String slug;
  final String? imageUrl;
  final String? imageAlt;
  final String? authorName;

  Page({
    required this.id,
    required this.title,
    required this.content,
    this.excerpt,
    required this.date,
    required this.slug,
    this.imageUrl,
    this.imageAlt,
    this.authorName,
  });

  factory Page.fromJson(Map<String, dynamic> json) {
    return Page(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      excerpt: json['excerpt'],
      date: json['date'] ?? '',
      slug: json['slug'] ?? '',
      imageUrl: json['featuredImage']?['node']?['sourceUrl'],
      imageAlt: json['featuredImage']?['node']?['altText'],
      authorName: json['author']?['node']?['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'excerpt': excerpt,
      'date': date,
      'slug': slug,
      'featuredImage': {
        'node': {'sourceUrl': imageUrl, 'altText': imageAlt},
      },
      'author': {
        'node': {'name': authorName},
      },
    };
  }
}
