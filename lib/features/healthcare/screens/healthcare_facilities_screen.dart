import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/healthcare_facility_filter.dart';
import '../models/healthcare_facility_model.dart';
import '../models/healthcare_facility_result.dart';
import '../providers/healthcare_facility_provider.dart';
import '../widgets/healthcare_facility_card.dart';

class HealthcareFacilitiesScreen extends StatefulWidget {
  const HealthcareFacilitiesScreen({
    super.key,
  });

  @override
  State<HealthcareFacilitiesScreen> createState() =>
      _HealthcareFacilitiesScreenState();
}

class _HealthcareFacilitiesScreenState
    extends State<HealthcareFacilitiesScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final provider =
          context.read<HealthcareFacilityProvider>();

      if (provider.facilities.isEmpty &&
          !provider.loading) {
        provider.loadFacilities();
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
        context.watch<HealthcareFacilityProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        title: const Text(
          'Healthcare Facilities',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF172B4D),
          ),
        ),
        actions: [
          if (provider.hasSavedFacilities)
            Padding(
              padding: const EdgeInsets.only(
                right: 12,
              ),
              child: Center(
                child: Text(
                  '${provider.savedFacilityCount} saved',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF667085),
                  ),
                ),
              ),
            ),
        ],
      ),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await provider.loadFacilities();
          },
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
                  provider.clearSearch();
                  setState(() {});
                },
              ),

              const SizedBox(height: 18),

              _FilterSection(
                provider: provider,
              ),

              const SizedBox(height: 20),

              _LocationSection(
                provider: provider,
              ),

              const SizedBox(height: 20),

              if (provider.loading)
                const _FacilityListSkeleton()
              else if (provider.error != null &&
                  provider.facilities.isEmpty)
                _ErrorView(
                  message: provider.error!,
                  onRetry: provider.loadFacilities,
                )
              else
                _FacilityResults(
                  provider: provider,
                ),
            ],
          ),
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
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText:
            'Search hospital, clinic, pharmacy...',
        prefixIcon: const Icon(
          Icons.search_rounded,
        ),
        suffixIcon:
            widget.controller.text.isNotEmpty
                ? IconButton(
                    onPressed: widget.onClear,
                    icon: const Icon(
                      Icons.clear_rounded,
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
// FILTERS
// ============================================================

class _FilterSection extends StatelessWidget {
  const _FilterSection({
    required this.provider,
  });

  final HealthcareFacilityProvider provider;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Facility Type',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF172B4D),
          ),
        ),

        const SizedBox(height: 10),

        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _TypeChip(
                label: 'All',
                icon: Icons.apps_rounded,
                selected:
                    provider.selectedType == null,
                onTap: () {
                  provider.clearSelectedType();
                },
              ),

              const SizedBox(width: 8),

              _TypeChip(
                label: 'Hospitals',
                icon:
                    Icons.local_hospital_outlined,
                selected:
                    provider.selectedType ==
                        HealthcareFacilityType.hospital,
                onTap: () {
                  provider.setSelectedType(
                    HealthcareFacilityType.hospital,
                  );
                },
              ),

              const SizedBox(width: 8),

              _TypeChip(
                label: 'Clinics',
                icon: Icons.medical_services_outlined,
                selected:
                    provider.selectedType ==
                        HealthcareFacilityType.clinic,
                onTap: () {
                  provider.setSelectedType(
                    HealthcareFacilityType.clinic,
                  );
                },
              ),

              const SizedBox(width: 8),

              _TypeChip(
                label: 'Diagnostic',
                icon: Icons.biotech_outlined,
                selected:
                    provider.selectedType ==
                        HealthcareFacilityType
                            .diagnosticCenter,
                onTap: () {
                  provider.setSelectedType(
                    HealthcareFacilityType
                        .diagnosticCenter,
                  );
                },
              ),

              const SizedBox(width: 8),

              _TypeChip(
                label: 'Pharmacy',
                icon: Icons.medication_outlined,
                selected:
                    provider.selectedType ==
                        HealthcareFacilityType.pharmacy,
                onTap: () {
                  provider.setSelectedType(
                    HealthcareFacilityType.pharmacy,
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        const Text(
          'Quick Filters',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF172B4D),
          ),
        ),

        const SizedBox(height: 10),

        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _FilterChip(
                label: 'All',
                icon: Icons.apps_rounded,
                selected:
                    provider.selectedFilter ==
                        FacilityFilter.all,
                onTap: () {
                  provider.setFilter(
                    FacilityFilter.all,
                  );
                },
              ),

              const SizedBox(width: 8),

              _FilterChip(
                label: 'Nearby',
                icon: Icons.near_me_outlined,
                selected:
                    provider.selectedFilter ==
                        FacilityFilter.nearby,
                onTap: () async {
                  provider.setFilter(
                    FacilityFilter.nearby,
                  );

                  if (!provider.hasLocation) {
                    await provider
                        .loadNearbyFacilities();
                  }
                },
              ),

              const SizedBox(width: 8),

              _FilterChip(
                label: 'Emergency',
                icon: Icons.emergency_outlined,
                selected:
                    provider.selectedFilter ==
                        FacilityFilter.emergency,
                danger: true,
                onTap: () {
                  provider.setFilter(
                    FacilityFilter.emergency,
                  );
                },
              ),

              const SizedBox(width: 8),

              _FilterChip(
                label: 'Saved',
                icon: Icons.bookmark_outline_rounded,
                selected:
                    provider.selectedFilter ==
                        FacilityFilter.saved,
                onTap: () {
                  provider.setFilter(
                    FacilityFilter.saved,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// TYPE CHIP
// ============================================================

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? const Color(0xFF1976D2)
          : Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
          ),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(22),
            border: Border.all(
              color: selected
                  ? const Color(0xFF1976D2)
                  : const Color(0xFFE4E7EC),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 17,
                color: selected
                    ? Colors.white
                    : const Color(0xFF667085),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? Colors.white
                      : const Color(0xFF344054),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// FILTER CHIP
// ============================================================

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.danger = false,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final activeColor = danger
        ? const Color(0xFFD92D20)
        : const Color(0xFF1976D2);

    return Material(
      color: selected
          ? activeColor
          : Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
          ),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(22),
            border: Border.all(
              color: selected
                  ? activeColor
                  : const Color(0xFFE4E7EC),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected
                    ? Colors.white
                    : activeColor,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? Colors.white
                      : const Color(0xFF344054),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// LOCATION
// ============================================================

class _LocationSection extends StatelessWidget {
  const _LocationSection({
    required this.provider,
  });

  final HealthcareFacilityProvider provider;

  @override
  Widget build(BuildContext context) {
    if (provider.locationLoading) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF4FF),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Finding healthcare facilities near you...',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF344054),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (provider.locationError != null) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F0),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.location_off_outlined,
              color: Color(0xFFD92D20),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Unable to access your location.',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed:
                  provider.loadNearbyFacilities,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (provider.hasLocation) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF4FF),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.my_location_rounded,
              color: Color(0xFF1976D2),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Location enabled. Nearby facilities are available.',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF344054),
                ),
              ),
            ),
            IconButton(
              onPressed:
                  provider.loadNearbyFacilities,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
            ),
          ],
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed:
          provider.loadNearbyFacilities,
      icon: const Icon(
        Icons.location_on_outlined,
      ),
      label: const Text(
        'Find facilities near me',
      ),
    );
  }
}

// ============================================================
// RESULTS
// ============================================================

class _FacilityResults extends StatelessWidget {
  const _FacilityResults({
    required this.provider,
  });

  final HealthcareFacilityProvider provider;

  @override
  Widget build(BuildContext context) {
    final facilities =
        provider.visibleFacilities;

    final isNearby =
        provider.selectedFilter ==
            FacilityFilter.nearby;

    if (facilities.isEmpty) {
      return const _EmptyFacilityView();
    }

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _getTitle(provider),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF172B4D),
                ),
              ),
            ),
            Text(
              '${facilities.length}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF667085),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        ...facilities.map(
          (facility) {
            String? distance;

            if (isNearby) {
              final nearby =
                  provider.nearbyFacilities
                      .where(
                        (item) =>
                            item.facility.id ==
                            facility.id,
                      )
                      .firstOrNull;

              distance =
                  nearby?.formattedDistance;
            }

            return Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 12,
              ),
              child: HealthcareFacilityCard(
                facility: facility,
                distance: distance,
                onTap: () {
                  _showFacilityDetails(
                    context,
                    facility,
                  );
                },
                onCall: facility.phone
                        .trim()
                        .isEmpty
                    ? null
                    : () {
                        _callFacility(
                          facility.phone,
                        );
                      },
                onDirections: () {
                  _openDirections(
                    facility.latitude,
                    facility.longitude,
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  String _getTitle(
    HealthcareFacilityProvider provider,
  ) {
    if (provider.searchQuery.isNotEmpty) {
      return 'Search Results';
    }

    switch (provider.selectedFilter) {
      case FacilityFilter.nearby:
        return 'Nearby Facilities';

      case FacilityFilter.emergency:
        return 'Emergency Facilities';

      case FacilityFilter.saved:
        return 'Saved Facilities';

      case FacilityFilter.all:
        return 'Healthcare Facilities';
    }
  }

  void _showFacilityDetails(
    BuildContext context,
    HealthcareFacilityModel facility,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _FacilityDetailsSheet(
          facility: facility,
        );
      },
    );
  }

  Future<void> _callFacility(
    String phone,
  ) async {
    final uri = Uri(
      scheme: 'tel',
      path: phone,
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openDirections(
    double latitude,
    double longitude,
  ) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=$latitude,$longitude',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode:
            LaunchMode.externalApplication,
      );
    }
  }
}

// ============================================================
// DETAILS SHEET
// ============================================================

class _FacilityDetailsSheet
    extends StatelessWidget {
  const _FacilityDetailsSheet({
    required this.facility,
  });

  final HealthcareFacilityModel facility;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          20,
          12,
          20,
          24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFFD0D5DD),
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                facility.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF172B4D),
                ),
              ),

              const SizedBox(height: 6),

              Text(
                facility.typeLabel,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1976D2),
                ),
              ),

              const SizedBox(height: 16),

              if (facility.description
                  .trim()
                  .isNotEmpty)
                Text(
                  facility.description,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Color(0xFF667085),
                  ),
                ),

              const SizedBox(height: 18),

              _DetailRow(
                icon: Icons.location_on_outlined,
                title: 'Address',
                value: facility.address,
              ),

              if (facility.phone
                  .trim()
                  .isNotEmpty)
                _DetailRow(
                  icon: Icons.phone_outlined,
                  title: 'Phone',
                  value: facility.phone,
                ),

              _DetailRow(
                icon: Icons.star_outline_rounded,
                title: 'Rating',
                value:
                    '${facility.rating.toStringAsFixed(1)} (${facility.reviewCount} reviews)',
              ),

              if (facility.specialities.isNotEmpty)
                _DetailRow(
                  icon: Icons.medical_services_outlined,
                  title: 'Specialities',
                  value:
                      facility.specialities.join(', '),
                ),

              _DetailRow(
                icon: Icons.people_outline_rounded,
                title: 'Doctors',
                value:
                    '${facility.doctorCount}',
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed:
                      facility.phone.trim().isEmpty
                          ? null
                          : () async {
                              final uri = Uri(
                                scheme: 'tel',
                                path: facility.phone,
                              );

                              if (await canLaunchUrl(
                                uri,
                              )) {
                                await launchUrl(
                                  uri,
                                );
                              }
                            },
                  icon: const Icon(
                    Icons.phone_outlined,
                  ),
                  label: const Text(
                    'Call Facility',
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 14,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(0xFF1976D2),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF98A2B3),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF344054),
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

// ============================================================
// EMPTY
// ============================================================

class _EmptyFacilityView
    extends StatelessWidget {
  const _EmptyFacilityView();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
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
            Icons.local_hospital_outlined,
            size: 56,
            color: Color(0xFF98A2B3),
          ),
          SizedBox(height: 14),
          Text(
            'No healthcare facilities found',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF172B4D),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Try changing your search or filters.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
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
  final Future<void> Function() onRetry;

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
            Icons.error_outline_rounded,
            size: 48,
            color: Color(0xFFD92D20),
          ),
          const SizedBox(height: 12),
          const Text(
            'Unable to load facilities',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF667085),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(
              Icons.refresh_rounded,
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

class _FacilityListSkeleton
    extends StatelessWidget {
  const _FacilityListSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        5,
        (_) => const Padding(
          padding:
              EdgeInsets.only(bottom: 12),
          child: _FacilitySkeletonCard(),
        ),
      ),
    );
  }
}

class _FacilitySkeletonCard
    extends StatelessWidget {
  const _FacilitySkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      padding: const EdgeInsets.all(15),
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
          Row(
            children: [
              _SkeletonBox(
                width: 64,
                height: 64,
                radius: 16,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _SkeletonBox(
                      width: 180,
                      height: 16,
                    ),
                    SizedBox(height: 9),
                    _SkeletonBox(
                      width: 90,
                      height: 12,
                    ),
                    SizedBox(height: 9),
                    _SkeletonBox(
                      width: 120,
                      height: 12,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _SkeletonBox(
            width: double.infinity,
            height: 12,
          ),
          const SizedBox(height: 8),
          const _SkeletonBox(
            width: double.infinity,
            height: 12,
          ),
          const SizedBox(height: 8),
          const _SkeletonBox(
            width: 180,
            height: 12,
          ),
          const SizedBox(height: 18),
          Row(
            children: const [
              Expanded(
                child: _SkeletonBox(
                  width: double.infinity,
                  height: 38,
                  radius: 10,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _SkeletonBox(
                  width: double.infinity,
                  height: 38,
                  radius: 10,
                ),
              ),
            ],
          ),
        ],
      ),
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