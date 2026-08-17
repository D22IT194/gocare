import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/nearby_provider.dart';
import '../services/nearby_places_service.dart';
import '../widgets/nearby_place_card.dart';
import '../models/nearby_category.dart';
import 'saved_places_screen.dart';
import '../widgets/categories_drawer.dart';

class NearbyScreen extends StatefulWidget {
  const NearbyScreen({super.key});

  @override
  State<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<NearbyScreen> {
  // ==========================================================
  // UI STATE
  // ==========================================================

  final TextEditingController _searchController = TextEditingController();

  String _categorySearch = '';

  // ==========================================================
  // CATEGORY GROUPS
  // ==========================================================

  static const List<NearbyPlaceCategory> _healthcareCategories = [
    NearbyPlaceCategory.hospital,
    NearbyPlaceCategory.clinic,
    NearbyPlaceCategory.doctor,
    NearbyPlaceCategory.pharmacy,
    NearbyPlaceCategory.medicalLab,
    NearbyPlaceCategory.dentalClinic,
    NearbyPlaceCategory.eyeCare,
    NearbyPlaceCategory.mentalHealth,
    NearbyPlaceCategory.cardiology,
    NearbyPlaceCategory.pediatricCare,
    NearbyPlaceCategory.orthopedic,
    NearbyPlaceCategory.maternity,
    NearbyPlaceCategory.diagnosticCenter,
    NearbyPlaceCategory.physiotherapy,
  ];

  static const List<NearbyPlaceCategory> _emergencyCategories = [
    NearbyPlaceCategory.emergency,
    NearbyPlaceCategory.police,
    NearbyPlaceCategory.fireStation,
    NearbyPlaceCategory.ambulance,
  ];

  static const List<NearbyPlaceCategory> _supportCategories = [
    NearbyPlaceCategory.bloodBank,
    NearbyPlaceCategory.rehabilitation,
    NearbyPlaceCategory.homeHealthcare,
    NearbyPlaceCategory.nursingService,
    NearbyPlaceCategory.medicalEquipment,
  ];

  // ==========================================================
  // LIFECYCLE
  // ==========================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final provider = context.read<NearbyProvider>();

      if (!provider.hasLocation && !provider.isLoading) {
        provider.loadCurrentLocation();
      }

      // Load saved places in background.
      provider.loadSavedPlaces();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NearbyProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),

      appBar: _buildAppBar(context, provider),

      body: SafeArea(child: _buildNearbyView(context, provider)),
    );
  }

   // ==========================================================
  // APP BAR (REDESIGNED PREMIUM STYLE)
  // ==========================================================

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    NearbyProvider provider,
  ) {
    // Shared styling properties for the action buttons
    final double buttonSize = 40.0;
    final Color iconColor = const Color(0xFF1976D2);
    final Color buttonBgColor = const Color(0xFF1976D2).withValues(alpha: 0.06);

    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent, // Fixes default material color tint changes on scroll
      elevation: 0,
      titleSpacing: 20, // Increased spacing slightly for a more premium look
      
      // Bottom divider line separating the app bar from screen content cleanly
      shape: Border(
        bottom: BorderSide(
          color: Colors.grey.shade100,
          width: 1.2,
        ),
      ),

      title: const Text(
        'Nearby',
        style: TextStyle(
          fontSize: 22, // Lifted slightly for clear visibility
          fontWeight: FontWeight.w800,
          color: Color(0xFF172B4D),
          letterSpacing: -0.4, // Modern tight typography spacing look
        ),
      ),

      actions: [
        // 1. CATEGORIES BUTTON MODULE
        SizedBox(
          width: buttonSize,
          height: buttonSize,
          child: Material(
            color: buttonBgColor,
            shape: const CircleBorder(),
            child: IconButton(
              tooltip: 'Categories',
              padding: EdgeInsets.zero,
              onPressed: () => _openCategoriesDrawer(context),
              icon: Icon(Icons.category_rounded, color: iconColor, size: 20),
            ),
          ),
        ),

        const SizedBox(width: 10),

        // 2. SAVED PLACES BUTTON MODULE
        SizedBox(
          width: buttonSize,
          height: buttonSize,
          child: Material(
            color: buttonBgColor,
            shape: const CircleBorder(),
            child: IconButton(
              tooltip: 'Saved places',
              padding: EdgeInsets.zero,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SavedPlacesScreen()),
                );
              },
              icon: Icon(Icons.bookmark_rounded, color: iconColor, size: 20),
            ),
          ),
        ),

        const SizedBox(width: 10),

        // 3. REFRESH BUTTON MODULE
        SizedBox(
          width: buttonSize,
          height: buttonSize,
          child: Material(
            color: provider.isLoading 
                ? Colors.grey.shade100 
                : buttonBgColor,
            shape: const CircleBorder(),
            child: IconButton(
              tooltip: 'Refresh',
              padding: EdgeInsets.zero,
              onPressed: provider.isLoading ? null : () => provider.refresh(),
              icon: Icon(
                Icons.refresh_rounded, 
                color: provider.isLoading ? Colors.grey.shade400 : iconColor, 
                size: 20,
              ),
            ),
          ),
        ),

        const SizedBox(width: 16), // Balanced right edge screen padding
      ],
    );
  }


  void _openCategoriesDrawer(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierLabel: 'Categories',
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.35),

      transitionDuration: const Duration(milliseconds: 260),

      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerLeft,
          child: NearbyCategoriesDrawer(
            healthcareCategories: _healthcareCategories,
            emergencyCategories: _emergencyCategories,
            supportCategories: _supportCategories,

            onCategorySelected: (category) async {
              // Close drawer first.
              Navigator.of(context).pop();

              // Wait until drawer animation/navigation is finished.
              await Future<void>.delayed(const Duration(milliseconds: 80));

              if (!mounted) {
                return;
              }

              await _selectCategory(category);
            },
          ),
        );
      },

      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );
      },
    );
  }

  // ==========================================================
  // NEARBY VIEW
  // ==========================================================

  Widget _buildNearbyView(BuildContext context, NearbyProvider provider) {
    return RefreshIndicator(
      color: const Color(0xFF1976D2),
      onRefresh: provider.refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
        children: [
          // ----------------------------------------------------
          // LOCATION
          // ----------------------------------------------------
          _LocationCard(
            provider: provider,
            onChangeLocation: _showChangeLocationSheet,
          ),

          const SizedBox(height: 18),

          // ----------------------------------------------------
          // TITLE
          // ----------------------------------------------------
          // const Text(
          //   'Find nearby care',
          //   style: TextStyle(
          //     fontSize: 24,
          //     fontWeight: FontWeight.w800,
          //     color: Color(0xFF172B4D),
          //   ),
          // ),

          // const SizedBox(height: 6),

          // const Text(
          //   'First select a category or search for a place.',
          //   style: TextStyle(
          //     fontSize: 14,
          //     height: 1.45,
          //     color: Color(0xFF667085),
          //   ),
          // ),

          // const SizedBox(height: 16),

          // ----------------------------------------------------
          // SEARCH
          // ----------------------------------------------------
          _SearchField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _categorySearch = value.trim();
              });
            },
            onClear: () {
              _searchController.clear();

              setState(() {
                _categorySearch = '';
              });
            },
            onSubmitted: (value) {
              _handleSearch(context, value.trim());
            },
          ),

          const SizedBox(height: 15),

          // ----------------------------------------------------
          // SEARCH RESULT MODE
          // ----------------------------------------------------
          if (_categorySearch.isNotEmpty) _buildFilteredCategories(provider),

          // ----------------------------------------------------
          // INITIAL / EMPTY STATE
          // ----------------------------------------------------
          if (_categorySearch.isEmpty &&
              provider.selectedCategory == null &&
              provider.places.isEmpty &&
              !provider.isLoading)
            const _NearbyInitialCard(),

          // ----------------------------------------------------
          // RESULTS
          // ----------------------------------------------------
          if (provider.selectedCategory != null) ...[
            const SizedBox(height: 10),

            _SelectedCategoryHeader(
              category: provider.selectedCategory!,
              resultCount: provider.places.length,
              onClear: () {
                provider.clearPlaces();
              },
            ),

            const SizedBox(height: 12),

            _buildResults(provider),
          ],

          // ----------------------------------------------------
          // LOCATION LOADING INDICATOR
          // ----------------------------------------------------
          if (provider.isLoading && provider.places.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 18),
              child: _SmallLoadingCard(),
            ),
        ],
      ),
    );
  }

  // ==========================================================
  // FILTERED CATEGORY SEARCH
  // ==========================================================

  Widget _buildFilteredCategories(NearbyProvider provider) {
    final allCategories = [
      ..._healthcareCategories,
      ..._emergencyCategories,
      ..._supportCategories,
    ];

    final query = _categorySearch.toLowerCase();

    final filtered = allCategories.where((category) {
      return category.displayName.toLowerCase().contains(query) ||
          category.name.toLowerCase().contains(query);
    }).toList();

    if (filtered.isEmpty) {
      return _NoCategoryResults(query: _categorySearch);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categories',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF172B4D),
          ),
        ),

        const SizedBox(height: 12),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filtered.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.25,
          ),
          itemBuilder: (context, index) {
            final category = filtered[index];

            return _CategoryCard(
              category: category,
              selected: provider.selectedCategory == category,
              onTap: () {
                _selectCategory(category);
              },
            );
          },
        ),
      ],
    );
  }

  // ==========================================================
  // SELECT CATEGORY
  // ==========================================================

  Future<void> _selectCategory(NearbyPlaceCategory category) async {
    FocusScope.of(context).unfocus();

    // Clear category text search after selecting
    // a category from the drawer.
    if (_searchController.text.isNotEmpty) {
      _searchController.clear();

      if (mounted) {
        setState(() {
          _categorySearch = '';
        });
      }
    }

    if (!mounted) {
      return;
    }

    await context.read<NearbyProvider>().searchPlaces(category);
  }
  // ==========================================================
  // SEARCH
  // ==========================================================

  Future<void> _handleSearch(BuildContext context, String value) async {
    if (value.trim().isEmpty) {
      return;
    }

    FocusScope.of(context).unfocus();

    await context.read<NearbyProvider>().searchText(value.trim());
  }

  // ==========================================================
  // RESULTS
  // ==========================================================

  Widget _buildResults(NearbyProvider provider) {
    if (provider.isLoading) {
      return const Column(
        children: [_ResultSkeleton(), SizedBox(height: 12), _ResultSkeleton()],
      );
    }

    if (provider.status == NearbyStatus.error) {
      return _ResultError(
        message: provider.errorMessage ?? 'Unable to load places.',
        onRetry: () {
          final category = provider.selectedCategory;

          if (category != null) {
            provider.searchPlaces(category);
          }
        },
      );
    }

    if (provider.places.isEmpty) {
      return _EmptyResults(
        category: provider.selectedCategory,
        onRetry: () {
          final category = provider.selectedCategory;

          if (category != null) {
            provider.searchPlaces(category);
          }
        },
      );
    }

    return Column(
      children: [
        ...provider.places.map((place) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: NearbyPlaceCard(
              place: place,

              // IMPORTANT:
              // Keep the existing UI/card
              // callback unchanged.
              onFavoriteToggle: (updatedPlace) {
                context.read<NearbyProvider>().toggleFavorite(updatedPlace);
              },
            ),
          );
        }),
      ],
    );
  }

  // ==========================================================
  // CHANGE LOCATION
  // ==========================================================

  void _showChangeLocationSheet() {
    final provider = context.read<NearbyProvider>();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _LocationBottomSheet(provider: provider);
      },
    );
  }
}

// ============================================================================
// LOCATION CARD
// ============================================================================

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.provider, required this.onChangeLocation});

  final NearbyProvider provider;

  final VoidCallback onChangeLocation;

  @override
  Widget build(BuildContext context) {
    final locationText = _getLocationText(provider);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onChangeLocation,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEAF4FF), Color(0xFFF5F9FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD6E9FF)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Color(0xFF1976D2),
                  size: 25,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your location',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF667085),
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      locationText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF172B4D),
                      ),
                    ),

                    const SizedBox(height: 3),

                    const Text(
                      'Tap to change location',
                      style: TextStyle(fontSize: 11, color: Color(0xFF667085)),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right_rounded, color: Color(0xFF667085)),
            ],
          ),
        ),
      ),
    );
  }

  String _getLocationText(NearbyProvider provider) {
    if (provider.locationName != null && provider.locationName!.isNotEmpty) {
      return provider.locationName!;
    }

    if (provider.isLoading) {
      return 'Getting your location...';
    }

    return 'Location unavailable';
  }
}

// ============================================================================
// CATEGORY SECTION
// ============================================================================

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.categories,
    required this.expanded,
    required this.selectedCategory,
    required this.onExpand,
    required this.onCategorySelected,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  final List<NearbyPlaceCategory> categories;

  final bool expanded;

  final NearbyPlaceCategory? selectedCategory;

  final VoidCallback onExpand;

  final ValueChanged<NearbyPlaceCategory> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4E7EC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ==============================================================
          // SECTION HEADER
          // ==============================================================
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onExpand,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 15, 13, 15),
                child: Row(
                  children: [
                    // Section icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEAF4FF), Color(0xFFF4F9FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        icon,
                        color: const Color(0xFF1976D2),
                        size: 24,
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Title
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF172B4D),
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF667085),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Category count
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F4F7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${categories.length}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF667085),
                        ),
                      ),
                    ),

                    const SizedBox(width: 5),

                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF667085),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ==============================================================
          // CATEGORY GRID
          // ==============================================================
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            firstCurve: Curves.easeOut,
            secondCurve: Curves.easeIn,
            crossFadeState: expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,

            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,

                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 9,
                  mainAxisSpacing: 9,
                  childAspectRatio: 2.05,
                ),

                itemBuilder: (context, index) {
                  final category = categories[index];

                  return _CategoryCard(
                    category: category,
                    selected: selectedCategory == category,
                    onTap: () {
                      onCategorySelected(category);
                    },
                  );
                },
              ),
            ),

            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// CATEGORY CARD
// ============================================================================

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final NearbyPlaceCategory category;

  final bool selected;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,

          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),

          decoration: BoxDecoration(
            color: selected ? const Color(0xFFEAF4FF) : const Color(0xFFF8FAFC),

            borderRadius: BorderRadius.circular(16),

            border: Border.all(
              color: selected
                  ? const Color(0xFF1976D2)
                  : const Color(0xFFE4E7EC),

              width: selected ? 1.4 : 1,
            ),

            boxShadow: [
              if (!selected)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.018),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
            ],
          ),

          child: Row(
            children: [
              // ============================================================
              // CATEGORY ICON
              // ============================================================
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),

                width: 40,
                height: 40,

                decoration: BoxDecoration(
                  color: selected ? const Color(0xFF1976D2) : Colors.white,

                  borderRadius: BorderRadius.circular(12),

                  border: selected
                      ? null
                      : Border.all(color: const Color(0xFFE4E7EC)),
                ),

                child: Icon(
                  category.icon,
                  size: 20,
                  color: selected ? Colors.white : const Color(0xFF1976D2),
                ),
              ),

              const SizedBox(width: 9),

              // ============================================================
              // CATEGORY NAME
              // ============================================================
              Expanded(
                child: Text(
                  category.displayName,

                  maxLines: 2,

                  overflow: TextOverflow.ellipsis,

                  style: TextStyle(
                    fontSize: 12,
                    height: 1.15,

                    fontWeight: FontWeight.w700,

                    color: selected
                        ? const Color(0xFF145DA0)
                        : const Color(0xFF344054),
                  ),
                ),
              ),

              // ============================================================
              // SELECTED ICON
              // ============================================================
              if (selected) ...[
                const SizedBox(width: 4),

                const Icon(
                  Icons.check_circle_rounded,
                  size: 17,
                  color: Color(0xFF1976D2),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SELECTED CATEGORY HEADER
// ============================================================================

class _SelectedCategoryHeader extends StatelessWidget {
  const _SelectedCategoryHeader({
    required this.category,
    required this.resultCount,
    required this.onClear,
  });

  final NearbyPlaceCategory category;

  final int resultCount;

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(category.icon, color: const Color(0xFF1976D2)),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.displayName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF172B4D),
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  '$resultCount places nearby',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF667085),
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            tooltip: 'Change category',
            onPressed: onClear,
            icon: const Icon(Icons.close_rounded, color: Color(0xFF667085)),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// EMPTY RESULTS
// ============================================================================

class _EmptyResults extends StatelessWidget {
  const _EmptyResults({required this.category, required this.onRetry});

  final NearbyPlaceCategory? category;

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: const BoxDecoration(
              color: Color(0xFFF2F4F7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 32,
              color: Color(0xFF98A2B3),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            category == null
                ? 'No places found'
                : 'No ${category!.displayName.toLowerCase()} found',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF172B4D),
            ),
          ),

          const SizedBox(height: 7),

          const Text(
            'Try another category or '
            'search in a different location.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: Color(0xFF667085),
            ),
          ),

          const SizedBox(height: 18),

          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Try Again'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1976D2),
              side: const BorderSide(color: Color(0xFF1976D2)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// RESULT ERROR
// ============================================================================

class _ResultError extends StatelessWidget {
  const _ResultError({required this.message, required this.onRetry});

  final String message;

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6F5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFD92D20)),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 13, color: Color(0xFFB42318)),
            ),
          ),

          IconButton(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFFD92D20)),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// CATEGORY SEARCH EMPTY
// ============================================================================

class _NoCategoryResults extends StatelessWidget {
  const _NoCategoryResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 42,
            color: Color(0xFF98A2B3),
          ),

          const SizedBox(height: 10),

          // Text(
          //   'No category found for "$query"',
          //   textAlign: TextAlign.center,
          //   style: const TextStyle(
          //     fontSize: 15,
          //     fontWeight: FontWeight.w700,
          //     color: Color(0xFF344054),
          //   ),
          // ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA), // Subtle grey background tint
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // const SizedBox(width: 16),
          // 1. Text Field with internal X Button
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              textInputAction: TextInputAction.search,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF172B4D),
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Search hospitals, doctors, places...',
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF98A2B3),
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,

                // SuffixIcon places the X button directly inside the text area boundary
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        onPressed: onClear,
                        padding: EdgeInsets.zero,
                        // Adding constraints keeps the ripple effect small and centered
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.cancel_rounded,
                          size: 20,
                          color: Color(0xFFBAC2D1),
                        ),
                      )
                    : null,

                // Internal Padding Configuration
                contentPadding: const EdgeInsets.only(
                  left: 8, // Keeps text slightly away from the start edge
                  right:
                      8, // Safe spacing gap before the text hits the X button
                  top:
                      15, // Vertically centers the text inside the 52px high container
                  bottom:
                      15, // Vertically centers the text inside the 52px high container
                ),
              ),
            ),
          ),

          const SizedBox(width: 6),

          // 2. Action Search Button (Magnifying Glass)
          SizedBox(
            height: 52,
            width: 52,
            child: Card(
              margin: EdgeInsets.zero,
              color: const Color(0xFF1976D2),
              elevation: 2,
              shadowColor: const Color(0xFF1976D2).withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () => onSubmitted(controller.text),
                borderRadius: BorderRadius.circular(12),
                child: const Icon(
                  Icons
                      .search_rounded, // Swapped to standard search magnifying glass
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// NEARBY INITIAL CARD
// ============================================================================

class _NearbyInitialCard extends StatelessWidget {
  const _NearbyInitialCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE4E7EC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ================================================================
          // ICON
          // ================================================================
          Container(
            width: 76,
            height: 76,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF4FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.explore_outlined,
              size: 38,
              color: Color(0xFF1976D2),
            ),
          ),

          const SizedBox(height: 18),

          // ================================================================
          // TITLE
          // ================================================================
          const Text(
            'Find places near you',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: Color(0xFF172B4D),
            ),
          ),

          const SizedBox(height: 8),

          // ================================================================
          // DESCRIPTION
          // ================================================================
          const Text(
            'Select Categories & Search for a healthcare service nearby you.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Color(0xFF667085),
            ),
          ),

          const SizedBox(height: 20),

          // ================================================================
          // QUICK ACTIONS
          // ================================================================
          Row(
            // 1. Centers the row contents horizontally on the screen
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width:
                    250, // Set the exact width you want for the centered card
                child: _InitialAction(
                  icon: Icons.category_outlined,
                  title: 'Categories',
                  subtitle: 'Browse services',
                  onTap: () {
                    final state = context
                        .findAncestorStateOfType<_NearbyScreenState>();
                    state?._openCategoriesDrawer(context);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// INITIAL ACTION
// ============================================================================

class _InitialAction extends StatelessWidget {
  const _InitialAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFE4E7EC)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4FF),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 20, color: const Color(0xFF1976D2)),
              ),

              const SizedBox(width: 9),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF344054),
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF667085),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// LOCATION BOTTOM SHEET
// ============================================================================

class _LocationBottomSheet extends StatefulWidget {
  const _LocationBottomSheet({required this.provider});

  final NearbyProvider provider;

  @override
  State<_LocationBottomSheet> createState() => _LocationBottomSheetState();
}

class _LocationBottomSheetState extends State<_LocationBottomSheet> {
  late final TextEditingController _controller;

  bool _isClosing = false;
  bool _isSelectingLocation = false;

  Future<void> _closeSheet() async {
    if (!mounted || _isClosing) {
      return;
    }

    _isClosing = true;

    FocusScope.of(context).unfocus();

    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 20 + bottomInset),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Consumer<NearbyProvider>(
          builder: (context, provider, _) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==========================================================
                  // HANDLE
                  // ==========================================================
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD0D5DD),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ==========================================================
                  // TITLE
                  // ==========================================================
                  const Text(
                    'Change location',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF172B4D),
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Search and select a location.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF667085)),
                  ),

                  const SizedBox(height: 18),

                  // ==========================================================
                  // CURRENT LOCATION
                  // ==========================================================
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        if (_isSelectingLocation || _isClosing) {
                          return;
                        }

                        setState(() {
                          _isSelectingLocation = true;
                        });

                        final success = await provider.loadCurrentLocation();

                        if (!mounted) {
                          return;
                        }

                        if (!success) {
                          setState(() {
                            _isSelectingLocation = false;
                          });
                          return;
                        }

                        await _closeSheet();
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF4FF),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.my_location_rounded,
                              color: Color(0xFF1976D2),
                            ),

                            SizedBox(width: 12),

                            Expanded(
                              child: Text(
                                'Use current location',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF172B4D),
                                ),
                              ),
                            ),

                            Icon(
                              Icons.chevron_right_rounded,
                              color: Color(0xFF667085),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ==========================================================
                  // SEARCH FIELD
                  // ==========================================================
                  TextField(
                    controller: _controller,
                    autofocus: true,
                    onChanged: provider.searchLocationSuggestions,
                    decoration: InputDecoration(
                      hintText: 'Search area, city, address...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: provider.isSearchingLocations
                          ? const Padding(
                              padding: EdgeInsets.all(14),
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ==========================================================
                  // SUGGESTIONS
                  // ==========================================================
                  if (provider.locationSuggestions.isNotEmpty) ...[
                    const SizedBox(height: 10),

                    Flexible(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE4E7EC)),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          clipBehavior: Clip.antiAlias,
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            itemCount: provider.locationSuggestions.length,
                            separatorBuilder: (_, __) => const Divider(
                              height: 1,
                              color: Color(0xFFE4E7EC),
                            ),
                            itemBuilder: (context, index) {
                              final suggestion =
                                  provider.locationSuggestions[index];

                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 4,
                                ),

                                leading: const CircleAvatar(
                                  backgroundColor: Color(0xFFEAF4FF),
                                  child: Icon(
                                    Icons.location_on_outlined,
                                    color: Color(0xFF1976D2),
                                  ),
                                ),

                                title: Text(
                                  suggestion.mainText ?? suggestion.description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),

                                subtitle: suggestion.secondaryText != null
                                    ? Text(
                                        suggestion.secondaryText!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    : null,

                                onTap: () async {
                                  if (_isSelectingLocation || _isClosing) {
                                    return;
                                  }

                                  setState(() {
                                    _isSelectingLocation = true;
                                  });

                                  final success = await provider.selectLocation(
                                    suggestion,
                                  );

                                  if (!mounted) {
                                    return;
                                  }

                                  if (!success) {
                                    setState(() {
                                      _isSelectingLocation = false;
                                    });
                                    return;
                                  }

                                  await _closeSheet();
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ============================================================================
// EMPTY SAVED
// ============================================================================

class _EmptySavedPlaces extends StatelessWidget {
  const _EmptySavedPlaces({required this.onBrowse});

  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF4FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bookmark_border_rounded,
              size: 35,
              color: Color(0xFF1976D2),
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'No saved places yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF172B4D),
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Save hospitals, doctors, pharmacies '
            'and other useful places for quick access later.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Color(0xFF667085),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: onBrowse,
              icon: const Icon(Icons.explore_outlined),
              label: const Text('Explore Nearby'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SAVED PLACES ERROR
// ============================================================================

class _SavedPlacesError extends StatelessWidget {
  const _SavedPlacesError({required this.message, required this.onRetry});

  final String message;

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6F5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 32,
            color: Color(0xFFD92D20),
          ),

          const SizedBox(height: 10),

          const Text(
            'Unable to load saved places',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFFB42318),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Color(0xFFB42318)),
          ),

          const SizedBox(height: 14),

          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFD92D20),
              side: const BorderSide(color: Color(0xFFD92D20)),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SMALL LOADING
// ============================================================================

class _SmallLoadingCard extends StatelessWidget {
  const _SmallLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),

          SizedBox(width: 12),

          Text(
            'Getting nearby information...',
            style: TextStyle(fontSize: 13, color: Color(0xFF667085)),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// RESULT SKELETON
// ============================================================================

class _ResultSkeleton extends StatelessWidget {
  const _ResultSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      decoration: BoxDecoration(
        color: const Color(0xFFEDEFF2),
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }
}
