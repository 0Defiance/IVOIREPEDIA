import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Thème de lecture : le papier chaud par défaut, le sépia pour les longues
/// sessions, la nuit pour lire dans le noir.
enum ReadingTone { paper, sepia, night }

/// Réglages de confort, conservés sur l'appareil et jamais envoyés au serveur.
@immutable
class DisplayPrefs {
  const DisplayPrefs({
    this.tone = ReadingTone.paper,
    this.textScale = 1,
    this.readingMode = false,
  });

  final ReadingTone tone;
  final double textScale;
  final bool readingMode;

  bool get isNight => tone == ReadingTone.night;

  DisplayPrefs copyWith({ReadingTone? tone, double? textScale, bool? readingMode}) {
    return DisplayPrefs(
      tone: tone ?? this.tone,
      textScale: textScale ?? this.textScale,
      readingMode: readingMode ?? this.readingMode,
    );
  }

  Map<String, dynamic> toJson() => {
        'tone': tone.name,
        'scale': textScale,
        'reading': readingMode,
      };

  factory DisplayPrefs.fromJson(Map<String, dynamic> json) {
    final tone = ReadingTone.values.firstWhere(
      (value) => value.name == json['tone'],
      orElse: () => ReadingTone.paper,
    );

    return DisplayPrefs(
      tone: tone,
      textScale: (json['scale'] as num?)?.toDouble().clamp(0.85, 1.5) ?? 1,
      readingMode: json['reading'] == true,
    );
  }
}

/// Un article gardé en favori ou lu récemment.
@immutable
class LibraryEntry {
  const LibraryEntry({
    required this.slug,
    required this.title,
    this.category,
    this.at,
  });

  final String slug;
  final String title;
  final String? category;
  final DateTime? at;

  Map<String, dynamic> toJson() => {
        'slug': slug,
        'title': title,
        if (category != null) 'category': category,
        if (at != null) 'at': at!.millisecondsSinceEpoch,
      };

  factory LibraryEntry.fromJson(Map<String, dynamic> json) {
    final at = (json['at'] as num?)?.toInt();

    return LibraryEntry(
      slug: json['slug'] as String,
      title: json['title'] as String,
      category: json['category'] as String?,
      at: at == null ? null : DateTime.fromMillisecondsSinceEpoch(at),
    );
  }
}

/// Mémoire locale du lecteur : favoris, historique de lecture, recherches
/// récentes et réglages d'affichage.
///
/// Tout tient dans le stockage du navigateur (aucun compte, aucun serveur) :
/// l'application reste utilisable sans authentification, et rien de ce que le
/// lecteur garde ici ne quitte son appareil.
class AppStorage {
  AppStorage._();

  static final AppStorage instance = AppStorage._();

  static const _favoritesKey = 'library.favorites.v1';
  static const _recentKey = 'library.recent.v1';
  static const _searchKey = 'search.history.v1';
  static const _displayKey = 'display.prefs.v1';

  static const int maxRecent = 12;
  static const int maxSearches = 8;

  final ValueNotifier<List<LibraryEntry>> favorites = ValueNotifier(const []);
  final ValueNotifier<List<LibraryEntry>> recent = ValueNotifier(const []);
  final ValueNotifier<List<String>> searchHistory = ValueNotifier(const []);
  final ValueNotifier<DisplayPrefs> display = ValueNotifier(const DisplayPrefs());

  SharedPreferences? _prefs;
  bool _loaded = false;

  Future<SharedPreferences> get _store async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  /// Charge l'état conservé. Appelée au démarrage ; sans elle, les pages
  /// fonctionnent avec des listes vides plutôt que d'échouer.
  Future<void> load() async {
    if (_loaded) {
      return;
    }

    try {
      final prefs = await _store;
      _loaded = true;

      favorites.value = _readEntries(prefs.getString(_favoritesKey));
      recent.value = _readEntries(prefs.getString(_recentKey));
      searchHistory.value = prefs.getStringList(_searchKey) ?? const [];

      final raw = prefs.getString(_displayKey);
      if (raw != null) {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          display.value = DisplayPrefs.fromJson(decoded);
        }
      }
    } catch (_) {
      // Stockage indisponible (navigation privée stricte) : le site continue
      // sans mémoire locale, ce qui ne doit jamais empêcher la lecture.
      _loaded = true;
    }
  }

  List<LibraryEntry> _readEntries(String? raw) {
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const [];
      }

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(LibraryEntry.fromJson)
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  bool isFavorite(String slug) =>
      favorites.value.any((entry) => entry.slug == slug);

  Future<bool> toggleFavorite(LibraryEntry entry) async {
    final current = [...favorites.value];
    final existing = current.indexWhere((item) => item.slug == entry.slug);
    final added = existing < 0;

    if (added) {
      current.insert(0, entry);
    } else {
      current.removeAt(existing);
    }

    favorites.value = current;
    await _writeEntries(_favoritesKey, current);

    return added;
  }

  Future<void> recordRead(LibraryEntry entry) async {
    final current = [...recent.value]
      ..removeWhere((item) => item.slug == entry.slug)
      ..insert(0, entry);

    final trimmed = current.take(maxRecent).toList(growable: false);
    recent.value = trimmed;
    await _writeEntries(_recentKey, trimmed);
  }

  Future<void> recordSearch(String term) async {
    final value = term.trim();
    if (value.isEmpty) {
      return;
    }

    final current = [...searchHistory.value]
      ..removeWhere((item) => item.toLowerCase() == value.toLowerCase())
      ..insert(0, value);

    final trimmed = current.take(maxSearches).toList(growable: false);
    searchHistory.value = trimmed;

    try {
      final prefs = await _store;
      await prefs.setStringList(_searchKey, trimmed);
    } catch (_) {
      // Ignoré : l'historique est un confort, pas une donnée critique.
    }
  }

  Future<void> clearSearchHistory() async {
    searchHistory.value = const [];
    try {
      final prefs = await _store;
      await prefs.remove(_searchKey);
    } catch (_) {}
  }

  Future<void> clearRecent() async {
    recent.value = const [];
    try {
      final prefs = await _store;
      await prefs.remove(_recentKey);
    } catch (_) {}
  }

  Future<void> saveDisplay(DisplayPrefs prefs) async {
    display.value = prefs;
    try {
      final store = await _store;
      await store.setString(_displayKey, jsonEncode(prefs.toJson()));
    } catch (_) {}
  }

  Future<void> _writeEntries(String key, List<LibraryEntry> entries) async {
    try {
      final store = await _store;
      await store.setString(
        key,
        jsonEncode(entries.map((entry) => entry.toJson()).toList()),
      );
    } catch (_) {}
  }
}
