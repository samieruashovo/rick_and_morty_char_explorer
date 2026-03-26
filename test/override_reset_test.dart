import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty_char_explorer/features/characters/data/character_repository.dart';
import 'package:rick_and_morty_char_explorer/features/characters/domain/character_models.dart';
import 'package:rick_and_morty_char_explorer/features/characters/presentation/controllers/character_providers.dart';
import 'package:rick_and_morty_char_explorer/features/characters/presentation/screens/character_detail_screen.dart';

void main() {
  const baseCharacter = Character(
    id: 1,
    name: 'Rick Sanchez',
    status: 'Alive',
    species: 'Human',
    type: '',
    gender: 'Male',
    originName: 'Earth (C-137)',
    locationName: 'Citadel of Ricks',
    image: 'https://example.com/rick.png',
  );

  test('clearOverride removes local edits and restores base data', () async {
    final repository = _FakeCharacterRepository(
      characters: {1: baseCharacter},
      overrides: {
        1: const CharacterOverride(
          name: 'Edited Rick',
          originName: 'Garage',
        ),
      },
    );

    final container = ProviderContainer(
      overrides: [
        characterRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final mergedBeforeReset = await container.read(
      mergedCharacterProvider(1).future,
    );
    expect(mergedBeforeReset?.name, 'Edited Rick');

    await container.read(overridesControllerProvider.notifier).clearOverride(1);

    final mergedAfterReset = await container.read(
      mergedCharacterProvider(1).future,
    );
    expect(mergedAfterReset?.name, 'Rick Sanchez');
    expect(mergedAfterReset?.originName, 'Earth (C-137)');
    expect(repository.overrides.containsKey(1), isFalse);
  });

  testWidgets('detail screen shows reset button only while override exists',
      (tester) async {
    final repository = _FakeCharacterRepository(
      characters: {1: baseCharacter},
      overrides: {
        1: const CharacterOverride(name: 'Edited Rick'),
      },
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          characterRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(
          home: CharacterDetailScreen(characterId: 1),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Edited Rick'), findsOneWidget);
    expect(find.text('Reset to API data'), findsOneWidget);

    await tester.tap(find.text('Reset to API data'));
    await tester.pumpAndSettle();

    expect(find.text('Rick Sanchez'), findsOneWidget);
    expect(find.text('Reset to API data'), findsNothing);
  });
}

class _FakeCharacterRepository implements CharacterRepositoryBase {
  _FakeCharacterRepository({
    Map<int, Character>? characters,
    Map<int, CharacterOverride>? overrides,
    Set<int>? favorites,
  })  : characters = characters ?? {},
        overrides = overrides ?? {},
        favorites = favorites ?? <int>{};

  final Map<int, Character> characters;
  final Map<int, CharacterOverride> overrides;
  final Set<int> favorites;

  @override
  Future<void> deleteOverride(int id) async {
    overrides.remove(id);
  }

  @override
  Future<Character?> getCharacterById(int id) async {
    return characters[id];
  }

  @override
  Future<CharacterPage> getCharacterPage(int page) async {
    return CharacterPage(
      characters: characters.values.toList(),
      page: page,
      hasNextPage: false,
      fromCache: true,
    );
  }

  @override
  List<Character> getCachedCharactersForPages(Iterable<int> pages) {
    return characters.values.toList();
  }

  @override
  Set<int> getFavoriteIds() => favorites;

  @override
  Map<int, CharacterOverride> getOverrides() => {...overrides};

  @override
  Future<void> saveOverride(int id, CharacterOverride override) async {
    if (override.isEmpty) {
      overrides.remove(id);
      return;
    }
    overrides[id] = override;
  }

  @override
  Future<void> setFavorite(int id, bool isFavorite) async {
    if (isFavorite) {
      favorites.add(id);
    } else {
      favorites.remove(id);
    }
  }
}
