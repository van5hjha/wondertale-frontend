import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../core/legal_config.dart';
import '../views/products_view.dart';

class PricingSection extends StatefulWidget {
  const PricingSection({super.key});

  @override
  State<PricingSection> createState() => _PricingSectionState();
}

class _PricingSectionState extends State<PricingSection> {
  bool _isSoftcoverHovered = false;
  bool _isHardcoverHovered = false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 768.0;

    return Container(
      color: AppTheme.surfaceContainerLowest,
      padding: EdgeInsets.symmetric(
        vertical: isDesktop ? AppConstants.sectionGapDesktop : AppConstants.sectionGapMobile,
        horizontal: isDesktop ? AppConstants.gutter : AppConstants.mobileMargin,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: AppConstants.maxContainerWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                'SIMPLE, TRANSPARENT PRICING',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12.0),
              Text(
                'Create a free digital preview. Only pay for the high-quality print when you fall in love with it.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.onSurfaceVariant,
                      fontSize: 16.0,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 64.0),

              // Cards Layout
              isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: MouseRegion(
                            onEnter: (_) => setState(() => _isSoftcoverHovered = true),
                            onExit: (_) => setState(() => _isSoftcoverHovered = false),
                            child: _buildPricingCard(
                              context,
                              title: 'SOFTCOVER BOOK',
                              price: '999',
                              originalPrice: '1,499',
                              description: 'Perfect for lightweight reading & everyday bedtime story magic.',
                              features: [
                                '24-28 Custom Illustrated Pages',
                                'High-res AI Face Mapping',
                                'Thick premium matte paper',
                                'Flexible durable soft cover',
                                'Free Shipping across India',
                              ],
                              isPopular: false,
                              isHovered: _isSoftcoverHovered,
                            ),
                          ),
                        ),
                        const SizedBox(width: 32.0),
                        Expanded(
                          child: MouseRegion(
                            onEnter: (_) => setState(() => _isHardcoverHovered = true),
                            onExit: (_) => setState(() => _isHardcoverHovered = false),
                            child: _buildPricingCard(
                              context,
                              title: 'HARDCOVER KEEPSAKE',
                              price: '1,499',
                              originalPrice: '2,299',
                              description: 'Our premium library-grade book. Built to last generations.',
                              features: [
                                '24-28 Custom Illustrated Pages',
                                'High-res AI Face Mapping',
                                'Heavy rigid board covers',
                                'Sturdy lay-flat binding',
                                'Free Shipping across India',
                              ],
                              isPopular: true,
                              isHovered: _isHardcoverHovered,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _buildPricingCard(
                          context,
                          title: 'SOFTCOVER BOOK',
                          price: '999',
                          originalPrice: '1,499',
                          description: 'Perfect for lightweight reading & everyday bedtime story magic.',
                          features: [
                            '24-28 Custom Illustrated Pages',
                            'High-res AI Face Mapping',
                            'Thick premium matte paper',
                            'Flexible durable soft cover',
                            'Free Shipping across India',
                          ],
                          isPopular: false,
                          isHovered: false,
                        ),
                        const SizedBox(height: 32.0),
                        _buildPricingCard(
                          context,
                          title: 'HARDCOVER KEEPSAKE',
                          price: '1,499',
                          originalPrice: '2,299',
                          description: 'Our premium library-grade book. Built to last generations.',
                          features: [
                            '24-28 Custom Illustrated Pages',
                            'High-res AI Face Mapping',
                            'Heavy rigid board covers',
                            'Sturdy lay-flat binding',
                            'Free Shipping across India',
                          ],
                          isPopular: true,
                          isHovered: false,
                        ),
                      ],
                    ),
              
              const SizedBox(height: 64.0),

              // Trust & Delivery Badges
              _buildTrustBadges(context, isDesktop),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPricingCard(
    BuildContext context, {
    required String title,
    required String price,
    required String originalPrice,
    required String description,
    required List<String> features,
    required bool isPopular,
    required bool isHovered,
  }) {
    return AnimatedScale(
      scale: isHovered ? 1.02 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusCard),
          border: Border.all(
            color: isPopular
                ? AppTheme.secondary
                : (isHovered ? AppTheme.primary.withOpacity(0.2) : AppTheme.primary.withOpacity(0.06)),
            width: isPopular ? 2.5 : 1.5,
          ),
          boxShadow: isHovered
              ? const [
                  BoxShadow(
                    color: Color(0x15A258F3),
                    blurRadius: 30.0,
                    offset: Offset(0, 10),
                    spreadRadius: 2.0,
                  )
                ]
              : const [
                  BoxShadow(
                    color: AppTheme.shadowColor,
                    blurRadius: 15.0,
                    offset: Offset(0, 4),
                  )
                ],
        ),
        padding: const EdgeInsets.all(40.0),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: isPopular ? AppTheme.secondary : AppTheme.onSurfaceVariant,
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16.0),

                // Price
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      LegalConfig.currencySymbol,
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                            fontSize: 28.0,
                          ),
                    ),
                    Text(
                      price,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                            fontSize: 48.0,
                          ),
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      '${LegalConfig.currencySymbol}$originalPrice',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.onSurfaceVariant.withOpacity(0.5),
                            decoration: TextDecoration.lineThrough,
                            fontSize: 16.0,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 6.0),
                Text(
                  LegalConfig.taxNote,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppTheme.onSurfaceVariant.withOpacity(0.6),
                        fontSize: 11.0,
                        fontWeight: FontWeight.normal,
                      ),
                ),
                const SizedBox(height: 20.0),

                // Description
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.onSurfaceVariant,
                        fontSize: 14.0,
                        height: 1.4,
                      ),
                ),
                const SizedBox(height: 32.0),

                const Divider(),
                const SizedBox(height: 24.0),

                // Features Checklist
                Column(
                  children: features.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: AppTheme.secondary,
                          size: 20.0,
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Text(
                            f,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.primary,
                                  fontSize: 14.0,
                                ),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 24.0),

                // Button
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ProductsView()),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isPopular ? AppTheme.secondary : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppConstants.radiusDefault),
                        border: Border.all(
                          color: AppTheme.secondary,
                          width: 2.0,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      alignment: Alignment.center,
                      child: Text(
                        'CREATE FREE PREVIEW',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: isPopular ? Colors.white : AppTheme.secondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.0,
                              letterSpacing: 0.5,
                            ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (isPopular)
              Positioned(
                top: -60.0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.secondary,
                    borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33A258F3),
                        blurRadius: 10.0,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: const Text(
                    '★ MOST POPULAR',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11.0,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrustBadges(BuildContext context, bool isDesktop) {
    final badges = [
      _buildBadgeItem(
        context,
        icon: Icons.local_shipping,
        title: 'Free Shipping',
        subtitle: LegalConfig.shippingRegions,
      ),
      _buildBadgeItem(
        context,
        icon: Icons.replay_outlined,
        title: 'Reprint Guarantee',
        subtitle: '100% replacement in case of transit damage or printing defects.',
      ),
      _buildBadgeItem(
        context,
        icon: Icons.credit_card,
        title: 'Secure Payments',
        subtitle: 'Processed securely with standard encrypted payment gateways.',
      ),
    ];

    return isDesktop
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: badges.map((b) => Expanded(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: b,
            ))).toList(),
          )
        : Column(
            children: badges.map((b) => Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: b,
            )).toList(),
          );
  }

  Widget _buildBadgeItem(BuildContext context, {required IconData icon, required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          decoration: const BoxDecoration(
            color: AppTheme.secondaryContainer,
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(12.0),
          child: Icon(
            icon,
            color: AppTheme.secondary,
            size: 24.0,
          ),
        ),
        const SizedBox(height: 12.0),
        Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              ),
        ),
        const SizedBox(height: 6.0),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.onSurfaceVariant.withOpacity(0.8),
                fontSize: 12.0,
                height: 1.4,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
