import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/theme.dart';

class BeforeAfterSlider extends StatefulWidget {
  final String beforeImageUrl;
  final String afterImageUrl;

  const BeforeAfterSlider({
    super.key,
    required this.beforeImageUrl,
    required this.afterImageUrl,
  });

  @override
  State<BeforeAfterSlider> createState() => _BeforeAfterSliderState();
}

class _BeforeAfterSliderState extends State<BeforeAfterSlider> with TickerProviderStateMixin {
  double _percent = 0.5; // Starts at 50% split
  AnimationController? _controller;
  AnimationController? _sparkleController;
  bool _isUserInteracting = false;

  @override
  void initState() {
    super.initState();
    // Loop sweep between 0.2 and 0.8
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
      lowerBound: 0.2,
      upperBound: 0.8,
    );

    _controller?.addListener(() {
      if (mounted && !_isUserInteracting) {
        setState(() {
          _percent = _controller!.value;
        });
      }
    });

    // Loop continuously for sparkle animations
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _startAutoPlay();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _sparkleController?.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    if (_isUserInteracting) return;
    // Set the controller value to current percent clamped to bounds to avoid jumps
    _controller?.value = _percent.clamp(0.2, 0.8);
    _controller?.repeat(reverse: true);
  }

  void _onInteractionStart() {
    if (!_isUserInteracting) {
      setState(() {
        _isUserInteracting = true;
      });
      _controller?.stop();
    }
  }

  void _onInteractionEnd() {
    if (_isUserInteracting) {
      setState(() {
        _isUserInteracting = false;
      });
      _startAutoPlay();
    }
  }

  void _updateDragPosition(double localX, double maxWidth) {
    _onInteractionStart();
    setState(() {
      _percent = (localX / maxWidth).clamp(0.0, 1.0);
    });
  }

  Widget _buildImage(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return Image.network(
        url,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      );
    } else {
      return Image.asset(
        url,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      );
    }
  }

  Widget _buildSparklingStar(double phaseOffset, double size) {
    return AnimatedBuilder(
      animation: _sparkleController!,
      builder: (context, child) {
        final rotationValue = (_sparkleController!.value * 2 * pi) + phaseOffset;
        final scaleValue = 0.8 + 0.2 * sin((_sparkleController!.value * 2 * pi) + phaseOffset * 4);
        
        return Transform.translate(
          offset: Offset(0, 3.0 * cos((_sparkleController!.value * 2 * pi) + phaseOffset * 2)),
          child: Transform.rotate(
            angle: rotationValue,
            child: Transform.scale(
              scale: scaleValue,
              child: Icon(
                Icons.auto_awesome,
                color: const Color(0xFFFFF59D), // Warm glowing gold
                size: size,
                shadows: [
                  Shadow(
                    color: const Color(0xFFFFD54F).withOpacity(0.8),
                    blurRadius: 14.0,
                  ),
                  Shadow(
                    color: Colors.white,
                    blurRadius: 4.0,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          return MouseRegion(
            onHover: (event) {
              _updateDragPosition(event.localPosition.dx, width);
            },
            onExit: (_) {
              _onInteractionEnd();
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragUpdate: (details) {
                _updateDragPosition(details.localPosition.dx, width);
              },
              onHorizontalDragEnd: (_) => _onInteractionEnd(),
              onHorizontalDragCancel: () => _onInteractionEnd(),
              onTapDown: (details) {
                _updateDragPosition(details.localPosition.dx, width);
              },
              onTapUp: (_) => _onInteractionEnd(),
              onTapCancel: () => _onInteractionEnd(),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppConstants.radiusCard),
                  boxShadow: const [
                    BoxShadow(
                      color: AppTheme.shadowColor,
                      blurRadius: 30.0,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    // 1. Base "After" Image (Magical Art) - Right side background
                    Positioned.fill(
                      child: _buildImage(
                        widget.afterImageUrl,
                      ),
                    ),

                    // 2. Feather-Blended "Before" Image (Real Photo)
                    Positioned.fill(
                      child: ShaderMask(
                        shaderCallback: (rect) {
                          return LinearGradient(
                            colors: const [Colors.black, Colors.transparent],
                            stops: [
                              (_percent - 0.03).clamp(0.0, 1.0),
                              (_percent + 0.03).clamp(0.0, 1.0),
                            ],
                          ).createShader(rect);
                        },
                        blendMode: BlendMode.dstIn,
                        child: _buildImage(
                          widget.beforeImageUrl,
                        ),
                      ),
                    ),

                    // 3. Magical Stars in the middle of the slider
                    Positioned(
                      left: width * _percent - 24.0,
                      top: 0.0,
                      bottom: 0.0,
                      width: 48.0,
                      child: IgnorePointer(
                        child: Stack(
                          children: [
                            // Top Star
                            Positioned(
                              top: height * 0.2 - 10,
                              left: 14.0,
                              child: _buildSparklingStar(1.0, 18.0),
                            ),
                            // Middle Star (Larger)
                            Positioned(
                              top: height * 0.5 - 15,
                              left: 9.0,
                              child: _buildSparklingStar(2.5, 28.0),
                            ),
                            // Bottom Star
                            Positioned(
                              top: height * 0.8 - 11,
                              left: 13.0,
                              child: _buildSparklingStar(4.0, 22.0),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 4. "Real Photo" Tag (Bottom Left)
                    Positioned(
                      bottom: 16.0,
                      left: 16.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                          child: Container(
                            color: Colors.white.withOpacity(0.6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 6.0,
                            ),
                            child: Text(
                              'Real Photo',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: AppTheme.primary,
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 5. "Magic Art" Tag (Bottom Right)
                    Positioned(
                      bottom: 16.0,
                      right: 16.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                          child: Container(
                            color: AppTheme.secondary.withOpacity(0.8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 6.0,
                            ),
                            child: Text(
                              'Magic Art',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: AppTheme.onPrimary,
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // 6. Border overlay to prevent subpixel leaks and white space gaps
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppConstants.radiusCard),
                            border: Border.all(color: Colors.white, width: 4.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
