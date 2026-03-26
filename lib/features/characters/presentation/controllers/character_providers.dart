import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../data/character_api_service.dart';
import '../../data/character_local_data_source.dart';
import '../../data/character_repository.dart';
import '../../domain/character_models.dart';

final _pageBoxProvider =
    Provider<Box<dynamic>>((ref) => Hive.box<dynamic>('character_pages'));
final _characterBoxProvider =
    Provider<Box<dynamic>>((ref) => Hive.box<dynamic>('characters'));
final _favoritesBoxProvider =
    Provider<Box<dynamic>>((ref) => Hive.box<dynamic>('favorites'));
final _overrideBoxProvider =
    Provider<Box<dynamic>>((ref) => Hive.box<dynamic>('character_overrides'));

final characterApiServiceProvider = Provider((ref) => CharacterApiService());

final characterLocalDataSourceProvider = Provider(
  (ref) => CharacterLocalDataSource(
    pageBox: ref.watch(_pageBoxProvider),
    characterBox: ref.watch(_characterBoxProvider),
    favoritesBox: ref.watch(_favoritesBoxProvider),
    overrideBox: ref.watch(_overrideBoxProvider),
  ),
);

final characterRepositoryProvider = Provider<CharacterRepositoryBase>(
  (ref) => CharacterRepository(
    api: ref.watch(characterApiServiceProvider),
    local: ref.watch(characterLocalDataSourceProvider),
  ),
);

class CharacterListState {
  const CharacterListState({
    required this.characters,
    required this.pagesLoaded,
    required this.hasNextPage,
    required this.isLoadingMore,
    required this.usedCache,
  });

  final List<Character> characters;
  final int pagesLoaded;
  final bool hasNextPage;
  final bool isLoadingMore;
  final bool usedCache;

  CharacterListState copyWith({
    List<Character>? characters,
    int? pagesLoaded,
    bool? hasNextPage,
    bool? isLoadingMore,
    bool? usedCache,
  }) {
    return CharacterListState(
      characters: characters ?? this.characters,
      pagesLoaded: pagesLoaded ?? this.pagesLoaded,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      usedCache: usedCache ?? this.usedCache,
    );
  }
}

class CharacterListController extends AsyncNotifier<CharacterListState> {
  @override
  Future<CharacterListState> build() async {
    final firstPage =
        await ref.read(characterRepositoryProvider).getCharacterPage(1);
    return CharacterListState(
      characters: firstPage.characters,
      pagesLoaded: 1,
      hasNextPage: firstPage.hasNextPage,
      isLoadingMore: false,
      usedCache: firstPage.fromCache,
    );
  }

  Future<void> loadNextPage() async {
    final current = state.valueOrNull;
    if (current == null || current.isLoadingMore || !current.hasNextPage) {
      return;
    }

    state = AsyncData(current.copyWith(isLoadingMore: true));
    final nextPageNumber = current.pagesLoaded + 1;

    try {
      final nextPage = await ref
          .read(characterRepositoryProvider)
          .getCharacterPage(nextPageNumber);
      state = AsyncData(
        current.copyWith(
          characters: [...current.characters, ...nextPage.characters],
          pagesLoaded: nextPageNumber,
          hasNextPage: nextPage.hasNextPage,
          isLoadingMore: false,
          usedCache: current.usedCache || nextPage.fromCache,
        ),
      );
    } catch (_) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }
}

final characterListControllerProvider =
    AsyncNotifierProvider<CharacterListController, CharacterListState>(
  CharacterListController.new,
);

class FavoritesController extends Notifier<Set<int>> {
  @override
  Set<int> build() {
    return ref.read(characterRepositoryProvider).getFavoriteIds();
  }

  Future<void> toggle(int id) async {
    final current = state.contains(id);
    final next = {...state};
    if (current) {
      next.remove(id);
    } else {
      next.add(id);
    }
    state = next;
    await ref.read(characterRepositoryProvider).setFavorite(id, !current);
  }
}

final favoritesControllerProvider =
    NotifierProvider<FavoritesController, Set<int>>(FavoritesController.new);

class OverridesController extends Notifier<Map<int, CharacterOverride>> {
  @override
  Map<int, CharacterOverride> build() {
    return ref.read(characterRepositoryProvider).getOverrides();
  }

  Future<void> saveOverride(int id, CharacterOverride override) async {
    final next = {...state};
    if (override.isEmpty) {
      next.remove(id);
    } else {
      next[id] = override;
    }
    state = next;
    await ref.read(characterRepositoryProvider).saveOverride(id, override);
  }

  Future<void> clearOverride(int id) async {
    final next = {...state}..remove(id);
    state = next;
    await ref.read(characterRepositoryProvider).deleteOverride(id);
  }
}

final overridesControllerProvider =
    NotifierProvider<OverridesController, Map<int, CharacterOverride>>(
  OverridesController.new,
);

final mergedCharacterProvider =
    FutureProvider.family<Character?, int>((ref, id) async {
  final base = await ref.watch(characterRepositoryProvider).getCharacterById(id);
  if (base == null) {
    return null;
  }

  final override = ref.watch(
    overridesControllerProvider.select((value) => value[id]),
  );
  return base.applyOverride(override);
});

final favoriteCharactersProvider = FutureProvider<List<Character>>((ref) async {
  final ids = ref.watch(favoritesControllerProvider).toList()..sort();
  final overrides = ref.watch(overridesControllerProvider);
  final repo = ref.watch(characterRepositoryProvider);

  final items = <Character>[];
  for (final id in ids) {
    final base = await repo.getCharacterById(id);
    if (base != null) {
      items.add(base.applyOverride(overrides[id]));
    }
  }
  return items;
});
