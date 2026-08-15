import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/first_aid_model.dart';
import '../providers/first_aid_provider.dart';
import '../widgets/first_aid_card.dart';
import 'first_aid_detail_screen.dart';

class FirstAidScreen extends StatefulWidget {
  const FirstAidScreen({super.key});

  @override
  State<FirstAidScreen> createState() => _FirstAidScreenState();
}


// Look for your state class at the top of the file and add this:
final TextEditingController _searchController = TextEditingController();

class _FirstAidScreenState extends State<FirstAidScreen> {
  // ============================================================
  // SPECIAL FILTERS
  // ============================================================

  static const String _allFilter = 'All';
  static const String _savedFilter = 'My Saved First Aid';
  static const String _recentFilter = 'Recently Viewed';
  static const String _topViewedFilter = 'Top Viewed Guides';

  String _selectedFilter = _allFilter;

  // ============================================================
  // OPEN DETAIL
  // ============================================================

  void _openDetail(BuildContext context, FirstAidModel item) {
    final provider = context.read<FirstAidProvider>();

    provider.recordView(item.id);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FirstAidDetailScreen(item: item)),
    );
  }

  // ============================================================
  // SELECT FILTER
  // ============================================================

  void _selectFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  // ============================================================
  // CLEAR RECENTLY VIEWED
  // ============================================================

  void _clearRecentlyViewed(FirstAidProvider provider) {
    provider.clearRecentlyViewed();

    // If the user is currently viewing Recently Viewed,
    // automatically return to All after clearing.
    if (_selectedFilter == _recentFilter) {
      setState(() {
        _selectedFilter = _allFilter;
      });
    }
  }

  // ============================================================
  // SEARCH MATCH
  // ============================================================

  bool _matchesSearch(FirstAidModel item, String query) {
    if (query.trim().isEmpty) {
      return true;
    }

    final search = query.trim().toLowerCase();

    return item.title.toLowerCase().contains(search) ||
        item.description.toLowerCase().contains(search) ||
        item.category.toLowerCase().contains(search) ||
        item.steps.any((step) => step.toLowerCase().contains(search)) ||
        item.doNot.any((text) => text.toLowerCase().contains(search));
  }

  // ============================================================
  // GET FILTERED ITEMS
  // ============================================================

  List<FirstAidModel> _getFilteredItems(FirstAidProvider provider) {
    final query = provider.searchQuery.trim();

    List<FirstAidModel> items;

    // ----------------------------------------------------------
    // SPECIAL FILTERS
    // ----------------------------------------------------------

    if (_selectedFilter == _savedFilter) {
      items = provider.savedItems;
    } else if (_selectedFilter == _recentFilter) {
      items = provider.recentItems;
    } else if (_selectedFilter == _topViewedFilter) {
      items = provider.topViewedItems;
    }
    // ----------------------------------------------------------
    // NORMAL CATEGORY / ALL
    // ----------------------------------------------------------
    else {
      items = provider.searchItems(category: _selectedFilter);
    }

    // ----------------------------------------------------------
    // SEARCH
    // ----------------------------------------------------------

    if (query.isEmpty) {
      return items;
    }

    return items.where((item) => _matchesSearch(item, query)).toList();
  }

  // ============================================================
  // FILTER COUNT
  // ============================================================

  int _getFilterCount(FirstAidProvider provider, String filter) {
    if (filter == _savedFilter) {
      return provider.savedItems.length;
    }

    if (filter == _recentFilter) {
      return provider.recentItems.length;
    }

    if (filter == _topViewedFilter) {
      return provider.topViewedItems.length;
    }

    if (filter == _allFilter) {
      return provider.items.length;
    }

    return provider.byCategory(filter).length;
  }

  // ============================================================
  // BUILD FILTER LIST
  // ============================================================

  List<String> _buildFilters(FirstAidProvider provider) {
    final filters = <String>[_allFilter, ...provider.categories];

    // ----------------------------------------------------------
    // MY SAVED FIRST AID
    // Show only when at least one guide is saved.
    // ----------------------------------------------------------

    if (provider.savedItems.isNotEmpty) {
      filters.add(_savedFilter);
    }

    // ----------------------------------------------------------
    // RECENTLY VIEWED
    // Show only when at least one guide was viewed.
    // ----------------------------------------------------------

    if (provider.recentItems.isNotEmpty) {
      filters.add(_recentFilter);
    }

    // ----------------------------------------------------------
    // TOP VIEWED GUIDES
    // Show only when there is data.
    // ----------------------------------------------------------

    if (provider.topViewedItems.isNotEmpty) {
      filters.add(_topViewedFilter);
    }

    // ----------------------------------------------------------
    // REMOVE DUPLICATES
    // ----------------------------------------------------------

    return filters.toSet().toList();
  }

  // ============================================================
  // FILTER ICON
  // ============================================================

  IconData _filterIcon(String filter) {
    switch (filter) {
      case _allFilter:
        return Icons.grid_view_rounded;

      case _savedFilter:
        return Icons.bookmark_rounded;

      case _recentFilter:
        return Icons.history_rounded;

      case _topViewedFilter:
        return Icons.trending_up_rounded;

      case 'Injuries':
        return Icons.healing_outlined;

      case 'Emergency':
        return Icons.emergency_outlined;

      default:
        return Icons.medical_information_outlined;
    }
  }

  // ============================================================
  // FILTER COLOR
  // ============================================================

  Color _filterColor(String filter) {
    switch (filter) {
      case _savedFilter:
        return const Color(0xFF7F56D9);

      case _recentFilter:
        return const Color(0xFF667085);

      case _topViewedFilter:
        return const Color(0xFFF79009);

      case 'Emergency':
        return const Color(0xFFD92D20);

      case 'Injuries':
        return const Color(0xFF1976D2);

      default:
        return const Color(0xFF1976D2);
    }
  }

  // ============================================================
  // EMPTY TITLE
  // ============================================================

  String _emptyTitle() {
    switch (_selectedFilter) {
      case _savedFilter:
        return 'No saved guides yet';

      case _recentFilter:
        return 'No recently viewed guides';

      case _topViewedFilter:
        return 'No viewed guides yet';

      default:
        return 'No first aid guide found';
    }
  }

  // ============================================================
  // EMPTY DESCRIPTION
  // ============================================================

  String _emptyDescription() {
    switch (_selectedFilter) {
      case _savedFilter:
        return 'Save important first-aid guides to quickly access them later.';

      case _recentFilter:
        return 'Guides you open will appear here for quick access.';

      case _topViewedFilter:
        return 'Open some guides to build your most-viewed list.';

      default:
        return 'Try another search or choose a different category.';
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FirstAidProvider>();

    final filters = _buildFilters(provider);

    final filteredItems = _getFilteredItems(provider);

    final hasSearch = provider.searchQuery.trim().isNotEmpty;

    // ----------------------------------------------------------
    // SAFETY
    // ----------------------------------------------------------
    //
    // If a selected special filter disappears because its count
    // became zero, automatically move back to All.
    //
    // Example:
    // Recently Viewed -> Clear -> Recently Viewed disappears.
    // ----------------------------------------------------------

    if (!filters.contains(_selectedFilter)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        setState(() {
          _selectedFilter = _allFilter;
        });
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,

        title: const Text(
          'First Aid',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF172B4D),
            fontSize: 22,
          ),
        ),

        actions: [
          // ----------------------------------------------------
          // SAVED ACCESS
          // ----------------------------------------------------
          if (provider.savedItems.isNotEmpty)
            IconButton(
              tooltip: 'My Saved First Aid',
              onPressed: () {
                _selectFilter(_savedFilter);
              },
              icon: Badge(
                label: Text('${provider.savedItems.length}'),
                child: Icon(
                  _selectedFilter == _savedFilter
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: _selectedFilter == _savedFilter
                      ? const Color(0xFF7F56D9)
                      : const Color(0xFF475467),
                ),
              ),
            ),

          const SizedBox(width: 6),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // ==================================================
            // SEARCH
            // ==================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _SearchField(
                controller: _searchController,
                value: provider.searchQuery,
                onChanged: provider.setSearchQuery,
                onClear: provider.clearSearch,
              ),
            ),

            const SizedBox(height: 14),

            // ==================================================
            // FILTER / CATEGORIES
            // ==================================================
            SizedBox(
              height: 44,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: filters.length,
                separatorBuilder: (_, _) {
                  return const SizedBox(width: 8);
                },
                itemBuilder: (context, index) {
                  final filter = filters[index];

                  final selected = filter == _selectedFilter;

                  final color = _filterColor(filter);

                  final count = _getFilterCount(provider, filter);

                  final isSpecialFilter =
                      filter == _savedFilter ||
                      filter == _recentFilter ||
                      filter == _topViewedFilter;

                  return ChoiceChip(
                    selected: selected,

                    onSelected: (_) {
                      _selectFilter(filter);
                    },

                    avatar: Icon(
                      _filterIcon(filter),
                      size: 17,
                      color: selected ? Colors.white : color,
                    ),

                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(filter),

                        // ------------------------------------------
                        // COUNT
                        // ------------------------------------------
                        if (isSpecialFilter) ...[
                          const SizedBox(width: 5),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? Colors.white.withValues(alpha: 0.20)
                                  : color.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$count',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: selected ? Colors.white : color,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    selectedColor: color,

                    backgroundColor: Colors.white,

                    labelStyle: TextStyle(
                      color: selected ? Colors.white : const Color(0xFF475467),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),

                    side: BorderSide(
                      color: selected ? color : const Color(0xFFEAECF0),
                    ),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),

                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 7,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 4),

            // ==================================================
            // CONTENT
            // ==================================================
            Expanded(
              child: provider.isLoadingUserData
                  ? const _FirstAidLoading()
                  : RefreshIndicator(
                      color: const Color(0xFF1976D2),

                      onRefresh: () async {
                        await Future<void>.delayed(
                          const Duration(milliseconds: 300),
                        );
                      },

                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),

                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),

                        children: [
                          // ========================================
                          // CURRENT FILTER HEADER
                          // ========================================
                          _FilterHeader(
                            filter: _selectedFilter,
                            resultCount: filteredItems.length,
                            hasSearch: hasSearch,
                            onClearRecentlyViewed: () {
                              _clearRecentlyViewed(provider);
                            },
                          ),

                          const SizedBox(height: 14),

                          // ========================================
                          // RESULTS
                          // ========================================
                          if (filteredItems.isEmpty)
                            _EmptyFirstAidState(
                              title: _emptyTitle(),
                              description: _emptyDescription(),
                              isSearch: hasSearch,
                            )
                          else
                            ...filteredItems.map((item) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: FirstAidCard(
                                  item: item,
                                  onTap: () {
                                    _openDetail(context, item);
                                  },
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// SEARCH FIELD
// ============================================================================

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.value,
    required this.controller, // 1. ADD THIS CONTROLLER PARAMETER
    required this.onChanged,
    required this.onClear,
  });

  final String value;
  final TextEditingController controller; // 2. DEFINE THE CONTROLLER PROPERTY
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E7EC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller, // 3. ASSIGN CONTROLLER HERE
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search first aid topics...',
          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF98A2B3)),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF667085),
          ),
          suffixIcon: value.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    controller.clear(); // 4. PHYSICALLY WIPES TEXT FROM SCREEN
                    onClear();          // 5. CALLS YOUR FILTER CLEAR LOGIC
                  },
                  icon: const Icon(Icons.close_rounded, size: 19),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 15,
          ),
        ),
      ),
    );
  }
}


// ============================================================================
// FILTER HEADER
// ============================================================================

class _FilterHeader extends StatelessWidget {
  const _FilterHeader({
    required this.filter,
    required this.resultCount,
    required this.hasSearch,
    required this.onClearRecentlyViewed,
  });

  final String filter;
  final int resultCount;
  final bool hasSearch;
  final VoidCallback onClearRecentlyViewed;

  @override
  Widget build(BuildContext context) {
    final subtitle = hasSearch
        ? '$resultCount result${resultCount == 1 ? '' : 's'} found'
        : '$resultCount guide${resultCount == 1 ? '' : 's'}';

    final isRecentlyViewed = filter == 'Recently Viewed';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                filter,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF172B4D),
                ),
              ),

              const SizedBox(height: 4),

              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Color(0xFF667085)),
              ),
            ],
          ),
        ),

        // ==========================================================
        // CLEAR RECENTLY VIEWED
        // ==========================================================
        if (isRecentlyViewed)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onClearRecentlyViewed,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFEAECF0)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.delete_sweep_outlined,
                      size: 16,
                      color: Color(0xFF667085),
                    ),

                    SizedBox(width: 5),

                    Text(
                      'Clear',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF475467),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        const SizedBox(width: 8),

        // ==========================================================
        // FILTER ICON
        // ==========================================================
        if (filter == 'My Saved First Aid')
          const Icon(
            Icons.bookmark_rounded,
            size: 20,
            color: Color(0xFF7F56D9),
          ),

        if (filter == 'Recently Viewed')
          const Icon(Icons.history_rounded, size: 20, color: Color(0xFF667085)),

        if (filter == 'Top Viewed Guides')
          const Icon(
            Icons.trending_up_rounded,
            size: 20,
            color: Color(0xFFF79009),
          ),
      ],
    );
  }
}

// ============================================================================
// EMPTY STATE
// ============================================================================

class _EmptyFirstAidState extends StatelessWidget {
  const _EmptyFirstAidState({
    required this.title,
    required this.description,
    required this.isSearch,
  });

  final String title;
  final String description;
  final bool isSearch;

  @override
  Widget build(BuildContext context) {
    IconData icon;

    if (isSearch) {
      icon = Icons.search_off_rounded;
    } else if (title == 'No saved guides yet') {
      icon = Icons.bookmark_border_rounded;
    } else if (title == 'No recently viewed guides') {
      icon = Icons.history_rounded;
    } else if (title == 'No viewed guides yet') {
      icon = Icons.trending_up_rounded;
    } else {
      icon = Icons.medical_information_outlined;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 42),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFF2F4F7),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 30, color: const Color(0xFF667085)),
          ),

          const SizedBox(height: 16),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF172B4D),
            ),
          ),

          const SizedBox(height: 7),

          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Color(0xFF667085),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// LOADING
// ============================================================================

class _FirstAidLoading extends StatelessWidget {
  const _FirstAidLoading();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
      itemCount: 5,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return const _FirstAidSkeletonCard();
      },
    );
  }
}

// ============================================================================
// SKELETON CARD
// ============================================================================

class _FirstAidSkeletonCard extends StatelessWidget {
  const _FirstAidSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 116,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(16),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 70,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),

                const SizedBox(height: 9),

                Container(
                  width: 150,
                  height: 15,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  width: double.infinity,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
