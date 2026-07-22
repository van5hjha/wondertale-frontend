import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../core/constants.dart';
import '../core/theme.dart';
import '../core/legal_config.dart';
import '../views/info_view.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  void _shareWebsite(BuildContext context) {
    final String shareUrl = kIsWeb ? Uri.base.toString() : 'https://wondertale.in';

    // Copy website link to clipboard
    Clipboard.setData(ClipboardData(text: shareUrl));

    // Display floating SnackBar notification
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20.0),
            SizedBox(width: 12.0),
            Expanded(
              child: Text(
                '✨ Link copied to clipboard! Share Wondertale with your friends & family.',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.secondary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusDefault),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1024.0;

    return Container(
      color: AppTheme.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(
        vertical: AppConstants.sectionGapMobile,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: AppConstants.maxContainerWidth,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop
                ? AppConstants.gutter
                : AppConstants.mobileMargin,
          ),
          child: Flex(
            direction: isDesktop ? Axis.horizontal : Axis.vertical,
            mainAxisAlignment: isDesktop
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Column 1: Brand Info
              Column(
                crossAxisAlignment: isDesktop
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 48.0,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    '© 2026 Wondertale. Hand-crafted with magic.',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppTheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 320.0),
                    child: Text(
                      'Operated by ${LegalConfig.entityName}.\nReg. Office: ${LegalConfig.registeredAddress}',
                      textAlign: isDesktop ? TextAlign.left : TextAlign.center,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppTheme.onSurfaceVariant.withOpacity(0.6),
                        fontSize: 10.0,
                        fontWeight: FontWeight.normal,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              if (!isDesktop) const SizedBox(height: 32.0),

              // Column 2: Quick Links
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 24.0,
                runSpacing: 12.0,
                children: [
                  _buildFooterLink(context, 'Privacy Policy', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const InfoView(initialTabIndex: 0),
                      ),
                    );
                  }),
                  _buildFooterLink(context, 'Terms of Service', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const InfoView(initialTabIndex: 1),
                      ),
                    );
                  }),
                  _buildFooterLink(context, 'Refund Policy', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const InfoView(initialTabIndex: 2),
                      ),
                    );
                  }),
                  _buildFooterLink(context, 'Shipping Policy', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const InfoView(initialTabIndex: 3),
                      ),
                    );
                  }),
                  _buildFooterLink(context, 'Contact Us', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const InfoView(initialTabIndex: 4),
                      ),
                    );
                  }),
                ],
              ),
              if (!isDesktop) const SizedBox(height: 32.0),

              // Column 3: Social / Utility Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialButton(
                    context,
                    Icons.share,
                    tooltip: 'Share Wondertale',
                    onTap: () => _shareWebsite(context),
                  ),
                  const SizedBox(width: 16.0),
                  _buildSocialButton(
                    context,
                    Icons.mail_outline,
                    tooltip: 'Contact Support',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const InfoView(initialTabIndex: 4),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterLink(
    BuildContext context,
    String title,
    VoidCallback onTap,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppTheme.onSurfaceVariant,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(
    BuildContext context,
    IconData icon, {
    VoidCallback? onTap,
    String? tooltip,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 40.0,
            height: 40.0,
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadowColor,
                  blurRadius: 4.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: AppTheme.primary, size: 20.0),
          ),
        ),
      ),
    );
  }
}
