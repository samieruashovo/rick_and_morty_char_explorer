class Character {
  const Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.type,
    required this.gender,
    required this.originName,
    required this.locationName,
    required this.image,
  });

  final int id;
  final String name;
  final String status;
  final String species;
  final String type;
  final String gender;
  final String originName;
  final String locationName;
  final String image;

  Character copyWith({
    String? name,
    String? status,
    String? species,
    String? type,
    String? gender,
    String? originName,
    String? locationName,
    String? image,
  }) {
    return Character(
      id: id,
      name: name ?? this.name,
      status: status ?? this.status,
      species: species ?? this.species,
      type: type ?? this.type,
      gender: gender ?? this.gender,
      originName: originName ?? this.originName,
      locationName: locationName ?? this.locationName,
      image: image ?? this.image,
    );
  }

  Character applyOverride(CharacterOverride? override) {
    if (override == null) {
      return this;
    }

    return copyWith(
      name: override.name ?? name,
      status: override.status ?? status,
      species: override.species ?? species,
      type: override.type ?? type,
      gender: override.gender ?? gender,
      originName: override.originName ?? originName,
      locationName: override.locationName ?? locationName,
    );
  }

  factory Character.fromApi(Map<String, dynamic> json) {
    return Character(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      status: json['status'] as String? ?? '',
      species: json['species'] as String? ?? '',
      type: json['type'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      originName: (json['origin'] as Map<String, dynamic>? ?? const {})['name']
              as String? ??
          '',
      locationName:
          (json['location'] as Map<String, dynamic>? ?? const {})['name']
                  as String? ??
              '',
      image: json['image'] as String? ?? '',
    );
  }

  factory Character.fromJson(Map<dynamic, dynamic> json) {
    return Character(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      status: json['status'] as String? ?? '',
      species: json['species'] as String? ?? '',
      type: json['type'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      originName: json['originName'] as String? ?? '',
      locationName: json['locationName'] as String? ?? '',
      image: json['image'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'species': species,
      'type': type,
      'gender': gender,
      'originName': originName,
      'locationName': locationName,
      'image': image,
    };
  }
}

class CharacterOverride {
  const CharacterOverride({
    this.name,
    this.status,
    this.species,
    this.type,
    this.gender,
    this.originName,
    this.locationName,
  });

  final String? name;
  final String? status;
  final String? species;
  final String? type;
  final String? gender;
  final String? originName;
  final String? locationName;

  bool get isEmpty =>
      name == null &&
      status == null &&
      species == null &&
      type == null &&
      gender == null &&
      originName == null &&
      locationName == null;

  factory CharacterOverride.fromJson(Map<dynamic, dynamic> json) {
    return CharacterOverride(
      name: json['name'] as String?,
      status: json['status'] as String?,
      species: json['species'] as String?,
      type: json['type'] as String?,
      gender: json['gender'] as String?,
      originName: json['originName'] as String?,
      locationName: json['locationName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'status': status,
      'species': species,
      'type': type,
      'gender': gender,
      'originName': originName,
      'locationName': locationName,
    };
  }
}

class CharacterPage {
  const CharacterPage({
    required this.characters,
    required this.page,
    required this.hasNextPage,
    required this.fromCache,
  });

  final List<Character> characters;
  final int page;
  final bool hasNextPage;
  final bool fromCache;
}
