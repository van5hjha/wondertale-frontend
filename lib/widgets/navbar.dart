import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../core/legal_config.dart';

class NavBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onHomeTap;
  final ValueChanged<String?>? onExploreStoriesTap;
  final VoidCallback? onHowItWorksTap;
  final VoidCallback? onPricingTap;
  final VoidCallback? onCreatePreviewTap;
  final bool showCreatePreviewButton;
  final int activeIndex;

  const NavBar({
    super.key,
    this.onHomeTap,
    this.onExploreStoriesTap,
    this.onHowItWorksTap,
    this.onPricingTap,
    this.onCreatePreviewTap,
    this.showCreatePreviewButton = true,
    this.activeIndex = 0,
  });

  Widget _buildProductsDropdown(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Products',
      offset: const Offset(0, 40),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusDefault),
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Products',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: activeIndex == 0 ? FontWeight.bold : FontWeight.normal,
                    color: activeIndex == 0 ? AppTheme.primary : AppTheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(width: 4.0),
            Icon(
              Icons.keyboard_arrow_down,
              size: 18.0,
              color: activeIndex == 0 ? AppTheme.primary : AppTheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
      onSelected: (value) {
        if (onExploreStoriesTap != null) {
          onExploreStoriesTap!(value == 'all' ? null : value);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'all',
          child: Text('All Products'),
        ),
        const PopupMenuItem(
          value: 'storybook',
          child: Text('Storybooks'),
        ),
        const PopupMenuItem(
          value: 'frame',
          child: Text('Memory Frames'),
        ),
        const PopupMenuItem(
          value: 'sticker',
          child: Text('Stickers'),
        ),
        const PopupMenuItem(
          value: 'label',
          child: Text('Name Labels'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 768.0;
    final showAnnouncement =
        LegalConfig.announcementEnabled && LegalConfig.announcementText.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showAnnouncement)
          Container(
            width: double.infinity,
            color: AppTheme.secondary,
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            alignment: Alignment.center,
            child: Text(
              LegalConfig.announcementText,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppTheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    fontSize: 13.0,
                  ),
            ),
          ),
        ClipRect(
          child: Builder(
            builder: (context) {
              final isMobile = width < 600.0;
              final navbarContainer = Container(
                height: 100.0,
                decoration: BoxDecoration(
                  color: isMobile ? AppTheme.surface : AppTheme.surface.withOpacity(0.8),
                  border: const Border(
                    bottom: BorderSide(
                      color: Color(0x1AC9C5CE),
                      width: 1.0,
                    ),
                  ),
                ),
                alignment: Alignment.center,
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: AppConstants.maxContainerWidth,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop
                        ? AppConstants.gutter
                        : AppConstants.mobileMargin,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Brand Logo
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: onHomeTap,
                          child: Image.asset(
                            'assets/images/logo.png',
                            height: 100.0,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      // Desktop Links
                      if (isDesktop)
                        Row(
                          children: [
                            _buildProductsDropdown(context),
                            const SizedBox(width: 32.0),
                            _buildNavLink(
                              context,
                              'How It Works',
                              onHowItWorksTap,
                              isActive: activeIndex == 1,
                            ),
                            const SizedBox(width: 32.0),
                            _buildNavLink(
                              context,
                              'Pricing',
                              onPricingTap,
                              isActive: activeIndex == 2,
                            ),
                          ],
                        ),

                      // Action Button
                      if (showCreatePreviewButton)
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: onCreatePreviewTap,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.magicButtonColor,
                                borderRadius: BorderRadius.circular(
                                  AppConstants.radiusFull,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x4DA258F3),
                                    blurRadius: 15.0,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                                vertical: 10.0,
                              ),
                              child: Text(
                                'CREATE PREVIEW',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      color: AppTheme.onPrimary,
                                      letterSpacing: 0.8,
                                    ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );

              return isMobile
                  ? navbarContainer
                  : BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                      child: navbarContainer,
                    );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNavLink(
    BuildContext context,
    String title,
    VoidCallback? onTap, {
    bool isActive = false,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          decoration: isActive
              ? const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppTheme.primary, width: 2.0),
                  ),
                )
              : null,
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? AppTheme.primary : AppTheme.onSurfaceVariant,
                ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize {
    final showAnnouncement =
        LegalConfig.announcementEnabled && LegalConfig.announcementText.isNotEmpty;
    return Size.fromHeight(showAnnouncement ? 136.0 : 100.0);
  }
}
