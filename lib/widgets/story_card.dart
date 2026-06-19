import 'dart:async';
import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/theme.dart';

class StoryCard extends StatefulWidget {
  final String title;
  final String ageRange;
  final String description;
  final List<String> imageUrls;
  final VoidCallback onTap;

  const StoryCard({
    super.key,
    required this.title,
    required this.ageRange,
    required this.description,
    required this.imageUrls,
    required this.onTap,
  });

  @override
  State<StoryCard> createState() => _StoryCardState();
}

class _StoryCardState extends State<StoryCard> {
  bool _isHovered = false;
  bool _isButtonHovered = false;
  int _currentImageIndex = 0;
  Timer? _sliderTimer;

  @override
  void initState() {
    super.initState();
    _startSliderTimer();
  }

  @override
  void dispose() {
    _sliderTimer?.cancel();
    super.dispose();
  }

  void _startSliderTimer() {
    if (widget.imageUrls.length <= 1) return;
    _sliderTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _currentImageIndex = (_currentImageIndex + 1) % widget.imageUrls.length;
        });
      }
    });
  }

  Widget _buildImage(String url) {
    return url.startsWith('http')
        ? Image.network(
            url,
            key: ValueKey(url),
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: AppTheme.surfaceContainer,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.secondary,
                    strokeWidth: 2.0,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) => Container(
              color: AppTheme.surfaceContainerLow,
              child: const Center(
                child: Icon(Icons.broken_image, color: AppTheme.outline),
              ),
            ),
          )
        : Image.asset(
            url,
            key: ValueKey(url),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: AppTheme.surfaceContainerLow,
              child: const Center(
                child: Icon(Icons.broken_image, color: AppTheme.outline),
              ),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppConstants.radiusCard),
            border: Border.all(
              color: AppTheme.outlineVariant.withOpacity(0.3),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? const Color(0x1F110F2D) // deeper shadow when hovered
                    : AppTheme.shadowColor,
                blurRadius: _isHovered ? 30.0 : 15.0,
                offset: _isHovered ? const Offset(0, 10) : const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image with hover scale zoom and automatic slider
              AspectRatio(
                aspectRatio: 3 / 2,
                child: ClipRRect(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AnimatedScale(
                        scale: _isHovered ? 1.05 : 1.0,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 800),
                          child: widget.imageUrls.isEmpty
                              ? Container(
                                  key: const ValueKey('empty'),
                                  color: AppTheme.surfaceContainerLow,
                                  child: const Center(
                                    child: Icon(Icons.broken_image, color: AppTheme.outline),
                                  ),
                                )
                              : _buildImage(widget.imageUrls[_currentImageIndex]),
                        ),
                      ),
                      if (widget.imageUrls.length > 1)
                        Positioned(
                          bottom: 12.0,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(widget.imageUrls.length, (index) {
                              final isActive = index == _currentImageIndex;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 3.0),
                                height: 6.0,
                                width: isActive ? 18.0 : 6.0,
                                decoration: BoxDecoration(
                                  color: isActive ? AppTheme.secondary : Colors.white.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(3.0),
                                  boxShadow: isActive
                                      ? [
                                          BoxShadow(
                                            color: AppTheme.secondary.withOpacity(0.4),
                                            blurRadius: 4.0,
                                            spreadRadius: 1.0,
                                          )
                                        ]
                                      : null,
                                ),
                              );
                            }),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
  
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Expanded(
                          child: Text(
                            widget.title,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primary,
                                ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        // Age Badge
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.tertiary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 4.0,
                          ),
                          child: Text(
                            'Age: ${widget.ageRange}',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: AppTheme.onTertiaryContainer,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),
   
                    // Description
                    Text(
                      widget.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.onSurfaceVariant,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16.0),
  
                    // Action Button
                    MouseRegion(
                      onEnter: (_) => setState(() => _isButtonHovered = true),
                      onExit: (_) => setState(() => _isButtonHovered = false),
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: widget.onTap,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          decoration: BoxDecoration(
                            color: _isButtonHovered ? AppTheme.secondary : AppTheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.edit,
                                size: 16.0,
                                color: _isButtonHovered ? AppTheme.onPrimary : AppTheme.primary,
                              ),
                              const SizedBox(width: 8.0),
                              Text(
                                'Personalize',
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                      color: _isButtonHovered ? AppTheme.onPrimary : AppTheme.primary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
