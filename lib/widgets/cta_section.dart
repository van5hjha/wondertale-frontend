import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/theme.dart';

class CtaSection extends StatefulWidget {
  const CtaSection({super.key});

  @override
  State<CtaSection> createState() => _CtaSectionState();
}

class _CtaSectionState extends State<CtaSection> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 768.0;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: isDesktop ? AppConstants.sectionGapDesktop : AppConstants.sectionGapMobile,
        horizontal: isDesktop ? AppConstants.gutter : AppConstants.mobileMargin,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: AppConstants.maxContainerWidth),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppConstants.radiusCta),
              border: Border.all(
                color: AppTheme.outlineVariant.withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: const [
                BoxShadow(
                  color: AppTheme.shadowColor,
                  blurRadius: 30.0,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(
              vertical: isDesktop ? 96.0 : 48.0,
              horizontal: isDesktop ? 96.0 : 24.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  'Ready to see the magic?',
                  style: (isDesktop
                          ? Theme.of(context).textTheme.displayLarge
                          : Theme.of(context).textTheme.displayMedium)
                      ?.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32.0),

                // Subtitle
                Container(
                  constraints: const BoxConstraints(maxWidth: 640.0),
                  child: Text(
                    "It takes less than 2 minutes to create a digital preview of your child's magical book. No credit card required.",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 48.0),

                // Magic CTA Button
                MouseRegion(
                  onEnter: (_) => setState(() => _isHovered = true),
                  onExit: (_) => setState(() => _isHovered = false),
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {},
                    child: AnimatedScale(
                      scale: _isHovered ? 1.05 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.magicButtonColor,
                          borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x4DA258F3), // magic button shadow
                              blurRadius: 20.0,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48.0,
                          vertical: 20.0,
                        ),
                        child: Text(
                          'START MY STORY',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppTheme.onPrimary,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
