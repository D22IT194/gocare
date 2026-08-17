import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/medicine_model.dart';
import '../providers/medicine_provider.dart';
import '../widgets/medicine_card.dart';
import 'medicine_detail_screen.dart';

class MedicinesScreen extends StatefulWidget {
  const MedicinesScreen({
    super.key,
  });

  @override
  State<MedicinesScreen> createState() =>
      _MedicinesScreenState();
}

class _MedicinesScreenState
    extends State<MedicinesScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      final provider =
          context.read<MedicineProvider>();

      if (!provider.hasMedicines) {
        provider.loadInitialData();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider =
        context.watch<MedicineProvider>();

    return Scaffold(
      backgroundColor:
          const Color(0xFFF8FAFC),

      appBar: AppBar(
        title: const Text(
          'Medicine Information',
        ),
        centerTitle: false,
        backgroundColor:
            const Color(0xFFF8FAFC),
        elevation: 0,
      ),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () {
            return provider.loadInitialData();
          },
          child: ListView(
            padding:
                const EdgeInsets.fromLTRB(
              20,
              8,
              20,
              32,
            ),
            children: [
              _SearchField(
                controller:
                    _searchController,
                onChanged:
                    provider.setSearchQuery,
                onClear: () {
                  _searchController.clear();
                  provider.setSearchQuery('');
                  setState(() {});
                },
              ),

              const SizedBox(height: 22),

              _SectionTitle(
                title: 'Categories',
              ),

              const SizedBox(height: 12),

              _CategoryList(
                provider: provider,
              ),

              const SizedBox(height: 26),

              if (provider.searchQuery
                  .isEmpty &&
                  provider.selectedCategory ==
                      null) ...[
                if (provider
                    .featuredMedicines
                    .isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Featured Medicines',
                  ),
                  const SizedBox(height: 12),
                  _HorizontalMedicineList(
                    medicines:
                        provider
                            .featuredMedicines,
                    provider: provider,
                  ),
                  const SizedBox(height: 28),
                ],

                if (provider
                    .popularMedicines
                    .isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Popular Medicines',
                  ),
                  const SizedBox(height: 12),
                  _HorizontalMedicineList(
                    medicines:
                        provider
                            .popularMedicines,
                    provider: provider,
                  ),
                  const SizedBox(height: 28),
                ],

                if (provider
                    .recentlyViewed
                    .isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Recently Viewed',
                  ),
                  const SizedBox(height: 12),
                  _HorizontalMedicineList(
                    medicines:
                        provider
                            .recentlyViewed,
                    provider: provider,
                  ),
                  const SizedBox(height: 28),
                ],

                if (provider
                    .savedMedicines
                    .isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Saved Medicines',
                  ),
                  const SizedBox(height: 12),
                  _HorizontalMedicineList(
                    medicines:
                        provider
                            .savedMedicines,
                    provider: provider,
                  ),
                  const SizedBox(height: 28),
                ],
              ],

              _SectionHeader(
                title: provider.searchQuery
                            .isNotEmpty ||
                        provider
                                .selectedCategory !=
                            null
                    ? 'Search Results'
                    : 'All Medicines',
              ),

              const SizedBox(height: 12),

              if (provider.loading)
                const _MedicineListSkeleton()
              else if (provider.error != null &&
                  provider.medicines.isEmpty)
                _ErrorView(
                  message: provider.error!,
                  onRetry:
                      provider.loadInitialData,
                )
              else if (provider
                  .filteredMedicines
                  .isEmpty)
                const _EmptyMedicineView()
              else
                ...provider.filteredMedicines
                    .map(
                      (medicine) =>
                          Padding(
                        padding:
                            const EdgeInsets.only(
                          bottom: 12,
                        ),
                        child:
                            MedicineCard(
                          medicine:
                              medicine,
                          onTap: () =>
                              _openMedicine(
                            medicine,
                          ),
                          isSaved:
                              provider.savedMedicines
                                  .any(
                            (item) =>
                                item.id ==
                                medicine.id,
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void _openMedicine(
    MedicineModel medicine,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            MedicineDetailScreen(
          medicineId: medicine.id,
        ),
      ),
    );
  }
}

// ============================================================
// SEARCH
// ============================================================

class _SearchField extends StatefulWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  State<_SearchField> createState() =>
      _SearchFieldState();
}

class _SearchFieldState
    extends State<_SearchField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_listener);
  }

  void _listener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      onChanged: widget.onChanged,
      textInputAction:
          TextInputAction.search,
      decoration: InputDecoration(
        hintText:
            'Search medicine, generic name...',
        prefixIcon: const Icon(
          Icons.search,
        ),
        suffixIcon:
            widget.controller.text.isNotEmpty
                ? IconButton(
                    onPressed: widget.onClear,
                    icon: const Icon(
                      Icons.clear,
                    ),
                  )
                : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFE4E7EC),
          ),
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFE4E7EC),
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFF1976D2),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// CATEGORIES
// ============================================================

class _CategoryList extends StatelessWidget {
  const _CategoryList({
    required this.provider,
  });

  final MedicineProvider provider;

  @override
  Widget build(BuildContext context) {
    final categories = <String>[
      'All',
      ...provider.medicines
          .map(
            (medicine) =>
                medicine.category,
          )
          .where(
            (category) =>
                category.trim().isNotEmpty,
          )
          .toSet(),
    ];

    if (provider.categoriesLoading &&
        categories.length == 1) {
      return const SizedBox(
        height: 44,
        child: _CategorySkeleton(),
      );
    }

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection:
            Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category =
              categories[index];

          final isSelected =
              category == 'All'
                  ? provider
                          .selectedCategory ==
                      null
                  : provider
                          .selectedCategory ==
                      category;

          return InkWell(
            onTap: () {
              provider.setCategory(
                category,
              );
            },
            borderRadius:
                BorderRadius.circular(24),
            child: AnimatedContainer(
              duration: const Duration(
                milliseconds: 180,
              ),
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 11,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(
                        0xFF1976D2,
                      )
                    : Colors.white,
                borderRadius:
                    BorderRadius.circular(
                  24,
                ),
                border: Border.all(
                  color: isSelected
                      ? const Color(
                          0xFF1976D2,
                        )
                      : const Color(
                          0xFFE4E7EC,
                        ),
                ),
              ),
              child: Text(
                category,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : const Color(
                          0xFF344054,
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// HORIZONTAL LIST
// ============================================================

class _HorizontalMedicineList
    extends StatelessWidget {
  const _HorizontalMedicineList({
    required this.medicines,
    required this.provider,
  });

  final List<MedicineModel> medicines;
  final MedicineProvider provider;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 172,
      child: ListView.separated(
        scrollDirection:
            Axis.horizontal,
        itemCount:
            medicines.length > 10
                ? 10
                : medicines.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final medicine =
              medicines[index];

          return SizedBox(
            width: 290,
            child: MedicineCard(
              medicine: medicine,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        MedicineDetailScreen(
                      medicineId:
                          medicine.id,
                    ),
                  ),
                );
              },
              isSaved:
                  provider.savedMedicines.any(
                (item) =>
                    item.id ==
                    medicine.id,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// SECTION HEADER
// ============================================================

class _SectionHeader
    extends StatelessWidget {
  const _SectionHeader({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleLarge
          ?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

class _SectionTitle
    extends StatelessWidget {
  const _SectionTitle({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

// ============================================================
// EMPTY
// ============================================================

class _EmptyMedicineView
    extends StatelessWidget {
  const _EmptyMedicineView();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        vertical: 50,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE4E7EC),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.medication_outlined,
            size: 56,
            color: Color(0xFF98A2B3),
          ),
          SizedBox(height: 14),
          Text(
            'No medicines found',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Try a different medicine name or category.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF667085),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ERROR
// ============================================================

class _ErrorView
    extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE4E7EC),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: Color(0xFFD32F2F),
          ),
          const SizedBox(height: 12),
          const Text(
            'Unable to load medicines',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            maxLines: 3,
            overflow:
                TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF667085),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(
              Icons.refresh,
            ),
            label: const Text(
              'Try again',
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SKELETON
// ============================================================

class _MedicineListSkeleton
    extends StatelessWidget {
  const _MedicineListSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        5,
        (_) => const Padding(
          padding:
              EdgeInsets.only(bottom: 12),
          child: _MedicineSkeletonCard(),
        ),
      ),
    );
  }
}

class _MedicineSkeletonCard
    extends StatelessWidget {
  const _MedicineSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE4E7EC),
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          _SkeletonBox(
            width: 76,
            height: 76,
            radius: 16,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: const [
                _SkeletonBox(
                  width: 180,
                  height: 16,
                ),
                SizedBox(height: 10),
                _SkeletonBox(
                  width: 120,
                  height: 12,
                ),
                SizedBox(height: 12),
                _SkeletonBox(
                  width: double.infinity,
                  height: 12,
                ),
                SizedBox(height: 7),
                _SkeletonBox(
                  width: 180,
                  height: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategorySkeleton
    extends StatelessWidget {
  const _CategorySkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _SkeletonBox(
          width: 60,
          height: 42,
          radius: 22,
        ),
        SizedBox(width: 8),
        _SkeletonBox(
          width: 110,
          height: 42,
          radius: 22,
        ),
        SizedBox(width: 8),
        _SkeletonBox(
          width: 100,
          height: 42,
          radius: 22,
        ),
      ],
    );
  }
}

class _SkeletonBox
    extends StatelessWidget {
  const _SkeletonBox({
    required this.width,
    required this.height,
    this.radius = 8,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE9EEF5),
        borderRadius:
            BorderRadius.circular(radius),
      ),
    );
  }
}