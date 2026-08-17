import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/medical_equipment_model.dart';
import '../providers/medical_equipment_provider.dart';
import '../widgets/medical_equipment_card.dart';
import 'medical_equipment_detail_screen.dart';

class MedicalEquipmentScreen extends StatefulWidget {
  const MedicalEquipmentScreen({
    super.key,
  });

  @override
  State<MedicalEquipmentScreen> createState() =>
      _MedicalEquipmentScreenState();
}

class _MedicalEquipmentScreenState
    extends State<MedicalEquipmentScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          context.read<MedicalEquipmentProvider>();

      if (!provider.hasEquipment) {
        provider.loadEquipment();
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
        context.watch<MedicalEquipmentProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        title: const Text(
          'Medical Equipment',
        ),
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
      ),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: provider.loadEquipment,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              20,
              8,
              20,
              32,
            ),
            children: [
              _SearchField(
                controller: _searchController,
                onChanged: provider.setSearchQuery,
                onClear: () {
                  _searchController.clear();
                  provider.setSearchQuery('');
                },
              ),

              const SizedBox(height: 22),

              const Text(
                'Categories',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF172B4D),
                ),
              ),

              const SizedBox(height: 12),

              _CategoryList(
                provider: provider,
              ),

              const SizedBox(height: 24),

              if (provider.loading)
                const _EquipmentListSkeleton()
              else if (provider.error != null &&
                  provider.equipment.isEmpty)
                _ErrorView(
                  message: provider.error!,
                  onRetry: provider.loadEquipment,
                )
              else if (provider.filteredEquipment.isEmpty)
                const _EmptyEquipmentView()
              else ...[
                if (provider.searchQuery.isEmpty &&
                    provider.selectedCategory == null &&
                    provider.featuredEquipment.isNotEmpty) ...[
                  const Text(
                    'Featured Equipment',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF172B4D),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    height: 170,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount:
                          provider.featuredEquipment.length > 10
                              ? 10
                              : provider.featuredEquipment.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final equipment =
                            provider.featuredEquipment[index];

                        return SizedBox(
                          width: 310,
                          child: MedicalEquipmentCard(
                            equipment: equipment,
                            onTap: () {
                              _openEquipment(
                                equipment,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 28),
                ],

                Text(
                  provider.searchQuery.isNotEmpty ||
                          provider.selectedCategory != null
                      ? 'Search Results'
                      : 'All Medical Equipment',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF172B4D),
                  ),
                ),

                const SizedBox(height: 12),

                ...provider.filteredEquipment.map(
                  (equipment) => Padding(
                    padding:
                        const EdgeInsets.only(bottom: 12),
                    child: MedicalEquipmentCard(
                      equipment: equipment,
                      onTap: () {
                        _openEquipment(equipment);
                      },
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _openEquipment(
    MedicalEquipmentModel equipment,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            MedicalEquipmentDetailScreen(
          equipmentId: equipment.id,
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
    widget.controller.addListener(_onChanged);
  }

  void _onChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        hintText:
            'Search equipment, device, brand...',
        prefixIcon: const Icon(
          Icons.search,
        ),
        suffixIcon: widget.controller.text.isNotEmpty
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
        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFE4E7EC),
          ),
        ),
        focusedBorder: OutlineInputBorder(
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
// CATEGORY LIST
// ============================================================

class _CategoryList extends StatelessWidget {
  const _CategoryList({
    required this.provider,
  });

  final MedicalEquipmentProvider provider;

  @override
  Widget build(BuildContext context) {
    final categories = <String>[
      'All',
      ...provider.categories.map((c) => c.name),
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];

          final selected =
              category == 'All'
                  ? provider.selectedCategory == null
                  : provider.selectedCategory ==
                      category;

          return InkWell(
            onTap: () {
              provider.setCategory(category);
            },
            borderRadius:
                BorderRadius.circular(24),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 11,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF1976D2)
                    : Colors.white,
                borderRadius:
                    BorderRadius.circular(24),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF1976D2)
                      : const Color(0xFFE4E7EC),
                ),
              ),
              child: Text(
                category,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? Colors.white
                      : const Color(0xFF344054),
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
// EMPTY
// ============================================================

class _EmptyEquipmentView
    extends StatelessWidget {
  const _EmptyEquipmentView();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 55,
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
            Icons.medical_services_outlined,
            size: 56,
            color: Color(0xFF98A2B3),
          ),
          SizedBox(height: 14),
          Text(
            'No equipment found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 7),
          Text(
            'Try another search or category.',
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

class _ErrorView extends StatelessWidget {
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
            size: 50,
            color: Color(0xFFD32F2F),
          ),
          const SizedBox(height: 12),
          const Text(
            'Unable to load equipment',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
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

class _EquipmentListSkeleton
    extends StatelessWidget {
  const _EquipmentListSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        5,
        (_) => const Padding(
          padding:
              EdgeInsets.only(bottom: 12),
          child: _EquipmentSkeletonCard(),
        ),
      ),
    );
  }
}

class _EquipmentSkeletonCard
    extends StatelessWidget {
  const _EquipmentSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 145,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE4E7EC),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: const Color(0xFFE9EEF5),
              borderRadius:
                  BorderRadius.circular(16),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: const [
                _SkeletonLine(
                  width: 180,
                  height: 16,
                ),
                SizedBox(height: 10),
                _SkeletonLine(
                  width: 110,
                  height: 12,
                ),
                SizedBox(height: 10),
                _SkeletonLine(
                  width: double.infinity,
                  height: 12,
                ),
                SizedBox(height: 7),
                _SkeletonLine(
                  width: 160,
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

class _SkeletonLine
    extends StatelessWidget {
  const _SkeletonLine({
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE9EEF5),
        borderRadius:
            BorderRadius.circular(8),
      ),
    );
  }
}