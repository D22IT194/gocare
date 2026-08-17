import 'package:flutter/material.dart';

import '../models/affiliate_product_model.dart';

class AffiliateProductCard extends StatelessWidget {
  const AffiliateProductCard({
    super.key,
    required this.product,
    required this.onBuyPressed,
    this.onProductPressed,
  });

  final AffiliateProductModel product;
  final VoidCallback onBuyPressed;
  final VoidCallback? onProductPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onProductPressed,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE4E7EC),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --------------------------------------------------
              // SPONSORED
              // --------------------------------------------------

              if (product.isSponsored)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4E5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.campaign_outlined,
                        size: 14,
                        color: Color(0xFFB54708),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Sponsored',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFB54708),
                        ),
                      ),
                    ],
                  ),
                ),

              if (product.isSponsored)
                const SizedBox(height: 12),

              // --------------------------------------------------
              // PRODUCT ROW
              // --------------------------------------------------

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProductImage(
                    imageUrl: product.imageUrl,
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          maxLines: 2,
                          overflow:
                              TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight:
                                FontWeight.w700,
                            color: Color(0xFF172B4D),
                          ),
                        ),

                        if (product.merchant != null &&
                            product.merchant!
                                .trim()
                                .isNotEmpty) ...[
                          const SizedBox(height: 5),
                          Text(
                            product.merchant!,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color:
                                  Color(0xFF667085),
                            ),
                          ),
                        ],

                        const SizedBox(height: 8),

                        if (product.rating != null)
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 16,
                                color:
                                    Color(0xFFF59E0B),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                product.rating!
                                    .toStringAsFixed(1),
                                style:
                                    const TextStyle(
                                  fontSize: 12,
                                  fontWeight:
                                      FontWeight.w700,
                                  color:
                                      Color(0xFF344054),
                                ),
                              ),
                              if (product.reviewCount !=
                                  null) ...[
                                const SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  '(${product.reviewCount})',
                                  style:
                                      const TextStyle(
                                    fontSize: 11,
                                    color:
                                        Color(0xFF98A2B3),
                                  ),
                                ),
                              ],
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // --------------------------------------------------
              // PRICE
              // --------------------------------------------------

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.end,
                children: [
                  if (product.price != null)
                    Text(
                      _formatPrice(
                        product.price!,
                      ),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.w800,
                        color: Color(0xFF172B4D),
                      ),
                    ),

                  if (product.originalPrice != null &&
                      product.price != null &&
                      product.originalPrice! >
                          product.price!) ...[
                    const SizedBox(width: 8),
                    Text(
                      _formatPrice(
                        product.originalPrice!,
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        decoration:
                            TextDecoration.lineThrough,
                        color: Color(0xFF98A2B3),
                      ),
                    ),
                  ],

                  const Spacer(),

                  FilledButton.icon(
                    onPressed: onBuyPressed,
                    icon: const Icon(
                      Icons.open_in_new,
                      size: 17,
                    ),
                    label: const Text(
                      'Buy Now',
                    ),
                    style: FilledButton.styleFrom(
                      minimumSize:
                          const Size(0, 42),
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPrice(double value) {
    return '₹${value.toStringAsFixed(0)}';
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({
    this.imageUrl,
  });

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final hasImage =
        imageUrl != null && imageUrl!.trim().isNotEmpty;

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4FF),
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) {
                return const _Placeholder();
              },
              loadingBuilder:
                  (context, child, progress) {
                if (progress == null) {
                  return child;
                }

                return const _Placeholder();
              },
            )
          : const _Placeholder(),
    );
  }
}

class _Placeholder
    extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.shopping_bag_outlined,
        size: 32,
        color: Color(0xFF1976D2),
      ),
    );
  }
}