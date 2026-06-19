import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/theme.dart';

class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 768.0;

    return Container(
      color: AppTheme.primary,
      padding: EdgeInsets.symmetric(
        vertical: isDesktop ? AppConstants.sectionGapDesktop : AppConstants.sectionGapMobile,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: AppConstants.maxContainerWidth),
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? AppConstants.gutter : AppConstants.mobileMargin,
          ),
          child: Column(
            children: [
              // Header
              Text(
                'HOW IT WORKS',
                style: (isDesktop
                        ? Theme.of(context).textTheme.headlineLarge
                        : Theme.of(context).textTheme.displayMedium)
                    ?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8.0),
              const Text(
                '3 Simple Steps to Magic',
                style: TextStyle(
                  color: AppTheme.onPrimaryContainer,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 64.0),

              // Steps Grid/List
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildStepCard(
                        context,
                        icon: Icons.auto_stories,
                        iconColor: AppTheme.secondary,
                        bgColor: AppTheme.secondary.withOpacity(0.2),
                        title: 'Pick a Book',
                        description: 'Choose from epic space travels, dinosaur jungles, or future career adventures.',
                      ),
                    ),
                    const SizedBox(width: 24.0),
                    Expanded(
                      child: _buildStepCard(
                        context,
                        icon: Icons.add_a_photo,
                        iconColor: AppTheme.tertiary,
                        bgColor: AppTheme.tertiary.withOpacity(0.2),
                        title: 'Upload Photo',
                        description: 'Our AI magic maps their face into every single illustration of the story.',
                      ),
                    ),
                    const SizedBox(width: 24.0),
                    Expanded(
                      child: _buildStepCard(
                        context,
                        icon: Icons.shopping_bag,
                        iconColor: AppTheme.secondary,
                        bgColor: AppTheme.secondary.withOpacity(0.2),
                        title: 'Preview & Order',
                        description: "Flip through your entire book for free. Only pay when you're in love with it.",
                      ),
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildStepCard(
                      context,
                      icon: Icons.auto_stories,
                      iconColor: AppTheme.secondary,
                      bgColor: AppTheme.secondary.withOpacity(0.2),
                      title: 'Pick a Book',
                      description: 'Choose from epic space travels, dinosaur jungles, or future career adventures.',
                    ),
                    const SizedBox(height: 24.0),
                    _buildStepCard(
                      context,
                      icon: Icons.add_a_photo,
                      iconColor: AppTheme.tertiary,
                      bgColor: AppTheme.tertiary.withOpacity(0.2),
                      title: 'Upload Photo',
                      description: 'Our AI magic maps their face into every single illustration of the story.',
                    ),
                    const SizedBox(height: 24.0),
                    _buildStepCard(
                      context,
                      icon: Icons.shopping_bag,
                      iconColor: AppTheme.secondary,
                      bgColor: AppTheme.secondary.withOpacity(0.2),
                      title: 'Preview & Order',
                      description: "Flip through your entire book for free. Only pay when you're in love with it.",
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String description,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(AppConstants.radiusFeatureCard),
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon Container
          Container(
            width: 80.0,
            height: 80.0,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 36.0,
            ),
          ),
          const SizedBox(height: 24.0),

          // Title
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16.0),

          // Description
          Text(
            description,
            style: const TextStyle(
              color: AppTheme.onPrimaryContainer,
              fontSize: 16.0,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
