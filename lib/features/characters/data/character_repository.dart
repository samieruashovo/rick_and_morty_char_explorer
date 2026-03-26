import '../domain/character_models.dart';
import 'character_api_service.dart';
import 'character_local_data_source.dart';

class CharacterRepository {
  CharacterRepository({
    required CharacterApiService api,
    required CharacterLocalDataSource local,
  })  : _api = api,
        _local = local;

  final CharacterApiService _api;
  final CharacterLocalDataSource _local;

  Future<CharacterPage> getCharacterPage(int page) async {
    try {
      final remote = await _api.fetchCharacters(page);
      await _local.savePage(remote);
      return remote;
    } catch (_) {
      final cached = _local.getCachedPage(page);
      if (cached != null) {
        return cached;
      }
      rethrow;
    }
  }

  List<Character> getCachedCharactersForPages(Iterable<int> pages) {
    return _local.getCachedCharactersForPages(pages);
  }

  Future<Character?> getCharacterById(int id) async {
    final cached = _local.getCharacter(id);
    if (cached != null) {
      return cached;
    }

    try {
      final remote = await _api.fetchCharacterById(id);
      await _local.saveCharacter(remote);
      return remote;
    } catch (_) {
      return null;
    }
  }

  Set<int> getFavoriteIds() => _local.getFavoriteIds();

  Future<void> setFavorite(int id, bool isFavorite) {
    return _local.setFavorite(id, isFavorite);
  }

  Map<int, CharacterOverride> getOverrides() => _local.getOverrides();

  Future<void> saveOverride(int id, CharacterOverride override) {
    return _local.saveOverride(id, override);
  }

  Future<void> deleteOverride(int id) {
    return _local.deleteOverride(id);
  }
}
