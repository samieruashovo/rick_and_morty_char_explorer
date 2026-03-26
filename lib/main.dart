import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Future.wait([
    Hive.openBox<dynamic>('character_pages'),
    Hive.openBox<dynamic>('characters'),
    Hive.openBox<dynamic>('favorites'),
    Hive.openBox<dynamic>('character_overrides'),
  ]);

  runApp(const ProviderScope(child: RickAndMortyApp()));
}
