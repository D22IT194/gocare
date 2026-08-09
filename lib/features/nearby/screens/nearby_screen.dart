import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/nearby_provider.dart';
import '../services/nearby_places_service.dart';
import '../widgets/nearby_place_card.dart';

class NearbyScreen
    extends StatefulWidget {
  const NearbyScreen({
    super.key,
  });

  @override
  State<NearbyScreen> createState() =>
      _NearbyScreenState();
      
}

class _NearbyScreenState
    extends State<NearbyScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      context
          .read<NearbyProvider>()
          .loadCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider =
        context.watch<NearbyProvider>();

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Nearby'),
        centerTitle: true,

        actions: [
          IconButton(
            tooltip:
                'Refresh',

            onPressed:
                provider.isLoading
                    ? null
                    : () {
                        context
                            .read<
                                NearbyProvider>()
                            .refresh();
                      },

            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),

      body:
          _buildBody(
        context,
        provider,
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    NearbyProvider provider,
  ) {
    if (provider.isLoading) {
      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    if (provider.status ==
        NearbyStatus.error) {
      return _ErrorView(
        message:
            provider.errorMessage ??
                'Something went wrong.',

        onRetry: () {
          if (provider
                  .selectedCategory !=
              null) {
            provider.searchPlaces(
              provider.selectedCategory!,
            );
          } else {
            provider
                .loadCurrentLocation();
          }
        },

        onSettings: () {
          provider
              .openAppSettings();
        },
      );
    }

    if (!provider.hasLocation) {
      return _LocationView(
        onPressed: () {
          provider
              .loadCurrentLocation();
        },
      );
    }

    return RefreshIndicator(
      onRefresh:
          provider.refresh,

      child: ListView(
        padding:
            const EdgeInsets.fromLTRB(
          20,
          16,
          20,
          30,
        ),

        children: [
          _LocationHeader(
            position:
                provider.currentPosition!,
          ),

          const SizedBox(
            height: 22,
          ),

          const Text(
            'Find nearby care',
            style: TextStyle(
              fontSize: 22,
              fontWeight:
                  FontWeight.w700,
              color:
                  Color(0xFF172B4D),
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          const Text(
            'Find healthcare and emergency '
            'services near your current location.',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color:
                  Color(0xFF667085),
            ),
          ),

          const SizedBox(
            height: 18,
          ),

          _CategorySelector(
            selected:
                provider
                    .selectedCategory,
            onSelected:
                (category) {
              provider
                  .searchPlaces(
                category,
              );
            },
          ),

          const SizedBox(
            height: 24,
          ),

          if (provider
              .selectedCategory ==
              null)
            const _SelectCategoryMessage()
          else if (provider.places.isEmpty)
            const _NoPlacesFound()
          else ...[
            Row(
              children: [
                Text(
                  provider
                      .selectedCategory!
                      .displayName,
                  style:
                      const TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        Color(0xFF172B4D),
                  ),
                ),

                const Spacer(),

                Text(
                  '${provider.places.length} found',
                  style:
                      const TextStyle(
                    fontSize: 13,
                    color:
                        Color(0xFF667085),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 14,
            ),

            ...provider.places.map(
              (place) =>
                  NearbyPlaceCard(
                place: place,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// LOCATION HEADER
// ============================================================

class _LocationHeader
    extends StatelessWidget {
  const _LocationHeader({
    required this.position,
  });

  final dynamic position;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(16),

      decoration:
          BoxDecoration(
        color:
            const Color(0xFFEAF4FF),
        borderRadius:
            BorderRadius.circular(18),
      ),

      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,

            decoration:
                const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons.location_on,
              color:
                  Color(0xFF1976D2),
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  'Using your location',
                  style:
                      TextStyle(
                    fontSize: 15,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        Color(
                      0xFF172B4D,
                    ),
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'Nearby results are based '
                  'on your current GPS location.',
                  style:
                      TextStyle(
                    fontSize: 12,
                    color:
                        Color(
                      0xFF667085,
                    ),
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
// CATEGORY SELECTOR
// ============================================================

class _CategorySelector
    extends StatelessWidget {
  const _CategorySelector({
    required this.selected,
    required this.onSelected,
  });

  final NearbyPlaceCategory?
      selected;

  final ValueChanged<
          NearbyPlaceCategory>
      onSelected;

  @override
  Widget build(BuildContext context) {
    const categories = [
      NearbyPlaceCategory.hospital,
      NearbyPlaceCategory.pharmacy,
      NearbyPlaceCategory.clinic,
      NearbyPlaceCategory.emergency,
      NearbyPlaceCategory.police,
      NearbyPlaceCategory.fireStation,
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,

      children:
          categories.map(
        (category) {
          final isSelected =
              selected == category;

          return ChoiceChip(
            label: Text(
              category.displayName,
            ),

            selected:
                isSelected,

            onSelected: (_) {
              onSelected(
                category,
              );
            },

            selectedColor:
                const Color(
              0xFFEAF4FF,
            ),

            side: BorderSide(
              color:
                  isSelected
                      ? const Color(
                          0xFF1976D2,
                        )
                      : const Color(
                          0xFFE4E7EC,
                        ),
            ),

            labelStyle:
                TextStyle(
              color:
                  isSelected
                      ? const Color(
                          0xFF1976D2,
                        )
                      : const Color(
                          0xFF344054,
                        ),
              fontWeight:
                  isSelected
                      ? FontWeight.w600
                      : FontWeight.w500,
            ),
          );
        },
      ).toList(),
    );
  }
}

// ============================================================
// SELECT CATEGORY
// ============================================================

class _SelectCategoryMessage
    extends StatelessWidget {
  const _SelectCategoryMessage();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding:
          EdgeInsets.symmetric(
        vertical: 40,
      ),

      child: Column(
        children: [
          Icon(
            Icons
                .location_searching,
            size: 60,
            color:
                Color(0xFF98A2B3),
          ),

          SizedBox(height: 16),

          Text(
            'Select a category',
            style:
                TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.w700,
              color:
                  Color(0xFF172B4D),
            ),
          ),

          SizedBox(height: 8),

          Text(
            'Choose what you are looking for '
            'near your current location.',
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              fontSize: 14,
              color:
                  Color(0xFF667085),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// NO PLACES
// ============================================================

class _NoPlacesFound
    extends StatelessWidget {
  const _NoPlacesFound();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding:
          EdgeInsets.symmetric(
        vertical: 40,
      ),

      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 60,
            color:
                Color(0xFF98A2B3),
          ),

          SizedBox(height: 16),

          Text(
            'No places found',
            style:
                TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          SizedBox(height: 8),

          Text(
            'Try another category or '
            'refresh your location.',
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              color:
                  Color(0xFF667085),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// LOCATION VIEW
// ============================================================

class _LocationView
    extends StatelessWidget {
  const _LocationView({
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 70,
              color:
                  Color(0xFF1976D2),
            ),

            const SizedBox(
              height: 20,
            ),

            const Text(
              'Location required',
              style: TextStyle(
                fontSize: 23,
                fontWeight:
                    FontWeight.w700,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            const Text(
              'Allow location access to find '
              'healthcare and emergency '
              'services near you.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color:
                    Color(0xFF667085),
                height: 1.5,
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            SizedBox(
              width:
                  double.infinity,
              height: 52,

              child:
                  ElevatedButton(
                onPressed:
                    onPressed,
                child:
                    const Text(
                  'Allow Location',
                ),
              ),
            ),
          ],
        ),
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
    required this.onSettings,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final isPermissionError =
        message.contains(
          'permanently denied',
        );

    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            const Icon(
              Icons.error_outline,
              size: 65,
              color:
                  Color(0xFFF79009),
            ),

            const SizedBox(
              height: 20,
            ),

            const Text(
              'Unable to load nearby places',
              textAlign:
                  TextAlign.center,
              style:
                  TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.w700,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            Text(
              message,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    Color(0xFF667085),
                height: 1.5,
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            SizedBox(
              width:
                  double.infinity,
              height: 50,

              child:
                  ElevatedButton(
                onPressed:
                    isPermissionError
                        ? onSettings
                        : onRetry,

                child: Text(
                  isPermissionError
                      ? 'Open Settings'
                      : 'Try Again',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
