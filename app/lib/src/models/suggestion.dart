/// Entrée de la recherche instantanée (`GET /api/v1/search/suggest`).
class SearchSuggestion {
  const SearchSuggestion({required this.slug, required this.title, this.category});

  final String slug;
  final String title;
  final String? category;

  factory SearchSuggestion.fromJson(Map<String, dynamic> json) {
    return SearchSuggestion(
      slug: json['slug'] as String,
      title: json['title'] as String,
      category: json['category'] as String?,
    );
  }
}
