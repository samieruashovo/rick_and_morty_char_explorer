import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/app_dimensions.dart';
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
        _scrollController.position.maxScrollExtent -
            AppDimensions.paginationTrigger.h) {
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
            padding: EdgeInsets.all(AppDimensions.space2xl.w),
            children: [
              SizedBox(height: 120.h),
              Text(
                'Unable to load characters',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppDimensions.spaceSm.h),
              Text(
                '$error',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppDimensions.spaceLg.h),
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
              padding: EdgeInsets.fromLTRB(
                AppDimensions.spaceLg.w,
                AppDimensions.spaceXs.h,
                AppDimensions.spaceLg.w,
                AppDimensions.space2xl.h,
              ),
              children: [
                if (state.usedCache)
                  Container(
                    margin: EdgeInsets.only(bottom: AppDimensions.spaceSm.h),
                    padding: EdgeInsets.all(AppDimensions.spaceSm.w),
                    decoration: BoxDecoration(
                      color: AppColors.offlineBanner,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusXs.r,
                      ),
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
                SizedBox(height: AppDimensions.spaceSm.h),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Alive', 'Dead', 'unknown']
                        .map(
                          (status) => Padding(
                            padding: EdgeInsets.only(right: AppDimensions.spaceXs.w),
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
                SizedBox(height: AppDimensions.spaceLg.h),
                if (visibleCharacters.isEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 80.h),
                    child: Center(
                      child: const Text('No characters match the current filters.'),
                    ),
                  ),
                ...visibleCharacters.map(
                  (character) => Padding(
                    padding: EdgeInsets.only(bottom: AppDimensions.spaceSm.h),
                    child: CharacterCard(character: character),
                  ),
                ),
                if (state.isLoadingMore)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: AppDimensions.spaceLg.h),
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
