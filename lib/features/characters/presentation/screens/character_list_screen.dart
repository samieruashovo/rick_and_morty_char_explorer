import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/character_providers.dart';
import '../widgets/character_card.dart';
import 'favorites_screen.dart';

class CharacterListScreen extends ConsumerStatefulWidget {
  const CharacterListScreen({super.key});

  @override
  ConsumerState<CharacterListScreen> createState() => _CharacterListScreenState();
}

class _CharacterListScreenState extends ConsumerState<CharacterListScreen> {
  final _scrollController = ScrollController();
  String _query = '';
  String _statusFilter = 'All';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      ref.read(characterListControllerProvider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(characterListControllerProvider);
    final overrides = ref.watch(overridesControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rick and Morty Explorer'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const FavoritesScreen(),
                ),
              );
            },
            icon: const Icon(Icons.star_rounded),
            tooltip: 'Favorites',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(characterListControllerProvider.notifier).refresh(),
        child: listState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 120),
              Text(
                'Unable to load characters',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                '$error',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () =>
                    ref.read(characterListControllerProvider.notifier).refresh(),
                child: const Text('Try again'),
              ),
            ],
          ),
          data: (state) {
            final visibleCharacters = state.characters.where((character) {
              final merged = character.applyOverride(overrides[character.id]);
              final matchesQuery = merged.name
                  .toLowerCase()
                  .contains(_query.trim().toLowerCase());
              final matchesStatus = _statusFilter == 'All' ||
                  merged.status.toLowerCase() == _statusFilter.toLowerCase();
              return matchesQuery && matchesStatus;
            }).toList();

            return ListView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                if (state.usedCache)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDFA),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'Showing locally cached characters. Pull to refresh when the network is back.',
                    ),
                  ),
                TextField(
                  onChanged: (value) => setState(() => _query = value),
                  decoration: const InputDecoration(
                    hintText: 'Search loaded characters',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Alive', 'Dead', 'unknown']
                        .map(
                          (status) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(status),
                              selected: _statusFilter == status,
                              onSelected: (_) {
                                setState(() => _statusFilter = status);
                              },
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 16),
                if (visibleCharacters.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(
                      child: Text('No characters match the current filters.'),
                    ),
                  ),
                ...visibleCharacters.map(
                  (character) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CharacterCard(character: character),
                  ),
                ),
                if (state.isLoadingMore)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
