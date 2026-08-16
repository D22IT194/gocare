import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/healthcare_facility_model.dart';
// import 'appointment_detail_screen.dart';
import 'hospital_doctors_screen.dart';

class HospitalDetailScreen extends StatelessWidget {
  const HospitalDetailScreen({super.key, required this.facility});

  final HealthcareFacilityModel facility;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        title: Text(facility.typeLabel),
        actions: [
          IconButton(
            tooltip: 'Save',
            onPressed: () {
              // Save implementation
              // will be added in Phase 2D.
            },
            icon: const Icon(Icons.bookmark_border_rounded),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHero(),

            const SizedBox(height: 20),

            _buildIdentity(),

            const SizedBox(height: 18),

            _buildActions(),

            const SizedBox(height: 18),

            if (facility.isEmergencyAvailable) _buildEmergencyCard(),

            const SizedBox(height: 22),

            _buildAbout(),

            const SizedBox(height: 24),

            _buildSpecialities(),

            const SizedBox(height: 24),

            _buildServices(),

            const SizedBox(height: 24),

            _buildDoctorsSection(context),

            const SizedBox(height: 24),

            _buildReviewsSection(),

            const SizedBox(height: 24),

            _buildDisclaimer(),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4FF),
        borderRadius: BorderRadius.circular(22),
      ),
      child: facility.imageUrl.isEmpty
          ? const Icon(
              Icons.local_hospital_outlined,
              size: 80,
              color: Color(0xFF1976D2),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.network(
                facility.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.local_hospital_outlined,
                  size: 80,
                  color: Color(0xFF1976D2),
                ),
              ),
            ),
    );
  }

  Widget _buildIdentity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                facility.name,
                style: const TextStyle(
                  fontSize: 25,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF172B4D),
                ),
              ),
            ),

            if (facility.isVerified)
              const Padding(
                padding: EdgeInsets.only(left: 8, top: 3),
                child: Icon(
                  Icons.verified_rounded,
                  color: Color(0xFF1976D2),
                  size: 23,
                ),
              ),
          ],
        ),

        const SizedBox(height: 8),

        Text(
          facility.typeLabel,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1976D2),
          ),
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            const Icon(Icons.star_rounded, size: 20, color: Color(0xFFF79009)),
            const SizedBox(width: 4),
            Text(
              facility.rating.toStringAsFixed(1),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
            const SizedBox(width: 5),
            Text(
              '${facility.reviewCount} reviews',
              style: const TextStyle(fontSize: 13, color: Color(0xFF667085)),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 19,
              color: Color(0xFF667085),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                facility.address,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: Color(0xFF667085),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: facility.phone.isEmpty ? null : _call,
            icon: const Icon(Icons.phone_outlined, size: 18),
            label: const Text('Call'),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: OutlinedButton.icon(
            onPressed: _openDirections,
            icon: const Icon(Icons.directions_outlined, size: 18),
            label: const Text('Directions'),
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xFFFEE4E2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emergency_outlined,
              color: Color(0xFFD92D20),
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Emergency care available',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF912018),
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'This facility provides emergency services.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF7A271A)),
                ),
              ],
            ),
          ),

          if (facility.isOpen24Hours)
            const Text(
              '24/7',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFFD92D20),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAbout() {
    return _Section(
      title: 'About',
      child: Text(
        facility.description.isEmpty
            ? 'Information about this healthcare facility is currently unavailable.'
            : facility.description,
        style: const TextStyle(
          fontSize: 14,
          height: 1.6,
          color: Color(0xFF475467),
        ),
      ),
    );
  }

  Widget _buildSpecialities() {
    if (facility.specialities.isEmpty) {
      return const SizedBox();
    }

    return _Section(
      title: 'Specialities',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: facility.specialities
            .map(
              (speciality) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  speciality,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF175CD3),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildServices() {
    return _Section(
      title: 'Services',
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.medical_services_outlined,
            title: 'Medical Specialists',
            value: '${facility.doctorCount} doctors',
          ),
          const Divider(height: 20),
          _InfoRow(
            icon: Icons.emergency_outlined,
            title: 'Emergency Care',
            value: facility.isEmergencyAvailable
                ? 'Available'
                : 'Not available',
          ),
          const Divider(height: 20),
          _InfoRow(
            icon: Icons.access_time_rounded,
            title: 'Availability',
            value: facility.isOpen24Hours
                ? 'Open 24 hours'
                : 'Check facility hours',
          ),
          const Divider(height: 20),
          _InfoRow(
            icon: Icons.calendar_month_outlined,
            title: 'Appointments',
            value: facility.appointmentEnabled
                ? 'Available'
                : 'Contact facility',
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorsSection(BuildContext context) {
    return _Section(
      title: 'Doctors',
      trailing: facility.doctorCount > 0
          ? TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HospitalDoctorsScreen(facility: facility),
                  ),
                );
              },
              child: const Text('See all'),
            )
          : null,
      child: facility.doctorCount == 0
          ? const Text(
              'No doctors are currently listed.',
              style: TextStyle(fontSize: 13, color: Color(0xFF667085)),
            )
          : Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFEAECF0)),
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
                    child: const Icon(
                      Icons.medical_services_outlined,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${facility.doctorCount} doctors available',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF172B4D),
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF98A2B3),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildReviewsSection() {
    return _Section(
      title: 'Patient Reviews',
      trailing: facility.reviewCount > 0
          ? TextButton(
              onPressed: () {
                // Reviews screen
                // will be added later.
              },
              child: const Text('See all'),
            )
          : null,
      child: facility.reviewCount == 0
          ? const Text(
              'No reviews yet.',
              style: TextStyle(fontSize: 13, color: Color(0xFF667085)),
            )
          : Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFEAECF0)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.format_quote_rounded,
                    color: Color(0xFF98A2B3),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${facility.reviewCount} patients have reviewed this facility.',
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: Color(0xFF475467),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDisclaimer() {
    return const Text(
      'Healthcare facility information may change. Please verify availability, services and timings before visiting.',
      style: TextStyle(fontSize: 11, height: 1.5, color: Color(0xFF98A2B3)),
    );
  }

  Future<void> _call() async {
    final uri = Uri(scheme: 'tel', path: facility.phone);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openDirections() async {
    // Replace this with your existing
    // MapLauncherService implementation.
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF172B4D),
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 21, color: const Color(0xFF1976D2)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 13, color: Color(0xFF667085)),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF172B4D),
          ),
        ),
      ],
    );
  }
}
