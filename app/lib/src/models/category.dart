/// Catégorie éditoriale telle que renvoyée par `GET /api/v1/categories`.
class Category {
  const Category({
    required this.name,
    required this.slug,
    this.description,
    this.articleCount = 0,
    this.children = const <Category>[],
  });

  final String name;
  final String slug;
  final String? description;
  final int articleCount;
  final List<Category> children;

  factory Category.fromJson(Map<String, dynamic> json) {
    final rawChildren = json['children'] as List<dynamic>? ?? const <dynamic>[];

    return Category(
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      articleCount: (json['article_count'] as num?)?.toInt() ?? 0,
      children: rawChildren
          .map((child) => Category.fromJson(child as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}
