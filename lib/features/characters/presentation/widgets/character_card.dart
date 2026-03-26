import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/app_dimensions.dart';
import '../../domain/character_models.dart';
import '../controllers/character_providers.dart';
import '../screens/character_detail_screen.dart';
import 'cached_character_image.dart';

class CharacterCard extends ConsumerWidget {
  const CharacterCard({super.key, required this.character});

  final Character character;

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'alive':
        return AppColors.alive;
      case 'dead':
        return AppColors.dead;
      default:
        return AppColors.unknown;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final override = ref.watch(
      overridesControllerProvider.select((value) => value[character.id]),
    );
    final merged = character.applyOverride(override);
    final favorites = ref.watch(favoritesControllerProvider);
    final isFavorite = favorites.contains(character.id);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CharacterDetailScreen(characterId: character.id),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.spaceMd.w),
          child: Row(
            children: [
              Hero(
                tag: 'character-${character.id}',
                child: CachedCharacterImage(
                  imageUrl: merged.image,
                  width: AppDimensions.cardImage.w,
                  height: AppDimensions.cardImage.w,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm.r),
                ),
              ),
              SizedBox(width: AppDimensions.spaceMd.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      merged.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    SizedBox(height: AppDimensions.spaceXs.h),
                    Wrap(
                      spacing: AppDimensions.spaceXs.w,
                      runSpacing: AppDimensions.spaceXs.h,
                      children: [
                        _MetaChip(
                          label: merged.species,
                          color: AppColors.species,
                        ),
                        _MetaChip(
                          label: merged.status,
                          color: _statusColor(merged.status),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => ref
                    .read(favoritesControllerProvider.notifier)
                    .toggle(character.id),
                icon: Icon(
                  isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                  color: isFavorite ? AppColors.favorite : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.chipHorizontal.w,
        vertical: AppDimensions.chipVertical.h,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill.r),
      ),
      child: Text(
        label.isEmpty ? 'Unknown' : label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12.sp,
        ),
      ),
    );
  }
}
