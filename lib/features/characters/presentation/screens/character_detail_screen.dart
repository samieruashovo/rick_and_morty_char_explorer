import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/character_providers.dart';
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
              color: isFavorite ? const Color(0xFFF59E0B) : null,
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
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
            children: [
              Hero(
                tag: 'character-${character.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Image.network(
                    character.image,
                    height: 320,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 320,
                      color: const Color(0xFFE5E7EB),
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image_outlined, size: 42),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
                  padding: const EdgeInsets.only(top: 12),
                  child: OutlinedButton.icon(
                    onPressed: () => ref
                        .read(overridesControllerProvider.notifier)
                        .clearOverride(characterId),
                    icon: const Icon(Icons.restore_rounded),
                    label: const Text('Reset to API data'),
                  ),
                ),
              const SizedBox(height: 20),
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
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
