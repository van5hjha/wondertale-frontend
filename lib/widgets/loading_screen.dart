import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../core/theme.dart';

class LoadingScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const LoadingScreen({super.key, this.onComplete});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _lottieController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));
    _fadeController.forward();

    _lottieController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600.0;

    final glowSize = isMobile ? 250.0 : 350.0;
    final lottieSize = isMobile ? 180.0 : 260.0;
    final fontSize = isMobile ? 16.0 : 20.0;
    final gapHeight = isMobile ? 16.0 : 24.0;

    return Container(
      color: Colors.white, // White background
      child: Stack(
        children: [
          // 1. Nebula Center Glow
          Positioned.fill(
            child: Center(
              child: Container(
                width: glowSize,
                height: glowSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.secondary.withOpacity(
                        0.15,
                      ), // Softer Magic Lilac glow on white
                      AppTheme.tertiary.withOpacity(
                        0.08,
                      ), // Softer Sunset Gold glow on white
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // 2. Centered Loading Animation & Text
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: lottieSize,
                    height: lottieSize,
                    child: Lottie.asset(
                      'assets/animations/loading.json',
                      controller: _lottieController,
                      fit: BoxFit.contain,
                      onLoaded: (composition) {
                        _lottieController
                          ..duration = composition.duration
                          ..repeat();
                      },
                    ),
                  ),
                  SizedBox(height: gapHeight),
                  Text(
                    'Opening the storybook...',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primary, // Dark text color on white
                      fontSize: fontSize,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w500,
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
