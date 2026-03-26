import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../domain/character_models.dart';
import 'character_api_service.dart';
import 'character_local_data_source.dart';

abstract class CharacterRepositoryBase {
  Future<CharacterPage> getCharacterPage(int page);
  List<Character> getCachedCharactersForPages(Iterable<int> pages);
  Future<Character?> getCharacterById(int id);
  Set<int> getFavoriteIds();
  Future<void> setFavorite(int id, bool isFavorite);
  Map<int, CharacterOverride> getOverrides();
  Future<void> saveOverride(int id, CharacterOverride override);
  Future<void> deleteOverride(int id);
}

class CharacterRepository implements CharacterRepositoryBase {
  CharacterRepository({
    required CharacterApiService api,
    required CharacterLocalDataSource local,
    BaseCacheManager? cacheManager,
  })  : _api = api,
        _local = local,
        _cacheManager = cacheManager ?? DefaultCacheManager();

  final CharacterApiService _api;
  final CharacterLocalDataSource _local;
  final BaseCacheManager _cacheManager;

  @override
  Future<CharacterPage> getCharacterPage(int page) async {
    try {
      final remote = await _api.fetchCharacters(page);
      await _local.savePage(remote);
      _prefetchImages(remote.characters);
      return remote;
    } catch (_) {
      final cached = _local.getCachedPage(page);
      if (cached != null) {
        return cached;
      }
      rethrow;
    }
  }

  @override
  List<Character> getCachedCharactersForPages(Iterable<int> pages) {
    return _local.getCachedCharactersForPages(pages);
  }

  @override
  Future<Character?> getCharacterById(int id) async {
    final cached = _local.getCharacter(id);
    if (cached != null) {
      return cached;
    }

    try {
      final remote = await _api.fetchCharacterById(id);
      await _local.saveCharacter(remote);
      _prefetchImages([remote]);
      return remote;
    } catch (_) {
      return null;
    }
  }

  @override
  Set<int> getFavoriteIds() => _local.getFavoriteIds();

  @override
  Future<void> setFavorite(int id, bool isFavorite) {
    return _local.setFavorite(id, isFavorite);
  }

  @override
  Map<int, CharacterOverride> getOverrides() => _local.getOverrides();

  @override
  Future<void> saveOverride(int id, CharacterOverride override) {
    return _local.saveOverride(id, override);
  }

  @override
  Future<void> deleteOverride(int id) {
    return _local.deleteOverride(id);
  }

  void _prefetchImages(List<Character> characters) {
    for (final character in characters) {
      final imageUrl = character.image.trim();
      if (imageUrl.isEmpty) {
        continue;
      }

      _cacheManager.downloadFile(imageUrl).catchError((_) {
        return null;
      });
    }
  }
}
