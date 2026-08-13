import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/nearby_provider.dart';
import '../widgets/nearby_place_card.dart';

class SavedPlacesScreen extends StatefulWidget {
  const SavedPlacesScreen({
    super.key,
  });

  @override
  State<SavedPlacesScreen> createState() =>
      _SavedPlacesScreenState();
}

class _SavedPlacesScreenState
    extends State<SavedPlacesScreen> {

  @override
  void initState() {
    super.initState();

    // Load saved places after the screen is mounted.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<NearbyProvider>().loadSavedPlaces();
    });
  }

  // ==========================================================
  // REMOVE CONFIRMATION DIALOG (REDESIGNED)
  // ==========================================================

  Future<void> _confirmRemove(
    BuildContext context,
    NearbyProvider provider,
    dynamic place,
  ) async {
    final shouldRemove = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent, // Prevents default material tint change
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24), // Smoother modern rounded corners
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24), // Cleaner box margins
          title: Row(
            children: [
              // Circular soft background container for the icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.bookmark_remove_rounded,
                  color: Colors.red.shade600, // Shifted to red for destructive actions
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Remove saved place?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF172B4D),
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to remove "${place.name}" from your saved places?',
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF667085),
            ),
          ),
          actions: [
            Row(
              children: [
                // 1. Cancel Button (Takes up equal half space)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop(false);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF667085),
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14), // Perfect rounded corners
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 2. Remove Button (Takes up equal half space)
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop(true);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red.shade600, // Standout confirmation color
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Remove',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (shouldRemove != true) {
      return;
    }

    if (!mounted) {
      return;
    }

    try {
      await provider.toggleFavorite(place);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text(
              'Place removed from saved places',
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceFirst(
                'Exception: ',
                '',
              ),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }


  // ==========================================================
  // REFRESH
  // ==========================================================

  Future<void> _refresh() async {
    await context
        .read<NearbyProvider>()
        .loadSavedPlaces();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,

        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF172B4D),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),

        title: const Text(
          'Saved places',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF172B4D),
          ),
        ),

        centerTitle: false,
      ),

      body: Consumer<NearbyProvider>(
        builder: (
          context,
          provider,
          _,
        ) {
          return RefreshIndicator(
            color: const Color(0xFF1976D2),
            onRefresh: _refresh,

            child: _buildBody(
              context,
              provider,
            ),
          );
        },
      ),
    );
  }

  // ==========================================================
  // BODY
  // ==========================================================

  Widget _buildBody(
    BuildContext context,
    NearbyProvider provider,
  ) {
    // --------------------------------------------------------
    // LOADING
    // --------------------------------------------------------

    if (provider.isLoadingSavedPlaces) {
      return ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: const [
          SizedBox(height: 120),

          Center(
            child: CircularProgressIndicator(
              color: Color(0xFF1976D2),
            ),
          ),
        ],
      );
    }

    // --------------------------------------------------------
    // ERROR
    // --------------------------------------------------------

    if (provider.errorMessage != null &&
        provider.errorMessage!.isNotEmpty &&
        provider.savedPlaces.isEmpty) {
      return ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 80),

          const Icon(
            Icons.error_outline_rounded,
            size: 52,
            color: Color(0xFFD92D20),
          ),

          const SizedBox(height: 16),

          const Center(
            child: Text(
              'Unable to load saved places',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF172B4D),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            provider.errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF667085),
            ),
          ),

          const SizedBox(height: 20),

          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                provider.loadSavedPlaces();
              },
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text(
                'Try again',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF1976D2),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // --------------------------------------------------------
    // EMPTY
    // --------------------------------------------------------

    if (provider.savedPlaces.isEmpty) {
      return ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          20,
          80,
          20,
          30,
        ),
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4FF),
              borderRadius:
                  BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.bookmark_border_rounded,
              size: 42,
              color: Color(0xFF1976D2),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'No saved places yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: Color(0xFF172B4D),
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Save hospitals, clinics, doctors and other '
            'healthcare places to quickly find them later.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Color(0xFF667085),
            ),
          ),

          const SizedBox(height: 24),

          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(
                Icons.explore_outlined,
              ),
              label: const Text(
                'Browse nearby places',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF1976D2),
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 13,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // --------------------------------------------------------
    // SAVED PLACES
    // --------------------------------------------------------

    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),

      padding: const EdgeInsets.fromLTRB(
        16,
        18,
        16,
        30,
      ),

      children: [
        // ------------------------------------------------------
        // HEADER
        // ------------------------------------------------------

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE4E7EC),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4FF),
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.bookmark_rounded,
                  color: Color(0xFF1976D2),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your saved places',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.w800,
                        color:
                            Color(0xFF172B4D),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '${provider.savedPlaces.length} saved place'
                      '${provider.savedPlaces.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                        fontSize: 13,
                        color:
                            Color(0xFF667085),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ------------------------------------------------------
        // PLACES
        // ------------------------------------------------------

        ...provider.savedPlaces.map(
          (place) {
            return Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 12,
              ),
              child: NearbyPlaceCard(
                place: place.copyWith(
                  isFavorite: true,
                ),

                onFavoriteToggle:
                    (updatedPlace) {
                  _confirmRemove(
                    context,
                    provider,
                    place,
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}