import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/character_models.dart';
import '../controllers/character_providers.dart';
import '../screens/character_detail_screen.dart';

class CharacterCard extends ConsumerWidget {
  const CharacterCard({super.key, required this.character});

  final Character character;

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'alive':
        return const Color(0xFF15803D);
      case 'dead':
        return const Color(0xFFB91C1C);
      default:
        return const Color(0xFF6B7280);
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
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CharacterDetailScreen(characterId: character.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Hero(
                tag: 'character-${character.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.network(
                    merged.image,
                    width: 84,
                    height: 84,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 84,
                      height: 84,
                      color: const Color(0xFFE5E7EB),
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image_outlined),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
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
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MetaChip(
                          label: merged.species,
                          color: const Color(0xFF155E75),
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
                  color: isFavorite ? const Color(0xFFF59E0B) : null,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label.isEmpty ? 'Unknown' : label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
