import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'features/characters/presentation/screens/character_list_screen.dart';

class RickAndMortyApp extends StatelessWidget {
  const RickAndMortyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rick and Morty Explorer',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const CharacterListScreen(),
    );
  }
}
