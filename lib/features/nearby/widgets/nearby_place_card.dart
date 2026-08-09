import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/nearby_place.dart';

/// A polished card for a single nearby place.
///
/// Wire [onFavoriteToggle] up to wherever you persist saved locations
/// (local db, shared prefs, backend, etc). This widget itself is stateless
/// with respect to data — it just animates the icon and reports the tap.
class NearbyPlaceCard extends StatefulWidget {
  const NearbyPlaceCard({
    super.key,
    required this.place,
    this.onFavoriteToggle,
    this.onTap,
  });

  final NearbyPlace place;

  /// Called with the place when the user taps the favorite/bookmark icon.
  /// Update your data source here (e.g. toggle in a list, write to storage).
  final ValueChanged<NearbyPlace>? onFavoriteToggle;

  /// Optional: called when the whole card is tapped (e.g. open details).
  final VoidCallback? onTap;

  @override
  State<NearbyPlaceCard> createState() => _NearbyPlaceCardState();
}

class _NearbyPlaceCardState extends State<NearbyPlaceCard>
    with SingleTickerProviderStateMixin {
  static const _blue = Color(0xFF1976D2);
  static const _blueBg = Color(0xFFEAF4FF);
  static const _green = Color(0xFF12B76A);
  static const _greenBg = Color(0xFFE8FBF1);
  static const _red = Color(0xFFE0245E);
  static const _amberBg = Color(0xFFFFF6E5);
  static const _amber = Color(0xFFB78103);
  static const _ink = Color(0xFF172B4D);
  static const _muted = Color(0xFF667085);
  static const _border = Color(0xFFE4E7EC);

  late final AnimationController _favController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    lowerBound: 0.85,
    upperBound: 1.0,
    value: 1.0,
  );

  @override
  void dispose() {
    _favController.dispose();
    super.dispose();
  }

  Future<void> _openMaps() async {
    final place = widget.place;
    Uri uri;

    if (place.googleMapsUri != null && place.googleMapsUri!.isNotEmpty) {
      uri = Uri.parse(place.googleMapsUri!);
    } else {
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1'
        '&query=${Uri.encodeComponent(place.name)}'
        '%20${place.latitude},${place.longitude}',
      );
    }

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) debugPrint('Could not launch Google Maps.');
    } catch (e) {
      debugPrint('Error opening Google Maps: $e');
    }
  }

  Future<void> _call() async {
    final phone = widget.place.phoneNumber;
    if (phone == null || phone.isEmpty) return;

    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  void _handleFavoriteTap() {
    _favController.forward(from: 0.85);
    widget.onFavoriteToggle?.call(
      widget.place.copyWith(isFavorite: !widget.place.isFavorite),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'hospital':
      case 'clinic':
      case 'pharmacy':
        return Icons.local_hospital_outlined;
      case 'restaurant':
      case 'cafe':
        return Icons.restaurant_outlined;
      case 'gas station':
      case 'fuel':
        return Icons.local_gas_station_outlined;
      case 'grocery':
      case 'supermarket':
        return Icons.local_grocery_store_outlined;
      case 'atm':
      case 'bank':
        return Icons.account_balance_outlined;
      default:
        return Icons.place_outlined;
    }
  }

  IconData _travelModeIcon(TravelMode mode) {
    switch (mode) {
      case TravelMode.walking:
        return Icons.directions_walk;
      case TravelMode.driving:
        return Icons.directions_car_outlined;
      case TravelMode.transit:
        return Icons.directions_transit_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final place = widget.place;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Header: icon, name, address, favorite button ----
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _blueBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(_categoryIcon(place.category), color: _blue),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _ink,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          place.address,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: _muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ScaleTransition(
                    scale: _favController,
                    child: IconButton(
                      onPressed: _handleFavoriteTap,
                      splashRadius: 20,
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        place.isFavorite ? Icons.bookmark : Icons.bookmark_border,
                        color: place.isFavorite ? _red : _muted,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ---- Info chips: distance, travel time, hours ----
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(
                    icon: Icons.near_me_outlined,
                    label: place.distanceText,
                    color: _blue,
                    background: _blueBg,
                  ),
                  if (place.travelTimeText != null)
                    _InfoChip(
                      icon: _travelModeIcon(place.travelMode),
                      label: '${place.travelTimeText} to reach',
                      color: _blue,
                      background: _blueBg,
                    ),
                  _InfoChip(
                    icon: place.isOpen
                        ? Icons.access_time_filled_rounded
                        : Icons.access_time_rounded,
                    label: place.hoursText,
                    color: place.isOpen ? _green : _amber,
                    background: place.isOpen ? _greenBg : _amberBg,
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ---- Actions: directions, call ----
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _openMaps,
                      icon: const Icon(Icons.directions_outlined, size: 18),
                      label: const Text('Directions'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _blue,
                        side: const BorderSide(color: _blue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  if (place.phoneNumber != null) ...[
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 52,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: _call,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _green,
                          side: const BorderSide(color: _green),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Icon(Icons.call_outlined),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}