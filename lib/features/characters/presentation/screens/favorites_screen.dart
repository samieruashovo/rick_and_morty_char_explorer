import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/app_dimensions.dart';
import '../controllers/character_providers.dart';
import '../widgets/character_card.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoriteCharactersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: favoritesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (characters) {
          if (characters.isEmpty) {
            return const Center(
              child: Text('No favorites yet. Star a character to keep it here.'),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.all(AppDimensions.spaceLg.w),
            itemBuilder: (context, index) =>
                CharacterCard(character: characters[index]),
            separatorBuilder: (context, index) =>
                SizedBox(height: AppDimensions.spaceSm.h),
            itemCount: characters.length,
          );
        },
      ),
    );
  }
}
