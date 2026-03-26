import 'package:hive/hive.dart';

import '../domain/character_models.dart';

class CharacterLocalDataSource {
  CharacterLocalDataSource({
    required Box<dynamic> pageBox,
    required Box<dynamic> characterBox,
    required Box<dynamic> favoritesBox,
    required Box<dynamic> overrideBox,
  })  : _pageBox = pageBox,
        _characterBox = characterBox,
        _favoritesBox = favoritesBox,
        _overrideBox = overrideBox;

  final Box<dynamic> _pageBox;
  final Box<dynamic> _characterBox;
  final Box<dynamic> _favoritesBox;
  final Box<dynamic> _overrideBox;

  Future<void> savePage(CharacterPage page) async {
    for (final character in page.characters) {
      await _characterBox.put(character.id, character.toJson());
    }

    await _pageBox.put(page.page, {
      'ids': page.characters.map((item) => item.id).toList(),
      'hasNextPage': page.hasNextPage,
    });
  }

  CharacterPage? getCachedPage(int page) {
    final raw = _pageBox.get(page);
    if (raw is! Map) {
      return null;
    }

    final ids = (raw['ids'] as List<dynamic>? ?? const []).cast<int>();
    final characters = ids
        .map(getCharacter)
        .whereType<Character>()
        .toList(growable: false);

    if (characters.isEmpty) {
      return null;
    }

    return CharacterPage(
      characters: characters,
      page: page,
      hasNextPage: raw['hasNextPage'] as bool? ?? false,
      fromCache: true,
    );
  }

  List<Character> getCachedCharactersForPages(Iterable<int> pages) {
    final items = <Character>[];
    for (final page in pages) {
      final cached = getCachedPage(page);
      if (cached != null) {
        items.addAll(cached.characters);
      }
    }
    return items;
  }

  Character? getCharacter(int id) {
    final raw = _characterBox.get(id);
    if (raw is! Map) {
      return null;
    }

    return Character.fromJson(raw);
  }

  Future<void> saveCharacter(Character character) async {
    await _characterBox.put(character.id, character.toJson());
  }

  Set<int> getFavoriteIds() {
    return _favoritesBox.keys.cast<int>().toSet();
  }

  Future<void> setFavorite(int id, bool isFavorite) async {
    if (isFavorite) {
      await _favoritesBox.put(id, true);
      return;
    }
    await _favoritesBox.delete(id);
  }

  Map<int, CharacterOverride> getOverrides() {
    final output = <int, CharacterOverride>{};
    for (final key in _overrideBox.keys.cast<int>()) {
      final raw = _overrideBox.get(key);
      if (raw is Map) {
        output[key] = CharacterOverride.fromJson(raw);
      }
    }
    return output;
  }

  Future<void> saveOverride(int id, CharacterOverride override) async {
    if (override.isEmpty) {
      await _overrideBox.delete(id);
      return;
    }
    await _overrideBox.put(id, override.toJson());
  }

  Future<void> deleteOverride(int id) async {
    await _overrideBox.delete(id);
  }
}
