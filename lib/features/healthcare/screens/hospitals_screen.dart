import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/healthcare_facility_model.dart';
import '../providers/healthcare_facility_provider.dart';
import '../widgets/healthcare_facility_card.dart';
import 'hospital_detail_screen.dart';

class HospitalsScreen
    extends StatefulWidget {
  const HospitalsScreen({
    super.key,
  });

  @override
  State<HospitalsScreen>
      createState() =>
          _HospitalsScreenState();
}

class _HospitalsScreenState
    extends State<HospitalsScreen> {
  final TextEditingController
      _searchController =
      TextEditingController();

  Timer? _searchTimer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback(
      (_) {
        context
            .read<
                HealthcareFacilityProvider>()
            .loadFacilities();
      },
    );
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(
    String value,
  ) {
    _searchTimer?.cancel();

    _searchTimer =
        Timer(
      const Duration(
        milliseconds: 300,
      ),
      () {
        if (!mounted) {
          return;
        }

        context
            .read<
                HealthcareFacilityProvider>()
            .setSearchQuery(
              value,
            );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider =
        context.watch<
            HealthcareFacilityProvider>();

    return Scaffold(
      backgroundColor:
          const Color(0xFFF8FAFC),

      appBar: AppBar(
        title: const Text(
          'Hospitals & Clinics',
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: provider.loading
                ? null
                : () {
                    provider
                        .loadFacilities();
                  },
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          _buildSearch(),

          _buildCategories(
            provider,
          ),

          Expanded(
            child: _buildContent(
              provider,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        20,
        14,
        20,
        12,
      ),
      child: TextField(
        controller:
            _searchController,
        onChanged:
            _onSearchChanged,
        decoration:
            InputDecoration(
          hintText:
              'Search hospitals, clinics...',
          prefixIcon:
              const Icon(
            Icons.search_rounded,
          ),
          suffixIcon:
              _searchController
                      .text
                      .isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _searchController
                            .clear();

                        context
                            .read<
                                HealthcareFacilityProvider>()
                            .setSearchQuery(
                              '',
                            );

                        setState(() {});
                      },
                      icon:
                          const Icon(
                        Icons
                            .close_rounded,
                      ),
                    ),
          filled: true,
          fillColor: Colors.white,
          border:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              14,
            ),
            borderSide:
                const BorderSide(
              color:
                  Color(0xFFEAECF0),
            ),
          ),
          enabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              14,
            ),
            borderSide:
                const BorderSide(
              color:
                  Color(0xFFEAECF0),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategories(
    HealthcareFacilityProvider
        provider,
  ) {
    final categories = [
      (
        'All',
        null,
      ),
      (
        'Hospitals',
        HealthcareFacilityType
            .hospital,
      ),
      (
        'Clinics',
        HealthcareFacilityType
            .clinic,
      ),
      (
        'Diagnostics',
        HealthcareFacilityType
            .diagnosticCenter,
      ),
      (
        'Pharmacy',
        HealthcareFacilityType
            .pharmacy,
      ),
    ];

    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        scrollDirection:
            Axis.horizontal,
        itemCount:
            categories.length,
        separatorBuilder:
            (_, _) =>
                const SizedBox(
          width: 8,
        ),
        itemBuilder:
            (context, index) {
          final category =
              categories[index];

          final selected =
              provider.selectedType ==
                  category.$2;

          return ChoiceChip(
            label: Text(
              category.$1,
            ),
            selected: selected,
            onSelected: (_) {
              provider.setType(
                category.$2,
              );
            },
            selectedColor:
                const Color(
              0xFF1976D2,
            ),
            backgroundColor:
                Colors.white,
            labelStyle:
                TextStyle(
              color: selected
                  ? Colors.white
                  : const Color(
                      0xFF475467,
                    ),
              fontWeight:
                  FontWeight.w600,
            ),
            side: BorderSide(
              color: selected
                  ? const Color(
                      0xFF1976D2,
                    )
                  : const Color(
                      0xFFEAECF0,
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(
    HealthcareFacilityProvider
        provider,
  ) {
    if (provider.loading) {
      return const _FacilitySkeletonList();
    }

    if (provider.error != null) {
      return _ErrorState(
        onRetry:
            provider.loadFacilities,
      );
    }

    final facilities =
        provider.filteredFacilities;

    if (facilities.isEmpty) {
      return const _EmptyState();
    }

    return RefreshIndicator(
      onRefresh:
          provider.loadFacilities,
      child: ListView(
        padding:
            const EdgeInsets.fromLTRB(
          20,
          18,
          20,
          30,
        ),
        children: [
          if (provider.searchQuery
                  .isEmpty &&
              provider.selectedType ==
                  null)
            ...[
              _buildEmergencySection(
                provider,
              ),
              const SizedBox(
                height: 24,
              ),
            ],

          Text(
            provider.searchQuery.isEmpty
                ? 'Healthcare Near You'
                : 'Search Results',
            style:
                const TextStyle(
              fontSize: 19,
              fontWeight:
                  FontWeight.w800,
              color:
                  Color(0xFF172B4D),
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          ...facilities.map(
            (facility) =>
                Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 12,
              ),
              child:
                  HealthcareFacilityCard(
                facility:
                    facility,
                onTap: () {
                  _openFacility(
                    facility,
                  );
                },
                onCall:
                    facility.phone.isEmpty
                        ? null
                        : () {
                            _call(
                              facility
                                  .phone,
                            );
                          },
                onDirections: () {
                  _openDirections(
                    facility,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencySection(
    HealthcareFacilityProvider
        provider,
  ) {
    final emergency =
        provider.emergencyFacilities
            .take(3)
            .toList();

    if (emergency.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Emergency Hospitals',
                style:
                    TextStyle(
                  fontSize: 19,
                  fontWeight:
                      FontWeight.w800,
                  color:
                      Color(0xFF172B4D),
                ),
              ),
            ),

            TextButton(
              onPressed: () {
                provider
                    .setEmergencyOnly(
                  true,
                );
              },
              child:
                  const Text(
                'See all',
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 4,
        ),

        const Text(
          'Hospitals offering emergency care.',
          style:
              TextStyle(
            fontSize: 12,
            color:
                Color(0xFF667085),
          ),
        ),

        const SizedBox(
          height: 12,
        ),

        ...emergency.map(
          (facility) =>
              Padding(
            padding:
                const EdgeInsets.only(
              bottom: 10,
            ),
            child:
                HealthcareFacilityCard(
              facility:
                  facility,
              onTap: () {
                _openFacility(
                  facility,
                );
              },
              onCall:
                  facility.phone.isEmpty
                      ? null
                      : () {
                          _call(
                            facility
                                .phone,
                          );
                        },
              onDirections: () {
                _openDirections(
                  facility,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _openFacility(
    HealthcareFacilityModel
        facility,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            HospitalDetailScreen(
          facility:
              facility,
        ),
      ),
    );
  }

  Future<void> _call(
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
    HealthcareFacilityModel
        facility,
  ) async {
    // Connect this to your existing
    // MapLauncherService.
  }
}
class _FacilitySkeletonList
    extends StatelessWidget {
  const _FacilitySkeletonList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding:
          const EdgeInsets.fromLTRB(
        20,
        18,
        20,
        30,
      ),
      itemCount: 5,
      separatorBuilder:
          (_, _) =>
              const SizedBox(
        height: 12,
      ),
      itemBuilder:
          (_, _) =>
              const _FacilitySkeletonCard(),
    );
  }
}

class _FacilitySkeletonCard
    extends StatelessWidget {
  const _FacilitySkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color:
              const Color(0xFFEAECF0),
        ),
      ),
      padding:
          const EdgeInsets.all(15),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFF2F4F7,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Container(
                      height: 15,
                      width: 170,
                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFFF2F4F7,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          5,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 9,
                    ),
                    Container(
                      height: 12,
                      width: 100,
                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFFF2F4F7,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 18,
          ),

          Container(
            height: 12,
            width: double.infinity,
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFF2F4F7,
              ),
              borderRadius:
                  BorderRadius.circular(
                5,
              ),
            ),
          ),

          const Spacer(),

          Row(
            children: [
              Expanded(
                child: Container(
                  height: 34,
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFFF2F4F7,
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(
                      9,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: Container(
                  height: 34,
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFFF2F4F7,
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(
                      9,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
class _EmptyState
    extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding:
            EdgeInsets.all(30),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Icon(
              Icons
                  .local_hospital_outlined,
              size: 52,
              color:
                  Color(0xFF98A2B3),
            ),
            SizedBox(height: 12),
            Text(
              'No healthcare facilities found',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.w800,
                color:
                    Color(0xFF172B4D),
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Try another search or category.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color:
                    Color(0xFF667085),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _ErrorState
    extends StatelessWidget {
  const _ErrorState({
    required this.onRetry,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          const Icon(
            Icons
                .cloud_off_outlined,
            size: 48,
            color:
                Color(0xFF98A2B3),
          ),
          const SizedBox(
            height: 12,
          ),
          const Text(
            'Unable to load healthcare facilities.',
            textAlign:
                TextAlign.center,
          ),
          const SizedBox(
            height: 12,
          ),
          ElevatedButton(
            onPressed: onRetry,
            child:
                const Text('Retry'),
          ),
        ],
      ),
    );
  }
}