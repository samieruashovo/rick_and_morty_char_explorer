import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/app_dimensions.dart';
import '../controllers/character_providers.dart';
import '../widgets/cached_character_image.dart';
import 'edit_character_screen.dart';

class CharacterDetailScreen extends ConsumerWidget {
  const CharacterDetailScreen({super.key, required this.characterId});

  final int characterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final characterAsync = ref.watch(mergedCharacterProvider(characterId));
    final favorites = ref.watch(favoritesControllerProvider);
    final isFavorite = favorites.contains(characterId);
    final hasOverride = ref.watch(
      overridesControllerProvider.select((value) => value.containsKey(characterId)),
    );

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () =>
                ref.read(favoritesControllerProvider.notifier).toggle(characterId),
            icon: Icon(
              isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
              color: isFavorite ? AppColors.favorite : null,
            ),
          ),
        ],
      ),
      body: characterAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (character) {
          if (character == null) {
            return const Center(
              child: Text('Character details are not available offline yet.'),
            );
          }

          return ListView(
            padding: EdgeInsets.fromLTRB(
              AppDimensions.spaceXl.w,
              0,
              AppDimensions.spaceXl.w,
              AppDimensions.space3xl.h,
            ),
            children: [
              Hero(
                tag: 'character-${character.id}',
                child: CachedCharacterImage(
                  imageUrl: character.image,
                  width: double.infinity,
                  height: AppDimensions.detailImage.h,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg.r),
                  iconSize: AppDimensions.brokenIcon.r,
                ),
              ),
              SizedBox(height: AppDimensions.spaceXl.h),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      character.name,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => EditCharacterScreen(character: character),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text('Edit'),
                  ),
                ],
              ),
              if (hasOverride)
                Padding(
                  padding: EdgeInsets.only(top: AppDimensions.spaceSm.h),
                  child: OutlinedButton.icon(
                    onPressed: () => ref
                        .read(overridesControllerProvider.notifier)
                        .clearOverride(characterId),
                    icon: const Icon(Icons.restore_rounded),
                    label: const Text('Reset to API data'),
                  ),
                ),
              SizedBox(height: AppDimensions.spaceXl.h),
              _DetailTile(label: 'Status', value: character.status),
              _DetailTile(label: 'Species', value: character.species),
              _DetailTile(label: 'Type', value: character.type),
              _DetailTile(label: 'Gender', value: character.gender),
              _DetailTile(label: 'Origin', value: character.originName),
              _DetailTile(label: 'Location', value: character.locationName),
            ],
          );
        },
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: AppDimensions.spaceSm.h),
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.spaceLg.w),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            Expanded(
              child: Text(
                value.isEmpty ? 'Unknown' : value,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
