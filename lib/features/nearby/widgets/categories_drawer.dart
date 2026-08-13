import 'package:flutter/material.dart';

import '../models/nearby_category.dart';

class NearbyCategoriesDrawer extends StatefulWidget {
  const NearbyCategoriesDrawer({
    super.key,
    required this.healthcareCategories,
    required this.emergencyCategories,
    required this.supportCategories,
    required this.onCategorySelected,
  });

  final List<NearbyPlaceCategory> healthcareCategories;
  final List<NearbyPlaceCategory> emergencyCategories;
  final List<NearbyPlaceCategory> supportCategories;

  final ValueChanged<NearbyPlaceCategory> onCategorySelected;

  @override
  State<NearbyCategoriesDrawer> createState() =>
      _NearbyCategoriesDrawerState();
}

class _NearbyCategoriesDrawerState extends State<NearbyCategoriesDrawer> {
  // ==========================================================================
  // UI STATE
  // ==========================================================================

  bool _healthcareExpanded = true;
  bool _emergencyExpanded = false;
  bool _supportExpanded = false;

  String _searchQuery = '';

  final TextEditingController _searchController =
      TextEditingController();

  // ==========================================================================
  // LIFECYCLE
  // ==========================================================================

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    final filteredHealthcare = _filterCategories(
      widget.healthcareCategories,
    );

    final filteredEmergency = _filterCategories(
      widget.emergencyCategories,
    );

    final filteredSupport = _filterCategories(
      widget.supportCategories,
    );

    final hasSearch = _searchQuery.trim().isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        right: false,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.86,
          constraints: const BoxConstraints(
            maxWidth: 390,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFFF7F9FC),
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
          ),
          child: Column(
            children: [
              // ================================================================
              // HEADER
              // ================================================================

              _buildHeader(context),

              // ================================================================
              // SEARCH
              // ================================================================

              _buildSearchField(),

              const SizedBox(height: 12),

              // ================================================================
              // CATEGORIES
              // ================================================================

              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    14,
                    4,
                    14,
                    24,
                  ),
                  children: [
                    if (hasSearch) ...[
                      _buildSearchResults(
                        context,
                        filteredHealthcare,
                        filteredEmergency,
                        filteredSupport,
                      ),
                    ] else ...[
                      // --------------------------------------------------------
                      // HEALTHCARE
                      // --------------------------------------------------------

                      _CategoryGroup(
                        title: 'Healthcare',
                        subtitle:
                            'Hospitals, doctors, pharmacies and specialists',
                        icon: Icons.health_and_safety_outlined,
                        iconBackground: const Color(0xFFEAF4FF),
                        iconColor: const Color(0xFF1976D2),
                        categories: widget.healthcareCategories,
                        expanded: _healthcareExpanded,
                        onExpand: () {
                          setState(() {
                            _healthcareExpanded =
                                !_healthcareExpanded;

                            if (_healthcareExpanded) {
                              _emergencyExpanded = false;
                              _supportExpanded = false;
                            }
                          });
                        },
                        onCategorySelected:
                            widget.onCategorySelected,
                      ),

                      const SizedBox(height: 10),

                      // --------------------------------------------------------
                      // EMERGENCY & SAFETY
                      // --------------------------------------------------------

                      _CategoryGroup(
                        title: 'Emergency & Safety',
                        subtitle:
                            'Emergency, police, fire and ambulance services',
                        icon: Icons.emergency_outlined,
                        iconBackground: const Color(0xFFFFF0F0),
                        iconColor: const Color(0xFFD92D20),
                        categories: widget.emergencyCategories,
                        expanded: _emergencyExpanded,
                        onExpand: () {
                          setState(() {
                            _emergencyExpanded =
                                !_emergencyExpanded;

                            if (_emergencyExpanded) {
                              _healthcareExpanded = false;
                              _supportExpanded = false;
                            }
                          });
                        },
                        onCategorySelected:
                            widget.onCategorySelected,
                      ),

                      const SizedBox(height: 10),

                      // --------------------------------------------------------
                      // SUPPORT
                      // --------------------------------------------------------

                      _CategoryGroup(
                        title: 'Support',
                        subtitle:
                            'Blood banks, rehabilitation and home healthcare',
                        icon: Icons.volunteer_activism_outlined,
                        iconBackground: const Color(0xFFF2F9F0),
                        iconColor: const Color(0xFF388E3C),
                        categories: widget.supportCategories,
                        expanded: _supportExpanded,
                        onExpand: () {
                          setState(() {
                            _supportExpanded =
                                !_supportExpanded;

                            if (_supportExpanded) {
                              _healthcareExpanded = false;
                              _emergencyExpanded = false;
                            }
                          });
                        },
                        onCategorySelected:
                            widget.onCategorySelected,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // HEADER
  // ==========================================================================

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        18,
        18,
        10,
        14,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE4E7EC),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.category_outlined,
              color: Color(0xFF1976D2),
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF172B4D),
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Find services near you',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF667085),
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            tooltip: 'Close',
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.close_rounded,
              color: Color(0xFF667085),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // SEARCH FIELD
  // ==========================================================================

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        14,
        14,
        14,
        0,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE4E7EC),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.025,
              ),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search categories...',
            hintStyle: const TextStyle(
              fontSize: 13,
              color: Color(0xFF98A2B3),
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Color(0xFF667085),
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();

                      setState(() {
                        _searchQuery = '';
                      });
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 19,
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 15,
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // SEARCH RESULTS
  // ==========================================================================

  Widget _buildSearchResults(
    BuildContext context,
    List<NearbyPlaceCategory> healthcare,
    List<NearbyPlaceCategory> emergency,
    List<NearbyPlaceCategory> support,
  ) {
    final allCategories = [
      ...healthcare,
      ...emergency,
      ...support,
    ];

    if (allCategories.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFE4E7EC),
          ),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 42,
              color: Color(0xFF98A2B3),
            ),
            SizedBox(height: 10),
            Text(
              'No category found',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF344054),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(
            left: 4,
            bottom: 10,
          ),
          child: Text(
            'Search results',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF172B4D),
            ),
          ),
        ),

        ...allCategories.map(
          (category) => Padding(
            padding: const EdgeInsets.only(
              bottom: 8,
            ),
            child: _SearchCategoryTile(
              category: category,
              onTap: () {
                widget.onCategorySelected(category);
              },
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // FILTER
  // ==========================================================================

  List<NearbyPlaceCategory> _filterCategories(
    List<NearbyPlaceCategory> categories,
  ) {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return categories;
    }

    return categories.where((category) {
      return category.displayName
              .toLowerCase()
              .contains(query) ||
          category.name
              .toLowerCase()
              .contains(query) ||
          category.searchQuery
              .toLowerCase()
              .contains(query);
    }).toList();
  }
}

// ============================================================================
// CATEGORY GROUP
// ============================================================================

class _CategoryGroup extends StatelessWidget {
  const _CategoryGroup({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.categories,
    required this.expanded,
    required this.onExpand,
    required this.onCategorySelected,
  });

  final String title;
  final String subtitle;

  final IconData icon;
  final Color iconBackground;
  final Color iconColor;

  final List<NearbyPlaceCategory> categories;

  final bool expanded;

  final VoidCallback onExpand;

  final ValueChanged<NearbyPlaceCategory>
      onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE4E7EC),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.025,
            ),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ==================================================================
          // GROUP HEADER
          // ==================================================================

          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onExpand,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  14,
                  14,
                  12,
                  14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: iconBackground,
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                      child: Icon(
                        icon,
                        color: iconColor,
                        size: 23,
                      ),
                    ),

                    const SizedBox(width: 11),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight:
                                  FontWeight.w800,
                              color:
                                  Color(0xFF172B4D),
                            ),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            subtitle,
                            maxLines: 2,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              height: 1.3,
                              color:
                                  Color(0xFF667085),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFFF2F4F7),
                        borderRadius:
                            BorderRadius.circular(20),
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

                    const SizedBox(width: 4),

                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration:
                          const Duration(milliseconds: 200),
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

          // ==================================================================
          // CATEGORY LIST
          // ==================================================================

          AnimatedCrossFade(
            duration:
                const Duration(milliseconds: 220),
            firstCurve: Curves.easeOut,
            secondCurve: Curves.easeIn,
            crossFadeState: expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,

            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(
                12,
                0,
                12,
                14,
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.95,
                ),
                itemBuilder: (context, index) {
                  final category =
                      categories[index];

                  return _DrawerCategoryCard(
                    category: category,
                    onTap: () {
                      onCategorySelected(category);
                    },
                  );
                },
              ),
            ),

            secondChild:
                const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// CATEGORY CARD
// ============================================================================

class _DrawerCategoryCard extends StatelessWidget {
  const _DrawerCategoryCard({
    required this.category,
    required this.onTap,
  });

  final NearbyPlaceCategory category;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: const Color(0xFFE4E7EC),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(11),
                  border: Border.all(
                    color: const Color(0xFFE4E7EC),
                  ),
                ),
                child: Icon(
                  category.icon,
                  size: 19,
                  color: const Color(0xFF1976D2),
                ),
              ),

              const SizedBox(width: 7),

              Expanded(
                child: Text(
                  category.displayName,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    height: 1.15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF344054),
                  ),
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
// SEARCH CATEGORY TILE
// ============================================================================

class _SearchCategoryTile extends StatelessWidget {
  const _SearchCategoryTile({
    required this.category,
    required this.onTap,
  });

  final NearbyPlaceCategory category;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: const Color(0xFFE4E7EC),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4FF),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Icon(
                  category.icon,
                  color: const Color(0xFF1976D2),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.displayName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w800,
                        color: Color(0xFF172B4D),
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      category.group,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF667085),
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF98A2B3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}