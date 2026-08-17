import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'book_appointment_screen.dart';
import '../models/doctor_model.dart';

class DoctorDetailScreen extends StatelessWidget {
  const DoctorDetailScreen({super.key, required this.doctor});

  final DoctorModel doctor;

  Future<void> _callDoctor() async {
    if (doctor.phone.trim().isEmpty) {
      return;
    }

    final uri = Uri(scheme: 'tel', path: doctor.phone);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openDirections() async {
    final latitude = doctor.latitude;
    final longitude = doctor.longitude;

    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=$latitude,$longitude',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showAppointmentMessage(BuildContext context) {
    if (!doctor.appointmentEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Online appointment booking is not available for this doctor.',
          ),
        ),
      );

      return;
    }

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Book Appointment',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF172B4D),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Appointment booking for ${doctor.name} will be available here.',
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Color(0xFF667085),
                  ),
                ),

                const SizedBox(height: 18),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.payments_outlined,
                        color: Color(0xFF1976D2),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Consultation fee',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF667085),
                          ),
                        ),
                      ),
                      Text(
                        '₹${doctor.consultationFee.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF172B4D),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookAppointmentScreen(doctor: doctor),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(title: const Text('Doctor Profile'), centerTitle: true),

      bottomNavigationBar: _BottomActions(
        onCall: _callDoctor,
        onAppointment: () => _showAppointmentMessage(context),
        appointmentEnabled: doctor.appointmentEnabled,
      ),

      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildProfileHeader()),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStats(),

                  const SizedBox(height: 24),

                  _SectionCard(
                    title: 'About',
                    icon: Icons.person_outline,
                    child: Text(
                      doctor.about.isEmpty
                          ? 'No information available.'
                          : doctor.about,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.7,
                        color: Color(0xFF475467),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  _SectionCard(
                    title: 'Professional Information',
                    icon: Icons.workspace_premium_outlined,
                    child: Column(
                      children: [
                        _InfoRow(
                          icon: Icons.school_outlined,
                          label: 'Qualification',
                          value: doctor.qualification,
                        ),
                        const Divider(height: 22),
                        _InfoRow(
                          icon: Icons.medical_services_outlined,
                          label: 'Speciality',
                          value: doctor.specialityName,
                        ),
                        const Divider(height: 22),
                        _InfoRow(
                          icon: Icons.work_history_outlined,
                          label: 'Experience',
                          value: '${doctor.experienceYears} years',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  _SectionCard(
                    title: 'Clinic',
                    icon: Icons.local_hospital_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor.clinicName.isEmpty
                              ? 'Clinic information unavailable'
                              : doctor.clinicName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF172B4D),
                          ),
                        ),

                        const SizedBox(height: 7),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 18,
                              color: Color(0xFF667085),
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                doctor.clinicAddress,
                                style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.5,
                                  color: Color(0xFF667085),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _openDirections,
                            icon: const Icon(
                              Icons.directions_outlined,
                              size: 18,
                            ),
                            label: const Text('Get Directions'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF1976D2),
                              side: const BorderSide(color: Color(0xFFD0D5DD)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(11),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  _SectionCard(
                    title: 'Consultation',
                    icon: Icons.payments_outlined,
                    child: Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Consultation fee',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF667085),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Per consultation',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF98A2B3),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '₹${doctor.consultationFee.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF172B4D),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  _SectionCard(
                    title: 'Reviews',
                    icon: Icons.star_outline_rounded,
                    child: Row(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7E8),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            doctor.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFB54708),
                            ),
                          ),
                        ),

                        const SizedBox(width: 13),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: List.generate(
                                5,
                                (index) => Icon(
                                  index < doctor.rating.round()
                                      ? Icons.star_rounded
                                      : Icons.star_border_rounded,
                                  size: 18,
                                  color: const Color(0xFFF79009),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${doctor.reviewCount} reviews',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF667085),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (doctor.isSponsored) _SponsoredNotice(),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4FF),
                  borderRadius: BorderRadius.circular(30),
                ),
                clipBehavior: Clip.antiAlias,
                child: doctor.profileImageUrl.isEmpty
                    ? const Icon(
                        Icons.person_outline,
                        size: 58,
                        color: Color(0xFF1976D2),
                      )
                    : Image.network(
                        doctor.profileImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.person_outline,
                          size: 58,
                          color: Color(0xFF1976D2),
                        ),
                      ),
              ),

              if (doctor.isVerified)
                Positioned(
                  right: 0,
                  bottom: 4,
                  child: Container(
                    width: 31,
                    height: 31,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1976D2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 17,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 15),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  doctor.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF172B4D),
                  ),
                ),
              ),

              if (doctor.isVerified)
                const Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Icon(
                    Icons.verified,
                    size: 22,
                    color: Color(0xFF1976D2),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            doctor.specialityName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1976D2),
            ),
          ),

          const SizedBox(height: 5),

          Text(
            doctor.qualification,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Color(0xFF667085)),
          ),

          if (doctor.isSponsored) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4E5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Sponsored',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFB54708),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        Expanded(
          child: _StatItem(
            icon: Icons.star_rounded,
            value: doctor.rating.toStringAsFixed(1),
            label: 'Rating',
            iconColor: const Color(0xFFF79009),
          ),
        ),
        Expanded(
          child: _StatItem(
            icon: Icons.reviews_outlined,
            value: '${doctor.reviewCount}',
            label: 'Reviews',
            iconColor: const Color(0xFF1976D2),
          ),
        ),
        Expanded(
          child: _StatItem(
            icon: Icons.work_history_outlined,
            value: '${doctor.experienceYears}',
            label: 'Years',
            iconColor: const Color(0xFF12B76A),
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF172B4D),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF98A2B3)),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: const Color(0xFF1976D2)),
              ),

              const SizedBox(width: 10),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF172B4D),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 19, color: const Color(0xFF667085)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF98A2B3)),
          ),
        ),
        Flexible(
          child: Text(
            value.isEmpty ? 'Not available' : value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF344054),
            ),
          ),
        ),
      ],
    );
  }
}

class _SponsoredNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFEC84B)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: Color(0xFFB54708)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'This doctor is a sponsored listing. Sponsorship may affect placement in some areas of GoCare.',
              style: TextStyle(
                fontSize: 11,
                height: 1.4,
                color: Color(0xFF7A2E0E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.onCall,
    required this.onAppointment,
    required this.appointmentEnabled,
  });

  final VoidCallback onCall;
  final VoidCallback onAppointment;
  final bool appointmentEnabled;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: const Color(0xFFEAECF0))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onCall,
                icon: const Icon(Icons.call_rounded, size: 18),
                label: const Text('Call'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF12B76A),
                  side: const BorderSide(color: Color(0xFF12B76A)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: appointmentEnabled ? onAppointment : null,
                icon: const Icon(Icons.calendar_month_outlined, size: 18),
                label: const Text('Book Appointment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFEAECF0),
                  disabledForegroundColor: const Color(0xFF98A2B3),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
