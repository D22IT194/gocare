import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/medical_equipment_model.dart';
import '../providers/medical_equipment_provider.dart';
import '../models/affiliate_product_model.dart';
import '../services/affiliate_product_service.dart';
import '../widgets/affiliate_product_card.dart';

class MedicalEquipmentDetailScreen
    extends StatefulWidget {
  const MedicalEquipmentDetailScreen({
    super.key,
    required this.equipmentId,
    this.userId,
  });

  final String equipmentId;
  final String? userId;

  @override
  State<MedicalEquipmentDetailScreen>
      createState() =>
          _MedicalEquipmentDetailScreenState();
}

class _MedicalEquipmentDetailScreenState
    extends State<MedicalEquipmentDetailScreen> {
  final AffiliateProductService
      _affiliateService =
      AffiliateProductService();

  List<AffiliateProductModel> _affiliateProducts =
      [];

  bool _affiliateLoading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider =
        context.read<MedicalEquipmentProvider>();

    await provider.loadEquipmentDetail(
      widget.equipmentId,
    );

    await _loadAffiliateProducts();
  }

  Future<void> _loadAffiliateProducts() async {
    if (mounted) {
      setState(() {
        _affiliateLoading = true;
      });
    }

    try {
      final products =
          await _affiliateService
              .getEquipmentProducts(
        widget.equipmentId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _affiliateProducts = products;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _affiliateProducts = [];
      });
    } finally {
      if (mounted) {
        setState(() {
          _affiliateLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider =
        context.watch<MedicalEquipmentProvider>();

    return Scaffold(
      backgroundColor:
          const Color(0xFFF8FAFC),

      appBar: AppBar(
        title: const Text(
          'Equipment Details',
        ),
        backgroundColor:
            const Color(0xFFF8FAFC),
        elevation: 0,
      ),

      body: _buildBody(provider),
    );
  }

  Widget _buildBody(
    MedicalEquipmentProvider provider,
  ) {
    if (provider.detailLoading) {
      return const _DetailSkeleton();
    }

    if (provider.error != null &&
        provider.selectedEquipment == null) {
      return _ErrorState(
        message: provider.error!,
        onRetry: _loadData,
      );
    }

    final equipment =
        provider.selectedEquipment;

    if (equipment == null) {
      return const Center(
        child: Text(
          'Equipment not found.',
        ),
      );
    }

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            20,
            8,
            20,
            32,
          ),
          children: [
            _EquipmentHeader(
              equipment: equipment,
            ),

            const SizedBox(height: 18),

            if (equipment.description
                .trim()
                .isNotEmpty)
              _InformationCard(
                title: 'About this equipment',
                icon:
                    Icons.medical_services_outlined,
                child: Text(
                  equipment.description,
                  style: _bodyStyle,
                ),
              ),

            if (equipment.uses.isNotEmpty) ...[
              const SizedBox(height: 14),
              _BulletCard(
                title: 'Uses',
                icon:
                    Icons.check_circle_outline,
                items: equipment.uses,
              ),
            ],

            if (equipment.features.isNotEmpty) ...[
              const SizedBox(height: 14),
              _BulletCard(
                title: 'Features',
                icon:
                    Icons.auto_awesome_outlined,
                items: equipment.features,
              ),
            ],

            if (equipment.precautions.isNotEmpty) ...[
              const SizedBox(height: 14),
              _BulletCard(
                title: 'Precautions',
                icon:
                    Icons.warning_amber_outlined,
                items: equipment.precautions,
                warning: true,
              ),
            ],

            const SizedBox(height: 20),

            const _SafetyNote(),

            const SizedBox(height: 26),

            _AffiliateProductsSection(
              products: _affiliateProducts,
              loading: _affiliateLoading,
              userId: widget.userId,
              service: _affiliateService,
            ),
          ],
        ),
      ),
    );
  }
}

const _bodyStyle = TextStyle(
  fontSize: 14,
  height: 1.55,
  color: Color(0xFF475467),
);

// ============================================================
// HEADER
// ============================================================

class _EquipmentHeader extends StatelessWidget {
  const _EquipmentHeader({
    required this.equipment,
  });

  final MedicalEquipmentModel equipment;

  @override
  Widget build(BuildContext context) {
    final imageAvailable =
        equipment.imageUrl != null && equipment.imageUrl!.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE4E7EC),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4FF),
              borderRadius:
                  BorderRadius.circular(18),
            ),
            clipBehavior:
                Clip.antiAlias,
            child: imageAvailable
                ? Image.network(
                    equipment.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) {
                      return const Icon(
                        Icons
                            .medical_services_outlined,
                        size: 44,
                        color:
                            Color(0xFF1976D2),
                      );
                    },
                  )
                : const Icon(
                    Icons
                        .medical_services_outlined,
                    size: 44,
                    color:
                        Color(0xFF1976D2),
                  ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  equipment.name,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        Color(0xFF172B4D),
                  ),
                ),

                if (equipment.brand != null &&
                    equipment.brand!.trim().isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    equipment.brand!,
                    style: const TextStyle(
                      fontSize: 13,
                      color:
                          Color(0xFF667085),
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration:
                      BoxDecoration(
                    color: const Color(
                      0xFFEAF4FF,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: Text(
                    equipment.category,
                    style:
                        const TextStyle(
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w700,
                      color:
                          Color(0xFF1976D2),
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

class _InformationCard
    extends StatelessWidget {
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
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE4E7EC),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFEAF4FF),
                  borderRadius:
                      BorderRadius.circular(11),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color:
                      const Color(0xFF1976D2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        Color(0xFF172B4D),
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

class _BulletCard
    extends StatelessWidget {
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
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE4E7EC),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: warning
                    ? const Color(0xFFB54708)
                    : const Color(0xFF1976D2),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        Color(0xFF172B4D),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 8,
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(
                      top: 7,
                    ),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration:
                          BoxDecoration(
                        color: warning
                            ? const Color(
                                0xFFB54708,
                              )
                            : const Color(
                                0xFF1976D2,
                              ),
                        shape:
                            BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: _bodyStyle,
                    ),
                  ),
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
// SAFETY NOTE
// ============================================================

class _SafetyNote extends StatelessWidget {
  const _SafetyNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7),
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFDE7A9),
        ),
      ),
      child: const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: Color(0xFFB54708),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Equipment information is provided for educational purposes. Follow the manufacturer instructions and consult a healthcare professional when necessary.',
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
// AFFILIATE PRODUCTS
// ============================================================

class _AffiliateProductsSection
    extends StatelessWidget {
  const _AffiliateProductsSection({
    required this.products,
    required this.loading,
    required this.userId,
    required this.service,
  });

  final List<AffiliateProductModel> products;
  final bool loading;
  final String? userId;
  final AffiliateProductService service;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const _AffiliateSkeleton();
    }

    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Where to Buy',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF172B4D),
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          'Compare products from our affiliate partners.',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF667085),
          ),
        ),

        const SizedBox(height: 14),

        ...products.map(
          (product) => Padding(
            padding:
                const EdgeInsets.only(
              bottom: 12,
            ),
            child: AffiliateProductCard(
              product: product,
              onBuyPressed: () async {
                final opened =
                    await service
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
// SKELETON
// ============================================================

class _DetailSkeleton
    extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding:
            const EdgeInsets.fromLTRB(
          20,
          8,
          20,
          30,
        ),
        children: const [
          _SkeletonPanel(height: 140),
          SizedBox(height: 14),
          _SkeletonPanel(height: 150),
          SizedBox(height: 14),
          _SkeletonPanel(height: 150),
          SizedBox(height: 14),
          _SkeletonPanel(height: 180),
          SizedBox(height: 14),
          _SkeletonPanel(height: 120),
        ],
      ),
    );
  }
}

class _AffiliateSkeleton
    extends StatelessWidget {
  const _AffiliateSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const _SkeletonLine(
          width: 150,
          height: 21,
        ),
        const SizedBox(height: 12),
        ...List.generate(
          2,
          (_) => const Padding(
            padding:
                EdgeInsets.only(bottom: 10),
            child: _SkeletonPanel(
              height: 100,
            ),
          ),
        ),
      ],
    );
  }
}

class _SkeletonPanel
    extends StatelessWidget {
  const _SkeletonPanel({
    required this.height,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE4E7EC),
        ),
      ),
      child: const Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _SkeletonLine(
            width: 160,
            height: 18,
          ),
          SizedBox(height: 16),
          _SkeletonLine(
            width: double.infinity,
            height: 12,
          ),
          SizedBox(height: 9),
          _SkeletonLine(
            width: double.infinity,
            height: 12,
          ),
          SizedBox(height: 9),
          _SkeletonLine(
            width: 180,
            height: 12,
          ),
        ],
      ),
    );
  }
}

class _SkeletonLine
    extends StatelessWidget {
  const _SkeletonLine({
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE9EEF5),
        borderRadius:
            BorderRadius.circular(8),
      ),
    );
  }
}

// ============================================================
// ERROR
// ============================================================

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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 54,
              color: Color(0xFFD32F2F),
            ),
            const SizedBox(height: 14),
            const Text(
              'Unable to load equipment',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              maxLines: 4,
              overflow:
                  TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF667085),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh,
              ),
              label: const Text(
                'Try again',
              ),
            ),
          ],
        ),
      ),
    );
  }
}