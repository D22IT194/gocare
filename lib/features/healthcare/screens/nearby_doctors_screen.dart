import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../nearby/services/location_service.dart';
import '../providers/nearby_doctor_provider.dart';
import '../widgets/nearby_doctor_card.dart';
import 'doctor_detail_screen.dart';

class NearbyDoctorsScreen
    extends StatefulWidget {
  const NearbyDoctorsScreen({
    super.key,
  });

  @override
  State<NearbyDoctorsScreen>
      createState() =>
          _NearbyDoctorsScreenState();
}

class _NearbyDoctorsScreenState
    extends State<
        NearbyDoctorsScreen> {
  final LocationService
      _locationService =
      LocationService();

  bool _locationLoading =
      false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback(
      (_) {
        _loadDoctors();
      },
    );
  }

  Future<void> _loadDoctors()
      async {
    setState(() {
      _locationLoading = true;
    });

    try {
      final position =
          await _locationService
              .getCurrentLocation();

      if (!mounted) {
        return;
      }

      await context
          .read<
              NearbyDoctorProvider>()
          .loadNearbyDoctors(
        latitude:
            position.latitude,
        longitude:
            position.longitude,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Unable to get your location.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _locationLoading =
              false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider =
        context.watch<
            NearbyDoctorProvider>();

    return Scaffold(
      backgroundColor:
          const Color(0xFFF8FAFC),

      appBar: AppBar(
        title: const Text(
          'Nearby Doctors',
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed:
                _locationLoading
                    ? null
                    : _loadDoctors,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),

      body: _buildBody(
        provider,
      ),
    );
  }

  Widget _buildBody(
    NearbyDoctorProvider provider,
  ) {
    if (_locationLoading ||
        provider.loading) {
      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    if (provider.error != null) {
      return _ErrorView(
        onRetry: _loadDoctors,
      );
    }

    if (provider.doctors.isEmpty) {
      return const _EmptyView();
    }

    return RefreshIndicator(
      onRefresh:
          _loadDoctors,
      child: ListView.separated(
        padding:
            const EdgeInsets.fromLTRB(
          20,
          18,
          20,
          30,
        ),
        itemCount:
            provider.doctors.length,
        separatorBuilder:
            (_, _) =>
                const SizedBox(
          height: 12,
        ),
        itemBuilder:
            (context, index) {
          final item =
              provider.doctors[index];

          return NearbyDoctorCard(
            item: item,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      DoctorDetailScreen(
                    doctor:
                        item.doctor,
                  ),
                ),
              );
            },
            onCall: () {
              _callDoctor(
                item.doctor.phone,
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _callDoctor(
    String phone,
  ) async {
    if (phone.isEmpty) {
      return;
    }

    final uri =
        Uri(
      scheme: 'tel',
      path: phone,
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _EmptyView
    extends StatelessWidget {
  const _EmptyView();

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
                  .location_off_outlined,
              size: 50,
              color:
                  Color(0xFF98A2B3),
            ),
            SizedBox(height: 12),
            Text(
              'No doctors found nearby',
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
              'Try increasing the search radius or changing your location.',
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

class _ErrorView
    extends StatelessWidget {
  const _ErrorView({
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
                .location_off_outlined,
            size: 45,
            color:
                Color(0xFF98A2B3),
          ),
          const SizedBox(
            height: 10,
          ),
          const Text(
            'Unable to load nearby doctors.',
          ),
          const SizedBox(
            height: 10,
          ),
          OutlinedButton(
            onPressed: onRetry,
            child:
                const Text('Retry'),
          ),
        ],
      ),
    );
  }
}