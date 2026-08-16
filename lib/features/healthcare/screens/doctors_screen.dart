import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/doctor_provider.dart';
import '../widgets/doctor_card.dart';
import '../widgets/doctor_skeleton.dart';
import '../widgets/speciality_card.dart';
import 'doctor_detail_screen.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({
    super.key,
  });

  @override
  State<DoctorsScreen> createState() =>
      _DoctorsScreenState();
}

class _DoctorsScreenState
    extends State<DoctorsScreen> {
  final TextEditingController
      _searchController =
      TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _callDoctor(
    String phone,
  ) async {
    if (phone.isEmpty) {
      return;
    }

    final uri = Uri.parse(
      'tel:$phone',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider =
        context.watch<DoctorProvider>();

    return Scaffold(
      backgroundColor:
          const Color(0xFFF8FAFC),

      appBar: AppBar(
        title: const Text(
          'Find a Doctor',
        ),
        centerTitle: true,
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          // Firestore stream is already live.
          // Small delay gives RefreshIndicator
          // natural feedback.
          await Future.delayed(
            const Duration(
              milliseconds: 400,
            ),
          );
        },
        child: CustomScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(
                  20,
                  18,
                  20,
                  0,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Find the right doctor',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight:
                            FontWeight.w800,
                        color:
                            Color(0xFF172B4D),
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      'Search doctors and healthcare specialists near you.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color:
                            Color(0xFF667085),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller:
                          _searchController,
                      onChanged:
                          provider
                              .setSearchQuery,
                      decoration:
                          InputDecoration(
                        hintText:
                            'Search doctor, speciality or clinic',
                        prefixIcon:
                            const Icon(
                          Icons.search_rounded,
                        ),
                        suffixIcon:
                            provider.searchQuery
                                    .isNotEmpty
                                ? IconButton(
                                    onPressed: () {
                                      _searchController
                                          .clear();

                                      provider
                                          .setSearchQuery(
                                        '',
                                      );
                                    },
                                    icon:
                                        const Icon(
                                      Icons.clear,
                                    ),
                                  )
                                : null,
                        filled: true,
                        fillColor:
                            Colors.white,
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

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Specialities',
                            style:
                                TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.w800,
                              color:
                                  Color(
                                0xFF172B4D,
                              ),
                            ),
                          ),
                        ),
                        if (provider
                            .selectedSpecialityId !=
                            null)
                          TextButton(
                            onPressed:
                                provider
                                    .clearFilters,
                            child:
                                const Text(
                              'Clear',
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 9),

                    SizedBox(
                      height: 44,
                      child: ListView.separated(
                        scrollDirection:
                            Axis.horizontal,
                        itemCount:
                            provider
                                    .specialities
                                    .length +
                                1,
                        separatorBuilder:
                            (_, _) =>
                                const SizedBox(
                              width: 8,
                            ),
                        itemBuilder:
                            (context, index) {
                          if (index == 0) {
                            return _AllSpecialityChip(
                              selected:
                                  provider
                                          .selectedSpecialityId ==
                                      null,
                              onTap: () {
                                provider
                                    .selectSpeciality(
                                  null,
                                );
                              },
                            );
                          }

                          final speciality =
                              provider
                                  .specialities[
                                      index - 1];

                          return SpecialityCard(
                            speciality:
                                speciality,
                            selected: provider
                                    .selectedSpecialityId ==
                                speciality.id,
                            onTap: () {
                              provider
                                  .selectSpeciality(
                                speciality.id,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (provider.loading)
              SliverPadding(
                padding:
                    const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  30,
                ),
                sliver:
                    SliverList.separated(
                  itemCount: 4,
                  separatorBuilder:
                      (_, _) =>
                          const SizedBox(
                    height: 12,
                  ),
                  itemBuilder:
                      (_, _) =>
                          const DoctorSkeleton(),
                ),
              )
            else if (provider.error != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _ErrorState(
                  message:
                      provider.error!,
                  onRetry: () {
                    // Provider stream will normally
                    // reconnect automatically.
                    setState(() {});
                  },
                ),
              )
            else
              _buildDoctors(
                context,
                provider,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctors(
    BuildContext context,
    DoctorProvider provider,
  ) {
    final featured =
        provider.featuredDoctors;

    final doctors =
        provider.filteredDoctors;

    return SliverPadding(
      padding:
          const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        30,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate(
          [
            if (provider
                    .searchQuery
                    .trim()
                    .isEmpty &&
                provider
                        .selectedSpecialityId ==
                    null &&
                featured.isNotEmpty) ...[
              const Text(
                'Featured Doctors',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight:
                      FontWeight.w800,
                  color:
                      Color(0xFF172B4D),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                height: 190,
                child: ListView.separated(
                  scrollDirection:
                      Axis.horizontal,
                  itemCount:
                      featured.length,
                  separatorBuilder:
                      (_, _) =>
                          const SizedBox(
                    width: 12,
                  ),
                  itemBuilder:
                      (context, index) {
                    final doctor =
                        featured[index];

                    return SizedBox(
                      width: 310,
                      child: DoctorCard(
                        doctor: doctor,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DoctorDetailScreen(
                                doctor:
                                    doctor,
                              ),
                            ),
                          );
                        },
                        onCall: () =>
                            _callDoctor(
                          doctor.phone,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),
            ],

            Row(
              children: [
                Expanded(
                  child: Text(
                    provider
                            .searchQuery
                            .trim()
                            .isNotEmpty ||
                        provider
                                .selectedSpecialityId !=
                            null
                        ? 'Search Results'
                        : 'All Doctors',
                    style:
                        const TextStyle(
                      fontSize: 19,
                      fontWeight:
                          FontWeight.w800,
                      color:
                          Color(0xFF172B4D),
                    ),
                  ),
                ),
                Text(
                  '${doctors.length}',
                  style:
                      const TextStyle(
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        Color(0xFF667085),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (doctors.isEmpty)
              const _EmptyDoctors()
            else
              ...doctors.map(
                (doctor) {
                  return Padding(
                    padding:
                        const EdgeInsets.only(
                      bottom: 12,
                    ),
                    child: DoctorCard(
                      doctor: doctor,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                DoctorDetailScreen(
                              doctor: doctor,
                            ),
                          ),
                        );
                      },
                      onCall: () =>
                          _callDoctor(
                        doctor.phone,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _AllSpecialityChip
    extends StatelessWidget {
  const _AllSpecialityChip({
    required this.selected,
    required this.onTap,
  });

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? const Color(0xFF1976D2)
          : Colors.white,
      borderRadius:
          BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(14),
        child: Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? const Color(0xFF1976D2)
                  : const Color(0xFFEAECF0),
            ),
          ),
          child: Text(
            'All',
            style: TextStyle(
              fontSize: 13,
              fontWeight:
                  FontWeight.w700,
              color: selected
                  ? Colors.white
                  : const Color(0xFF344054),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyDoctors
    extends StatelessWidget {
  const _EmptyDoctors();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFEAECF0),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.person_search_outlined,
            size: 48,
            color: Color(0xFF98A2B3),
          ),
          SizedBox(height: 12),
          Text(
            'No doctors found',
            style: TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.w800,
              color:
                  Color(0xFF172B4D),
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Try another search or speciality.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color:
                  Color(0xFF667085),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState
    extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(30),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 48,
              color:
                  Color(0xFF98A2B3),
            ),
            const SizedBox(height: 12),
            const Text(
              'Unable to load doctors',
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.w800,
                color:
                    Color(0xFF172B4D),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              maxLines: 3,
              overflow:
                  TextOverflow.ellipsis,
              textAlign:
                  TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color:
                    Color(0xFF667085),
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: onRetry,
              child:
                  const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}