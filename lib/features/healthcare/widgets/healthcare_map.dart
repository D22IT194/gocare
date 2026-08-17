import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/healthcare_facility_result.dart';

class HealthcareMap extends StatefulWidget {
  const HealthcareMap({
    super.key,
    required this.facilities,
    required this.userLatitude,
    required this.userLongitude,
    required this.onFacilityTap,
  });

  final List<HealthcareFacilityResult> facilities;

  final double? userLatitude;
  final double? userLongitude;

  final ValueChanged<HealthcareFacilityResult>
      onFacilityTap;

  @override
  State<HealthcareMap> createState() =>
      _HealthcareMapState();
}

class _HealthcareMapState
    extends State<HealthcareMap> {
  GoogleMapController? _controller;

  Set<Marker> get _markers {
    final markers = <Marker>{};

    for (final result
        in widget.facilities) {
      final facility =
          result.facility;

      markers.add(
        Marker(
          markerId: MarkerId(
            facility.id,
          ),
          position: LatLng(
            facility.latitude,
            facility.longitude,
          ),
          infoWindow: InfoWindow(
            title: facility.name,
            snippet:
                '${result.formattedDistance} away',
          ),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(
            facility.isEmergencyAvailable
                ? BitmapDescriptor
                    .hueRed
                : BitmapDescriptor
                    .hueAzure,
          ),
          onTap: () {
            widget.onFacilityTap(
              result,
            );
          },
        ),
      );
    }

    if (widget.userLatitude !=
            null &&
        widget.userLongitude !=
            null) {
      markers.add(
        Marker(
          markerId:
              const MarkerId(
            'current_user',
          ),
          position: LatLng(
            widget.userLatitude!,
            widget.userLongitude!,
          ),
          icon:
              BitmapDescriptor
                  .defaultMarkerWithHue(
            BitmapDescriptor
                .hueGreen,
          ),
          infoWindow:
              const InfoWindow(
            title:
                'Your location',
          ),
        ),
      );
    }

    return markers;
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    if (widget.facilities.isEmpty) {
      return _buildEmptyMap();
    }

    final first =
        widget.facilities.first.facility;

    final initialPosition =
        LatLng(
      widget.userLatitude ??
          first.latitude,
      widget.userLongitude ??
          first.longitude,
    );

    return ClipRRect(
      borderRadius:
          BorderRadius.circular(20),
      child: GoogleMap(
        initialCameraPosition:
            CameraPosition(
          target: initialPosition,
          zoom: 12.5,
        ),
        markers: _markers,
        myLocationEnabled:
            widget.userLatitude != null,
        myLocationButtonEnabled:
            true,
        zoomControlsEnabled:
            false,
        mapToolbarEnabled: false,
        compassEnabled: true,
        onMapCreated:
            (controller) {
          _controller =
              controller;
        },
      ),
    );
  }

  Widget _buildEmptyMap() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color:
            const Color(0xFFF2F4F7),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: const Column(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            Icons
                .location_off_outlined,
            size: 48,
            color:
                Color(0xFF98A2B3),
          ),
          SizedBox(
            height: 12,
          ),
          Text(
            'No healthcare facilities found',
            style: TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.w700,
              color:
                  Color(0xFF344054),
            ),
          ),
        ],
      ),
    );
  }
}