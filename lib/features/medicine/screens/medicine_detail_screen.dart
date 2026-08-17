import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/medicine_model.dart';
import '../providers/medicine_provider.dart';
import '../../medical_equipment/services/affiliate_product_service.dart';
import '../../medical_equipment/widgets/affiliate_product_card.dart';

class MedicineDetailScreen extends StatefulWidget {
  const MedicineDetailScreen({
    super.key,
    required this.medicineId,
    this.userId,
  });

  final String medicineId;
  final String? userId;

  @override
  State<MedicineDetailScreen> createState() => _MedicineDetailScreenState();
}

class _MedicineDetailScreenState extends State<MedicineDetailScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MedicineProvider>().loadMedicine(
        widget.medicineId,
        userId: widget.userId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MedicineProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        title: const Text('Medicine Information'),
        actions: [
          if (provider.selectedMedicine != null)
            IconButton(
              tooltip: provider.selectedMedicineSaved
                  ? 'Remove from saved'
                  : 'Save medicine',
              onPressed: widget.userId == null
                  ? null
                  : () {
                      provider.toggleSavedMedicine(
                        userId: widget.userId!,
                        medicineId: widget.medicineId,
                      );
                    },
              icon: Icon(
                provider.selectedMedicineSaved
                    ? Icons.bookmark
                    : Icons.bookmark_border,
              ),
            ),
        ],
      ),

      body: _buildBody(provider),
    );
  }

  Widget _buildBody(MedicineProvider provider) {
    if (provider.detailLoading) {
      return const _MedicineDetailSkeleton();
    }

    if (provider.error != null && provider.selectedMedicine == null) {
      return _ErrorState(
        message: provider.error!,
        onRetry: () {
          provider.loadMedicine(widget.medicineId, userId: widget.userId);
        },
      );
    }

    final medicine = provider.selectedMedicine;

    if (medicine == null) {
      return const Center(child: Text('Medicine not found.'));
    }

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () {
          return provider.loadMedicine(
            widget.medicineId,
            userId: widget.userId,
          );
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            _MedicineHeader(medicine: medicine),

            const SizedBox(height: 20),

            _InformationCard(
              title: 'About this medicine',
              icon: Icons.medication_outlined,
              child: Text(medicine.description, style: _bodyTextStyle),
            ),

            if (medicine.howItWorks != null &&
                medicine.howItWorks!.trim().isNotEmpty) ...[
              const SizedBox(height: 14),
              _InformationCard(
                title: 'How it works',
                icon: Icons.science_outlined,
                child: Text(medicine.howItWorks!, style: _bodyTextStyle),
              ),
            ],

            if (medicine.uses.isNotEmpty) ...[
              const SizedBox(height: 14),
              _BulletCard(
                title: 'Uses',
                icon: Icons.check_circle_outline,
                items: medicine.uses,
              ),
            ],

            if (medicine.precautions.isNotEmpty) ...[
              const SizedBox(height: 14),
              _BulletCard(
                title: 'Precautions',
                icon: Icons.warning_amber_outlined,
                items: medicine.precautions,
                warning: true,
              ),
            ],

            if (medicine.sideEffects.isNotEmpty) ...[
              const SizedBox(height: 14),
              _BulletCard(
                title: 'Possible side effects',
                icon: Icons.report_problem_outlined,
                items: medicine.sideEffects,
              ),
            ],

            if (medicine.interactions.isNotEmpty) ...[
              const SizedBox(height: 14),
              _BulletCard(
                title: 'Interactions',
                icon: Icons.compare_arrows_outlined,
                items: medicine.interactions,
                warning: true,
              ),
            ],

            if (medicine.storage != null &&
                medicine.storage!.trim().isNotEmpty) ...[
              const SizedBox(height: 14),
              _InformationCard(
                title: 'Storage',
                icon: Icons.inventory_2_outlined,
                child: Text(medicine.storage!, style: _bodyTextStyle),
              ),
            ],

            const SizedBox(height: 20),

            _MedicalDisclaimer(),

            const SizedBox(height: 24),

            _AffiliateSection(
              provider: provider,
              userId: widget.userId,
            ),
          ],
        ),
      ),
    );
  }
}

const _bodyTextStyle = TextStyle(
  fontSize: 14,
  height: 1.55,
  color: Color(0xFF475467),
);

// ============================================================
// MEDICINE HEADER
// ============================================================

class _MedicineHeader extends StatelessWidget {
  const _MedicineHeader({required this.medicine});

  final MedicineModel medicine;

  @override
  Widget build(BuildContext context) {
    final hasImage =
        medicine.imageUrl != null && medicine.imageUrl!.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4FF),
              borderRadius: BorderRadius.circular(18),
            ),
            clipBehavior: Clip.antiAlias,
            child: hasImage
                ? Image.network(
                    medicine.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return const Icon(
                        Icons.medication_outlined,
                        size: 42,
                        color: Color(0xFF1976D2),
                      );
                    },
                  )
                : const Icon(
                    Icons.medication_outlined,
                    size: 42,
                    color: Color(0xFF1976D2),
                  ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine.name,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF172B4D),
                  ),
                ),

                if (medicine.genericName.trim().isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    medicine.genericName,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF667085),
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF4FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    medicine.category,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1976D2),
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
// INFORMATION CARD
// ============================================================

class _InformationCard extends StatelessWidget {
  const _InformationCard({
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4FF),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 20, color: const Color(0xFF1976D2)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF172B4D),
                  ),
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

// ============================================================
// BULLET CARD
// ============================================================

class _BulletCard extends StatelessWidget {
  const _BulletCard({
    required this.title,
    required this.icon,
    required this.items,
    this.warning = false,
  });

  final String title;
  final IconData icon;
  final List<String> items;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: warning
                    ? const Color(0xFFB54708)
                    : const Color(0xFF1976D2),
                size: 22,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF172B4D),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: warning
                            ? const Color(0xFFB54708)
                            : const Color(0xFF1976D2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(item, style: _bodyTextStyle)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DISCLAIMER
// ============================================================

class _MedicalDisclaimer extends StatelessWidget {
  const _MedicalDisclaimer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE7A9)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Color(0xFFB54708)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'This information is for general educational purposes only. It should not replace advice from a qualified healthcare professional.',
              style: TextStyle(
                fontSize: 12,
                height: 1.45,
                color: Color(0xFF7A4E00),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// AFFILIATE SECTION
// ============================================================

class _AffiliateSection extends StatelessWidget {
  const _AffiliateSection({
    required this.provider,
    required this.userId,
  });

  final MedicineProvider provider;
  final String? userId;

  @override
  Widget build(BuildContext context) {
    if (provider.affiliateLoading) {
      return const _AffiliateSkeleton();
    }

    if (provider.affiliateProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    final affiliateService =
        AffiliateProductService();

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Where to Buy',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: Color(0xFF172B4D),
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          'Compare available products from our partners.',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF667085),
          ),
        ),

        const SizedBox(height: 12),

        ...provider.affiliateProducts.map(
          (product) => Padding(
            padding:
                const EdgeInsets.only(
              bottom: 12,
            ),
            child: AffiliateProductCard(
              product: product,
              onBuyPressed: () async {
                final opened =
                    await affiliateService
                        .openAffiliateProduct(
                  product: product,
                  userId: userId,
                );

                if (!opened &&
                    context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Unable to open this product link.',
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// DETAIL SKELETON
// ============================================================

class _MedicineDetailSkeleton extends StatelessWidget {
  const _MedicineDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
        children: [
          _SkeletonPanel(height: 130),

          const SizedBox(height: 14),

          _SkeletonPanel(height: 150),

          const SizedBox(height: 14),

          _SkeletonPanel(height: 140),

          const SizedBox(height: 14),

          _SkeletonPanel(height: 180),

          const SizedBox(height: 14),

          _SkeletonPanel(height: 140),
        ],
      ),
    );
  }
}

class _AffiliateSkeleton extends StatelessWidget {
  const _AffiliateSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SkeletonLine(width: 150, height: 20),
        const SizedBox(height: 12),
        ...List.generate(
          2,
          (_) => const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: _SkeletonPanel(height: 75),
          ),
        ),
      ],
    );
  }
}

class _SkeletonPanel extends StatelessWidget {
  const _SkeletonPanel({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SkeletonLine(width: 150, height: 18),
          const SizedBox(height: 16),
          _SkeletonLine(width: double.infinity, height: 12),
          const SizedBox(height: 9),
          _SkeletonLine(width: double.infinity, height: 12),
          const SizedBox(height: 9),
          const _SkeletonLine(width: 180, height: 12),
        ],
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE9EEF5),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

// ============================================================
// ERROR STATE
// ============================================================

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 54, color: Color(0xFFD32F2F)),
            const SizedBox(height: 14),
            const Text(
              'Unable to load medicine',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF667085)),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
