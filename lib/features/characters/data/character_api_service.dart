import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/character_models.dart';

class CharacterApiService {
  CharacterApiService({http.Client? client})
      : _client = client ?? http.Client();

  static const _baseUrl = 'https://rickandmortyapi.com/api/character';
  final http.Client _client;

  Future<CharacterPage> fetchCharacters(int page) async {
    final response = await _client.get(Uri.parse('$_baseUrl?page=$page'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load characters. Status: ${response.statusCode}');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final info = payload['info'] as Map<String, dynamic>? ?? const {};
    final results = (payload['results'] as List<dynamic>? ?? const [])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList(growable: false);

    return CharacterPage(
      characters: results.map(Character.fromApi).toList(),
      page: page,
      hasNextPage: info['next'] != null,
      fromCache: false,
    );
  }

  Future<Character> fetchCharacterById(int id) async {
    final response = await _client.get(Uri.parse('$_baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load character details.');
    }

    return Character.fromApi(jsonDecode(response.body) as Map<String, dynamic>);
  }
}
