import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty_char_explorer/features/characters/domain/character_models.dart';

void main() {
  test('Character overrides replace editable fields only', () {
    const character = Character(
      id: 1,
      name: 'Rick Sanchez',
      status: 'Alive',
      species: 'Human',
      type: '',
      gender: 'Male',
      originName: 'Earth',
      locationName: 'Citadel of Ricks',
      image: 'image-url',
    );

    const override = CharacterOverride(
      name: 'Local Rick',
      locationName: 'Garage',
    );

    final merged = character.applyOverride(override);

    expect(merged.name, 'Local Rick');
    expect(merged.locationName, 'Garage');
    expect(merged.status, 'Alive');
    expect(merged.image, 'image-url');
  });

  test('empty override is treated as resettable state', () {
    const override = CharacterOverride();

    expect(override.isEmpty, isTrue);
  });
}
