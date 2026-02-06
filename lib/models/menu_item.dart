/// Modèle pour les éléments du menu
class MenuItem {
  final String id;
  final String label;
  final String url;
  final List<MenuItem>? childItems;

  MenuItem({
    required this.id,
    required this.label,
    required this.url,
    this.childItems,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      url: json['url'] ?? '',
      childItems: json['childItems'] != null
          ? (json['childItems'] as List)
                .map((item) => MenuItem.fromJson(item))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'url': url,
      'childItems': childItems?.map((item) => item.toJson()).toList(),
    };
  }
}
