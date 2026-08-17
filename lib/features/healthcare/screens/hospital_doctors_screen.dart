import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/healthcare_facility_model.dart';
import '../providers/doctor_provider.dart';
import '../widgets/doctor_card.dart';
import 'doctor_detail_screen.dart';

class HospitalDoctorsScreen
    extends StatefulWidget {
  const HospitalDoctorsScreen({
    super.key,
    required this.facility,
  });

  final HealthcareFacilityModel facility;

  @override
  State<HospitalDoctorsScreen>
      createState() =>
          _HospitalDoctorsScreenState();
}

class _HospitalDoctorsScreenState
    extends State<HospitalDoctorsScreen> {
  String _search = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      context
          .read<DoctorProvider>()
          .loadDoctorsByFacility(
            widget.facility.id,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider =
        context.watch<DoctorProvider>();

    final doctors =
        provider.facilityDoctors
            .where((doctor) {
      if (_search.isEmpty) {
        return true;
      }

      final query =
          _search.toLowerCase();

      return doctor.name
              .toLowerCase()
              .contains(query) ||
          doctor.specialityName
              .toLowerCase()
              .contains(query);
    }).toList();

    return Scaffold(
      backgroundColor:
          const Color(0xFFF8FAFC),

      appBar: AppBar(
        title: const Text(
          'Doctors',
        ),
      ),

      body: Column(
        children: [
          _buildHeader(),

          _buildSearch(),

          Expanded(
            child: _buildDoctors(
              provider,
              doctors,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      margin:
          const EdgeInsets.fromLTRB(
        20,
        16,
        20,
        12,
      ),
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            const Color(0xFFEAF4FF),
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            Icons
                .local_hospital_outlined,
            color:
                Color(0xFF1976D2),
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  widget.facility.name,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    fontSize: 15,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        Color(0xFF172B4D),
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                const Text(
                  'Doctors working at this facility',
                  style:
                      TextStyle(
                    fontSize: 12,
                    color:
                        Color(0xFF667085),
                  ),
                ),
              ],
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
        0,
        20,
        14,
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _search =
                value.trim();
          });
        },
        decoration:
            InputDecoration(
          hintText:
              'Search doctors or speciality...',
          prefixIcon:
              const Icon(
            Icons.search_rounded,
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

  Widget _buildDoctors(
    DoctorProvider provider,
    List doctors,
  ) {
    if (provider
        .facilityDoctorsLoading) {
      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    if (provider
            .facilityDoctorsError !=
        null) {
      return Center(
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Text(
              'Unable to load doctors.',
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {
                provider
                    .loadDoctorsByFacility(
                  widget.facility.id,
                );
              },
              child:
                  const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (doctors.isEmpty) {
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
                    .medical_services_outlined,
                size: 50,
                color:
                    Color(0xFF98A2B3),
              ),
              SizedBox(
                height: 12,
              ),
              Text(
                'No doctors found',
                style:
                    TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.w800,
                  color:
                      Color(0xFF172B4D),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                'No doctors are currently listed for this facility.',
                textAlign:
                    TextAlign.center,
                style:
                    TextStyle(
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

    return RefreshIndicator(
      onRefresh: () {
        return provider
            .loadDoctorsByFacility(
          widget.facility.id,
        );
      },
      child: ListView.separated(
        padding:
            const EdgeInsets.fromLTRB(
          20,
          4,
          20,
          30,
        ),
        itemCount:
            doctors.length,
        separatorBuilder:
            (_, _) =>
                const SizedBox(
          height: 12,
        ),
        itemBuilder:
            (context, index) {
          final doctor =
              doctors[index];

          return DoctorCard(
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
          );
        },
      ),
    );
  }
}