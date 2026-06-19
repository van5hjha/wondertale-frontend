import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../core/preview_api_service.dart';
import '../models/product.dart';
import '../widgets/navbar.dart';
import '../widgets/footer.dart';
import '../widgets/stardust_particles.dart';
import 'preview_view.dart';
import 'products_view.dart';

class PreviewLoadingView extends StatefulWidget {
  final Product product;
  final String contactEmail;
  final String childName;
  final String ageRange;
  final String gender;
  final String bookType;
  final List<PlatformFile> photos;

  const PreviewLoadingView({
    super.key,
    required this.product,
    required this.contactEmail,
    required this.childName,
    required this.ageRange,
    required this.gender,
    required this.bookType,
    required this.photos,
  });

  @override
  State<PreviewLoadingView> createState() => _PreviewLoadingViewState();
}

class _PreviewLoadingViewState extends State<PreviewLoadingView> with TickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  Map<String, dynamic>? _loadingData;
  bool _isLoadingJson = true;

  double _progress = 10.0;
  List<String> _teasers = [];
  String _currentTeaser = 'Mixing the stardust...';
  int _teaserIndex = 0;

  Timer? _pollingTimer;
  Timer? _teaserTimer;

  final PreviewApiService _apiService = PreviewApiService();
  String? _errorMessage;
  bool _isFailed = false;

  @override
  void initState() {
    super.initState();

    // Floating animation for central image
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: 0.0, end: -20.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Pulsing animation for glowing auto-fix-high icon
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _loadJsonData();
  }

  Future<void> _loadJsonData() async {
    try {
      final String response = await rootBundle.loadString('assets/data/preview_loading.json');
      final data = json.decode(response);
      if (mounted) {
        setState(() {
          _loadingData = data;
          _isLoadingJson = false;
          _teasers = List<String>.from(data['teasers'] ?? []);
          _currentTeaser = _teasers.isNotEmpty ? _teasers[0] : 'Mixing the stardust...';
        });
        _startPreviewPipeline();
        _startTeaserTimer();
      }
    } catch (e) {
      debugPrint('Error loading preview loading JSON: $e');
    }
  }

  void _startTeaserTimer() {
    _teaserTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_teasers.isNotEmpty) {
          _teaserIndex = (_teaserIndex + 1) % _teasers.length;
          _currentTeaser = _teasers[_teaserIndex];
        }
      });
    });
  }

  Future<void> _startPreviewPipeline() async {
    try {
      setState(() {
        _progress = 15.0;
        _currentTeaser = 'Uploading photos & initializing session...';
      });

      // 1. Create preview request
      final requestId = await _apiService.createPreviewRequest(
        productId: widget.product.id,
        bookTemplateId: widget.product.bookTemplateId,
        contactEmail: widget.contactEmail,
        childName: widget.childName,
        ageRange: widget.ageRange,
        gender: widget.gender,
        photos: widget.photos,
      );


      if (!mounted) return;
      setState(() {
        _progress = 35.0;
        _currentTeaser = 'Queuing ComfyUI rendering...';
      });

      // 2. Start generation
      await _apiService.startPreviewGeneration(requestId);

      if (!mounted) return;
      setState(() {
        _progress = 50.0;
        _currentTeaser = 'Generating personalized illustrations...';
      });

      // 3. Poll status
      _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
        if (!mounted) {
          timer.cancel();
          return;
        }

        try {
          final result = await _apiService.pollPreviewStatus(requestId);
          final status = result['status'] as String;
          final List<String> pages = List<String>.from(result['pages'] ?? []);

          if (!mounted) {
            timer.cancel();
            return;
          }

          if (status == 'completed') {
            timer.cancel();
            setState(() {
              _progress = 100.0;
              _currentTeaser = 'Preview ready! Launching...';
            });
            Future.delayed(const Duration(milliseconds: 600), () {
              if (mounted) {
                _navigateToPreview(requestId, pages);
              }
            });
          } else if (status == 'failed') {
            timer.cancel();
            setState(() {
              _isFailed = true;
              _errorMessage = 'AI illustration generation failed in the backend.';
            });
          } else {
            // Keep polling, advance progress asymptotically toward 95%
            setState(() {
              if (_progress < 95.0) {
                _progress += (95.0 - _progress) * 0.15;
              }
            });
          }
        } catch (e) {
          debugPrint('Error polling status: $e');
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isFailed = true;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  void _navigateToPreview(String requestId, List<String> generatedPageUrls) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PreviewView(
          product: widget.product,
          childName: widget.childName,
          ageRange: widget.ageRange,
          gender: widget.gender,
          bookType: widget.bookType,
          generatedPageUrls: generatedPageUrls,
          previewRequestId: requestId,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    _pollingTimer?.cancel();
    _teaserTimer?.cancel();
    super.dispose();
  }

  IconData _getFactIcon(String? iconName) {
    switch (iconName) {
      case 'rocket_launch':
        return Icons.rocket_launch;
      case 'nightlight_round':
        return Icons.nightlight_round;
      case 'sunny':
        return Icons.wb_sunny;
      default:
        return Icons.lightbulb_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 768.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: NavBar(
        activeIndex: -1,
        onHomeTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
        onExploreStoriesTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
        onHowItWorksTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
        onPricingTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
        onCreatePreviewTap: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const ProductsView()),
          );
        },
      ),
      body: Stack(
        children: [
          // 1. Drifting background particles
          const Positioned.fill(
            child: StardustParticles(),
          ),

          // 2. Main content view
          _isLoadingJson
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(AppTheme.secondary),
                  ),
                )
              : SingleChildScrollView(
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: AppConstants.maxContainerWidth),
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? AppConstants.gutter : AppConstants.mobileMargin,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 140.0), // Clearing navbar

                          // Magical image section with floating & glows
                          SizedBox(
                            width: isDesktop ? 320.0 : 260.0,
                            height: isDesktop ? 320.0 : 260.0,
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: [
                                // Glowing background radial circle
                                Positioned(
                                  top: 10,
                                  child: Container(
                                    width: isDesktop ? 280.0 : 220.0,
                                    height: isDesktop ? 280.0 : 220.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppTheme.secondary.withOpacity(0.08),
                                    ),
                                  ),
                                ),

                                // Floating image container
                                AnimatedBuilder(
                                  animation: _floatAnimation,
                                  builder: (context, child) {
                                    return Transform.translate(
                                      offset: Offset(0.0, _floatAnimation.value),
                                      child: child,
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.secondary.withOpacity(0.15),
                                          blurRadius: 40.0,
                                          offset: const Offset(0, 20),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                                      child: Image.network(
                                        _loadingData?['hovering_image'] ?? '',
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          color: AppTheme.surfaceContainerLow,
                                          child: const Center(
                                            child: Icon(
                                              Icons.broken_image,
                                              color: AppTheme.secondary,
                                              size: 48.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Bounce/Pulse star icon
                                Positioned(
                                  top: -16.0,
                                  right: -16.0,
                                  child: AnimatedBuilder(
                                    animation: _floatAnimation,
                                    builder: (context, child) {
                                      return Transform.translate(
                                        offset: Offset(0, _floatAnimation.value * 0.4),
                                        child: const Icon(
                                          Icons.star_rounded,
                                          color: AppTheme.tertiary,
                                          size: 44.0,
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                // Pulsing magic wand icon
                                Positioned(
                                  bottom: -16.0,
                                  left: -16.0,
                                  child: AnimatedBuilder(
                                    animation: _pulseAnimation,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: _pulseAnimation.value,
                                        child: const Icon(
                                          Icons.auto_fix_high_rounded,
                                          color: AppTheme.secondary,
                                          size: 36.0,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 56.0),

                          // Progress tracker or error box
                          _isFailed
                              ? Container(
                                  constraints: const BoxConstraints(maxWidth: 440.0),
                                  padding: const EdgeInsets.all(28.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.error.withOpacity(0.08),
                                        blurRadius: 30.0,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: AppTheme.error.withOpacity(0.15),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 56.0,
                                        height: 56.0,
                                        decoration: BoxDecoration(
                                          color: AppTheme.error.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.error_outline_rounded,
                                          color: AppTheme.error,
                                          size: 32.0,
                                        ),
                                      ),
                                      const SizedBox(height: 20.0),
                                      Text(
                                        'Magic Failed',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 22.0,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.error,
                                        ),
                                      ),
                                      const SizedBox(height: 12.0),
                                      Text(
                                        _errorMessage ?? 'An error occurred during preview generation. Please check the backend services.',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14.0,
                                          color: AppTheme.onSurfaceVariant,
                                          height: 1.5,
                                        ),
                                      ),
                                      const SizedBox(height: 28.0),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 50.0,
                                        child: ElevatedButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppTheme.primary,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(AppConstants.radiusDefault),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: Text(
                                            'Go Back & Try Again',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(
                                  constraints: const BoxConstraints(maxWidth: 440.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            'Magic in Progress...',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 22.0,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.primary,
                                            ),
                                          ),
                                          Text(
                                            '${_progress.toInt()}%',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.secondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16.0),

                                      // Custom progress track & fill
                                      Container(
                                        height: 12.0,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.05),
                                          borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                                        ),
                                        child: FractionallySizedBox(
                                          widthFactor: _progress / 100.0,
                                          alignment: Alignment.centerLeft,
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 300),
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Color(0xFF812DC6), // Magic Lilac
                                                  Color(0xFFDFB7FF), // Soft Lilac
                                                ],
                                              ),
                                              borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFF812DC6).withOpacity(0.3),
                                                  blurRadius: 10.0,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16.0),

                                      // Rotating status teasers with cross-fade transition
                                      Container(
                                        height: 36.0,
                                        alignment: Alignment.center,
                                        child: AnimatedSwitcher(
                                          duration: const Duration(milliseconds: 500),
                                          transitionBuilder: (child, animation) {
                                            return FadeTransition(
                                              opacity: animation,
                                              child: SlideTransition(
                                                position: Tween<Offset>(
                                                  begin: const Offset(0.0, 0.2),
                                                  end: Offset.zero,
                                                ).animate(animation),
                                                child: child,
                                              ),
                                            );
                                          },
                                          child: Text(
                                            _currentTeaser,
                                            key: ValueKey<String>(_currentTeaser),
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 15.0,
                                              color: AppTheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                          const SizedBox(height: 64.0),

                          // Space facts responsive grid
                          isDesktop
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: _buildFactCards(),
                                )
                              : Column(
                                  children: _buildFactCards()
                                      .map((card) => Padding(
                                            padding: const EdgeInsets.only(bottom: 20.0),
                                            child: card,
                                          ))
                                      .toList(),
                                ),

                          const SizedBox(height: 80.0),

                          // Standardized footer
                          const Footer(),
                        ],
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  List<Widget> _buildFactCards() {
    final list = _loadingData?['facts'] as List<dynamic>? ?? [];
    return list.map<Widget>((fact) {
      final card = ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              border: Border.all(
                color: Colors.black.withOpacity(0.05),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 24.0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    color: AppTheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusDefault),
                  ),
                  child: Center(
                    child: Icon(
                      _getFactIcon(fact['icon']),
                      color: AppTheme.secondary,
                      size: 20.0,
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                // Title
                Text(
                  fact['title'] ?? '',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 17.0,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 8.0),
                // Description
                Text(
                  fact['description'] ?? '',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.0,
                    color: AppTheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      if (MediaQuery.of(context).size.width >= 768.0) {
        return Expanded(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: card,
        ));
      } else {
        return card;
      }
    }).toList();
  }
}
