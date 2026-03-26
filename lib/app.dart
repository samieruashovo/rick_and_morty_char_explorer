import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/app_dimensions.dart';
import 'core/theme.dart';
import 'features/characters/presentation/screens/character_list_screen.dart';

class RickAndMortyApp extends StatelessWidget {
  const RickAndMortyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(
        AppDimensions.designWidth,
        AppDimensions.designHeight,
      ),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Rick and Morty Explorer',
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(),
          home: child,
        );
      },
      child: const CharacterListScreen(),
    );
  }
}
