import 'dart:math' as math;
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../core/preview_api_service.dart';
import '../models/product.dart';

enum FlipDirection { forward, backward, none }

class BookWidget extends StatefulWidget {
  final Product product;
  final String childName;
  final String ageRange;
  final String gender;
  final String bookType;
  final Function(int)? onPageChanged;
  final bool isFullScreen;
  final int initialIndex;
  final List<String>? generatedPageUrls;
  final String? previewRequestId;

  const BookWidget({
    super.key,
    required this.product,
    required this.childName,
    required this.ageRange,
    required this.gender,
    required this.bookType,
    this.onPageChanged,
    this.isFullScreen = false,
    this.initialIndex = 0,
    this.generatedPageUrls,
    this.previewRequestId,
  });

  @override
  State<BookWidget> createState() => BookWidgetState();
}

class BookWidgetState extends State<BookWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  FlipDirection _direction = FlipDirection.none;
  late int _currentIndex;
  int get _totalSpreads => math.max(1, (_pageUrls.length / 2).ceil());

  late List<String> _pageUrls;
  final Map<int, bool> _loadingPages = {};
  final PreviewApiService _previewApiService = PreviewApiService();
  final Map<int, Timer?> _pollingTimers = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageUrls = List<String>.from(widget.generatedPageUrls ?? []);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && _direction == FlipDirection.forward) {
        setState(() {
          _currentIndex += 1;
          _direction = FlipDirection.none;
          _controller.reset();
        });
        widget.onPageChanged?.call(_currentIndex);
      } else if (status == AnimationStatus.dismissed && _direction == FlipDirection.backward) {
        setState(() {
          _currentIndex -= 1;
          _direction = FlipDirection.none;
          _controller.reset();
        });
        widget.onPageChanged?.call(_currentIndex);
      }
    });
  }

  @override
  void didUpdateWidget(covariant BookWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.generatedPageUrls != oldWidget.generatedPageUrls) {
      setState(() {
        _pageUrls = List<String>.from(widget.generatedPageUrls ?? []);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _pollingTimers.values.forEach((timer) => timer?.cancel());
    super.dispose();
  }

  int get currentPageNumber => _currentIndex * 2 + 1; // e.g. Spread 0 is page 1 & 2
  int get totalPages => _totalSpreads * 2;

  bool get canFlipForward => _currentIndex < _totalSpreads - 1 && _direction == FlipDirection.none;
  bool get canFlipBackward => _currentIndex > 0 && _direction == FlipDirection.none;

  void flipForward() {
    if (!canFlipForward) return;
    setState(() {
      _direction = FlipDirection.forward;
    });
    _controller.forward(from: 0.0);
  }

  void flipBackward() {
    if (!canFlipBackward) return;
    setState(() {
      _direction = FlipDirection.backward;
    });
    _controller.reverse(from: 1.0);
  }

  // Pronoun mapping replacement helper
  String _personalizeText(String template) {
    String name = widget.childName.trim();
    if (name.isEmpty) name = "The Explorer";

    // Gender rules
    String he = "they";
    String him = "them";
    String his = "their";
    String was = "were";
    String isStr = "are";
    String s = "";

    final genderLower = widget.gender.toLowerCase();
    if (genderLower.contains("boy") || genderLower.contains("he/him")) {
      he = "he";
      him = "him";
      his = "his";
      was = "was";
      isStr = "is";
      s = "s";
    } else if (genderLower.contains("girl") || genderLower.contains("she/her")) {
      he = "she";
      him = "her";
      his = "her";
      was = "was";
      isStr = "is";
      s = "s";
    }

    // Capitalize pronouns when they follow a period or quotes
    String capitalize(String str) {
      if (str.isEmpty) return str;
      return str[0].toUpperCase() + str.substring(1);
    }

    String result = template
        .replaceAll("{name}", name)
        .replaceAll("{he}", he)
        .replaceAll("{him}", him)
        .replaceAll("{his}", his)
        .replaceAll("{was}", was)
        .replaceAll("{is}", isStr)
        .replaceAll("{s}", s);

    // Apply sentence case capitalization for pronouns at start of sentences
    result = result.replaceAllMapped(RegExp(r'([.!?"]\s+){he}'), (match) {
      return match.group(1)! + capitalize(he);
    });
    result = result.replaceAllMapped(RegExp(r'([.!?"]\s+){name}'), (match) {
      return match.group(1)! + capitalize(name);
    });

    return result;
  }

  // Get dynamic template texts for each product
  Map<String, String> _getSpreadData(int index) {
    final prodId = widget.product.id;
    if (prodId == 'galactic-kid') {
      final templates = [
        {
          "title": "Chapter 1: The Spark of Adventure",
          "body": "\"{name} peered through the telescope, eyes wide with wonder. Tonight, the stardust stars {was} calling, and a glowing rocket stood ready for a journey beyond the Milky Way...\""
        },
        {
          "title": "Chapter 2: Into the Cosmic Swirl",
          "body": "\"With a soft hum, the engines ignited! {he} soared past swirling nebulas of purple and blue, feeling weightless, painting the dark sky with {his} glittering stardust paths...\""
        },
        {
          "title": "Chapter 3: Stardust Tea Party",
          "body": "\"On a friendly, floating asteroid, space bunnies served liquid starlight tea. {name} giggled as star-cookies floated around {him}, catching them in mid-air...\""
        },
        {
          "title": "Chapter 4: Saturn's Lullaby",
          "body": "\"{he} soared past the rings of Saturn, looking for the lost star-cookies that had floated away during the great asteroid tea party. Every swirl of space dust hummed a gentle lullaby...\""
        },
        {
          "title": "Chapter 5: Finding the Stardust Star",
          "body": "\"Finally, the legendary Stardust Star appeared, wrapping {name} in a warm, sleepy glow. With a heart full of stardust memories, it {was} time to drift back home to bed...\""
        }
      ];
      return templates[index];
    } else if (prodId == 'jurassic-friend') {
      final templates = [
        {
          "title": "Chapter 1: The Secret Valley",
          "body": "\"{name} stepped through the tall ferns, holding {his} wooden magnifying glass. A giant footprint on the ground suggested a friendly giant {was} nearby...\""
        },
        {
          "title": "Chapter 2: Hello Bronty!",
          "body": "\"Poking out from behind a canopy of leaves {was} a very long neck. A gentle Brontosaurus looked down and offered {him} a sweet, leafy snack with a soft nudge...\""
        },
        {
          "title": "Chapter 3: Dino Tag",
          "body": "\"Small, colorful raptors zipped through the flowers. {name} laughed, playing a game of tag, running under the warm prehistoric sun...\""
        },
        {
          "title": "Chapter 4: Sky High Glide",
          "body": "\"A friendly Pterodactyl swept down, inviting {name} for a ride. Together {he} soared over the sparkling rivers, watching the valley glow below...\""
        },
        {
          "title": "Chapter 5: Sleepy Giants",
          "body": "\"As the volcano blew gentle smoke rings in the orange twilight, the valley settled. {name} snuggled close to Bronty, safe and warm under the starlit canopy...\""
        }
      ];
      return templates[index];
    } else {
      // wild-safari or fallback
      final templates = [
        {
          "title": "Chapter 1: Into the Wild",
          "body": "\"{name} climbed aboard the green safari jeep, wearing {his} tiny explorer hat. The binoculars showed a path leading deep into the golden savannah...\""
        },
        {
          "title": "Chapter 2: Watering Hole Wonders",
          "body": "\"At the blue lake, baby elephants splashed water in the air. {name} waved as a tall giraffe bent down to drink, its spots shimmering in the sun...\""
        },
        {
          "title": "Chapter 3: The Golden Whispers",
          "body": "\"Rustling leaves in the acacia tree revealed a family of playful monkeys. They tossed a sweet mango to {him}, chatter filling the air...\""
        },
        {
          "title": "Chapter 4: The Lion's Pride",
          "body": "\"{name} spotted the majestic Golden Lion resting on a warm rock. The lion gave a gentle, friendly yawn, welcoming the brave little explorer to the pride...\""
        },
        {
          "title": "Chapter 5: Sunset Serenade",
          "body": "\"The sun dipped low, turning the safari sky into a canvas of pink and gold. {he} fell asleep in the jeep, listening to the crickets hum {his} bedtime song...\""
        }
      ];
      return templates[index];
    }
  }

  Widget? _buildRegenerateButton(int pageIndex) {
    if (widget.previewRequestId == null) return null;
    if (pageIndex >= _pageUrls.length) return null;

    final isLeft = pageIndex % 2 == 0;
    
    return Positioned(
      top: 24.0,
      left: 0,
      right: 0,
      child: Center(
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Tooltip(
            message: 'Regenerate Illustration',
            child: GestureDetector(
              onTap: () => _regeneratePage(pageIndex),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.3),
                      blurRadius: 8.0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 16.0,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      "Regenerate",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget? _buildLoadingOverlay(int pageIndex) {
    if (_loadingPages[pageIndex] != true) return null;

    return Positioned.fill(
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
          child: Container(
            color: Colors.black.withOpacity(0.45),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 32.0,
                    height: 32.0,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.secondary),
                      strokeWidth: 3.0,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    "Regenerating Magic...",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    "Creating new illustration",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.0,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _regeneratePage(int pageIndex) async {
    final requestId = widget.previewRequestId;
    if (requestId == null) return;
    
    final pageNumber = pageIndex + 1;

    setState(() {
      _loadingPages[pageIndex] = true;
    });

    try {
      await _previewApiService.regeneratePreviewPage(requestId, pageNumber);

      _pollingTimers[pageIndex]?.cancel();

      _pollingTimers[pageIndex] = Timer.periodic(const Duration(milliseconds: 2500), (timer) async {
        try {
          final result = await _previewApiService.pollPreviewStatus(requestId);
          final status = result['status'] as String;
          final List<String> pages = List<String>.from(result['pages'] ?? []);

          if (status == 'completed' || status == 'failed') {
            timer.cancel();
            _pollingTimers[pageIndex] = null;

            if (status == 'completed' && pages.length > pageIndex) {
              setState(() {
                final rawUrl = pages[pageIndex];
                final separator = rawUrl.contains('?') ? '&' : '?';
                _pageUrls[pageIndex] = '$rawUrl${separator}t=${DateTime.now().millisecondsSinceEpoch}';
                _loadingPages[pageIndex] = false;
              });
            } else {
              setState(() {
                _loadingPages[pageIndex] = false;
              });
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('⚠️ Illustration regeneration failed.'),
                    backgroundColor: AppTheme.error,
                  ),
                );
              }
            }
          }
        } catch (e) {
          debugPrint('Error polling regeneration status: $e');
        }
      });
    } catch (e) {
      debugPrint('Error initiating regeneration: $e');
      setState(() {
        _loadingPages[pageIndex] = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Error starting regeneration: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  // Get image URL for a spread
  String _getSpreadImageUrl(int index) {
    if (index < _pageUrls.length) {
      return _pageUrls[index];
    }
    return '';
  }

  Widget _buildLeftPage(int index) {
    final imageUrl = _getSpreadImageUrl(index * 2);

    return Container(
      key: ValueKey('left_$index'),
      color: Colors.white,
      child: Stack(
        fit: StackFit.expand,
        children: [
          imageUrl.startsWith('http')
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppTheme.surfaceContainerLow,
                    child: const Icon(Icons.broken_image, color: AppTheme.outline),
                  ),
                )
              : Image.asset(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppTheme.surfaceContainerLow,
                    child: const Icon(Icons.broken_image, color: AppTheme.outline),
                  ),
                ),
          // Gradient overlay for visual magic/premium feel
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.35),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Subtle page edge shadow (inner-curl effect)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 12.0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    Colors.black.withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Illustration Preview badge
          Positioned(
            bottom: 24.0,
            left: 24.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(AppConstants.radiusDefault),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              child: Text(
                "ILLUSTRATION PREVIEW",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ),
          // Page Number
          Positioned(
            bottom: 16.0,
            right: 24.0,
            child: Text(
              "${index * 2 + 1}",
              style: GoogleFonts.literata(
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
          ),
          if (_buildRegenerateButton(index * 2) != null)
            _buildRegenerateButton(index * 2)!,
          if (_buildLoadingOverlay(index * 2) != null)
            _buildLoadingOverlay(index * 2)!,
        ],
      ),
    );
  }

  Widget _buildRightPage(int index) {
    final imageUrl = _getSpreadImageUrl(index * 2 + 1);

    return Container(
      key: ValueKey('right_$index'),
      color: Colors.white,
      child: Stack(
        fit: StackFit.expand,
        children: [
          imageUrl.startsWith('http')
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppTheme.surfaceContainerLow,
                    child: const Icon(Icons.broken_image, color: AppTheme.outline),
                  ),
                )
              : Image.asset(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppTheme.surfaceContainerLow,
                    child: const Icon(Icons.broken_image, color: AppTheme.outline),
                  ),
                ),
          // Gradient overlay for visual magic/premium feel
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.35),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Subtle page edge shadow (inner-curl effect)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 12.0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Illustration Preview badge
          Positioned(
            bottom: 24.0,
            right: 24.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(AppConstants.radiusDefault),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              child: Text(
                "ILLUSTRATION PREVIEW",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ),
          // Page Number
          Positioned(
            bottom: 16.0,
            left: 24.0,
            child: Text(
              "${index * 2 + 2}",
              style: GoogleFonts.literata(
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
          ),
          if (_buildRegenerateButton(index * 2 + 1) != null)
            _buildRegenerateButton(index * 2 + 1)!,
          if (_buildLoadingOverlay(index * 2 + 1) != null)
            _buildLoadingOverlay(index * 2 + 1)!,
        ],
      ),
    );
  }

  Widget _buildSinglePageMobile(int pageIndex) {
    final imageUrl = _getSpreadImageUrl(pageIndex);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      child: AspectRatio(
        aspectRatio: 3 / 2,
        child: Stack(
          fit: StackFit.expand,
          children: [
            imageUrl.startsWith('http')
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppTheme.surfaceContainerLow,
                      child: const Icon(Icons.broken_image, color: AppTheme.outline),
                    ),
                  )
                : Image.asset(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppTheme.surfaceContainerLow,
                      child: const Icon(Icons.broken_image, color: AppTheme.outline),
                    ),
                  ),
            // Gradient overlay for visual magic/premium feel
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            // Illustration Preview badge
            Positioned(
              bottom: 16.0,
              left: 16.0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(AppConstants.radiusDefault),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                child: Text(
                  "ILLUSTRATION PREVIEW",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ),
            // Page Number
            Positioned(
              bottom: 16.0,
              right: 16.0,
              child: Text(
                "${pageIndex + 1}",
                style: GoogleFonts.literata(
                  fontSize: 11.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            if (_buildRegenerateButton(pageIndex) != null)
              _buildRegenerateButton(pageIndex)!,
            if (_buildLoadingOverlay(pageIndex) != null)
              _buildLoadingOverlay(pageIndex)!,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bookWidth = constraints.maxWidth;
        final isMobile = bookWidth < 640.0;

        Widget bookWidget;

        if (isMobile) {
          int currentPage = _currentIndex;
          int nextOrPrevPage = _currentIndex;
          double startAngle = 0.0;
          double endAngle = 0.0;
          bool showFlippingOnTop = _direction != FlipDirection.none;

          if (_direction == FlipDirection.forward) {
            currentPage = _currentIndex;
            nextOrPrevPage = _currentIndex + 1;
            startAngle = 0.0;
            endAngle = -math.pi / 2;
          } else if (_direction == FlipDirection.backward) {
            currentPage = _currentIndex;
            nextOrPrevPage = _currentIndex - 1;
            startAngle = 0.0;
            endAngle = -math.pi / 2;
          }

          Widget staticPage = _buildSinglePageMobile(
            _direction == FlipDirection.forward ? nextOrPrevPage : currentPage,
          );

          if (!showFlippingOnTop) {
            bookWidget = Container(
              key: ValueKey<int>(_currentIndex),
              width: bookWidth,
              height: bookWidth / 1.5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x2E5D39DF),
                    blurRadius: 24.0,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: staticPage,
            );
          } else {
            bookWidget = Container(
              key: ValueKey<int>(_currentIndex),
              width: bookWidth,
              height: bookWidth / 1.5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x2E5D39DF),
                    blurRadius: 24.0,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Underneath page
                  _buildSinglePageMobile(
                    _direction == FlipDirection.forward ? nextOrPrevPage : currentPage,
                  ),
                  // Flipping page on top
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final double t = _controller.value;
                      final double angle = startAngle + (endAngle - startAngle) * t;

                      if (t > 0.9) {
                        return const SizedBox.shrink();
                      }

                      return Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, -0.001)
                          ..rotateY(angle),
                        alignment: Alignment.centerLeft,
                        child: _buildSinglePageMobile(
                          _direction == FlipDirection.forward ? currentPage : nextOrPrevPage,
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }
        } else {
          // Keep book spread side-by-side but scale it to match aspect ratio 1.5
          final bookHeight = bookWidth / 3.0;

          // Determine current indices based on animation direction
          int leftIndex = _currentIndex;
          int rightIndex = _currentIndex;
          int turningFrontIndex = _currentIndex;
          int turningBackIndex = _currentIndex;

          if (_direction == FlipDirection.forward) {
            leftIndex = _currentIndex;
            rightIndex = _currentIndex + 1;
            turningFrontIndex = _currentIndex;
            turningBackIndex = _currentIndex + 1;
          } else if (_direction == FlipDirection.backward) {
            leftIndex = _currentIndex - 1;
            rightIndex = _currentIndex;
            turningFrontIndex = _currentIndex - 1;
            turningBackIndex = _currentIndex;
          }

          bookWidget = Container(
          width: bookWidth,
          height: bookHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            boxShadow: const [
              BoxShadow(
                color: Color(0x2E5D39DF), // 18% primary shadow
                blurRadius: 40.0,
                offset: Offset(0, 15),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Static Left Page
              Positioned(
                left: 0,
                width: bookWidth / 2,
                top: 0,
                bottom: 0,
                child: _buildLeftPage(leftIndex),
              ),

              // 2. Static Right Page
              Positioned(
                left: bookWidth / 2,
                width: bookWidth / 2,
                top: 0,
                bottom: 0,
                child: _buildRightPage(rightIndex),
              ),

              // 3. Flipping Page (drawn on top of background pages when animating)
              if (_direction != FlipDirection.none)
                Positioned(
                  left: bookWidth / 2,
                  width: bookWidth / 2,
                  top: 0,
                  bottom: 0,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final double t = _controller.value;
                      // Rotate from 0 to -pi
                      final double angle = -t * math.pi;
                      final isFront = t < 0.5;

                      return Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, -0.001) // perspective
                          ..rotateY(angle),
                        alignment: Alignment.centerLeft,
                        child: isFront
                            ? _buildRightPage(turningFrontIndex)
                            : Transform(
                                transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0),
                                alignment: Alignment.center,
                                child: _buildLeftPage(turningBackIndex),
                              ),
                      );
                    },
                  ),
                ),

              // 4. Center Spine Crease Overlay (always visible to give depth)
              Positioned(
                left: (bookWidth / 2) - 16.0,
                width: 32.0,
                top: 0,
                bottom: 0,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.18),
                          Colors.black.withOpacity(0.04),
                          Colors.transparent,
                          Colors.black.withOpacity(0.04),
                          Colors.black.withOpacity(0.18),
                        ],
                        stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
                      ),
                    ),
                  ),
                ),
              ),

              // 5. Left Page Outer Curl Shadow (left edge)
              Positioned(
                left: 0,
                width: 8.0,
                top: 0,
                bottom: 0,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.black.withOpacity(0.06),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 6. Right Page Outer Curl Shadow (right edge)
              Positioned(
                right: 0,
                width: 8.0,
                top: 0,
                bottom: 0,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [
                          Colors.black.withOpacity(0.06),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
        }

        if (widget.isFullScreen) {
          return bookWidget;
        }

        return Stack(
          alignment: Alignment.center,
          children: [
            bookWidget,
            Positioned(
              top: 12.0,
              right: 12.0,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () async {
                    final newIndex = await Navigator.of(context).push<int>(
                      MaterialPageRoute(
                        builder: (_) => FullScreenBookViewer(
                          product: widget.product,
                          childName: widget.childName,
                          ageRange: widget.ageRange,
                          gender: widget.gender,
                          bookType: widget.bookType,
                          initialIndex: _currentIndex,
                          generatedPageUrls: widget.generatedPageUrls,
                          previewRequestId: widget.previewRequestId,
                        ),
                      ),
                    );
                    if (newIndex != null) {
                      setState(() {
                        _currentIndex = newIndex;
                      });
                      widget.onPageChanged?.call(newIndex);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 6.0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.fullscreen,
                      color: Colors.white,
                      size: 20.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class FullScreenBookViewer extends StatefulWidget {
  final Product product;
  final String childName;
  final String ageRange;
  final String gender;
  final String bookType;
  final int initialIndex;
  final List<String>? generatedPageUrls;
  final String? previewRequestId;

  const FullScreenBookViewer({
    super.key,
    required this.product,
    required this.childName,
    required this.ageRange,
    required this.gender,
    required this.bookType,
    required this.initialIndex,
    this.generatedPageUrls,
    this.previewRequestId,
  });

  @override
  State<FullScreenBookViewer> createState() => _FullScreenBookViewerState();
}

class _FullScreenBookViewerState extends State<FullScreenBookViewer> {
  final GlobalKey<BookWidgetState> _bookKey = GlobalKey<BookWidgetState>();
  late int _currentIndex;

  int get _totalSpreads {
    final pageCount = widget.generatedPageUrls?.length ?? 0;
    return math.max(1, (pageCount / 2).ceil());
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.95),
      body: Stack(
        children: [
          // Close button
          Positioned(
            top: 24.0,
            right: 24.0,
            child: SafeArea(
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(_currentIndex),
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 28.0),
                  ),
                ),
              ),
            ),
          ),

          // Central Book widget container
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80.0, vertical: 40.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200.0),
                child: BookWidget(
                  key: _bookKey,
                  product: widget.product,
                  childName: widget.childName,
                  ageRange: widget.ageRange,
                  gender: widget.gender,
                  bookType: widget.bookType,
                  initialIndex: _currentIndex,
                  isFullScreen: true,
                  generatedPageUrls: widget.generatedPageUrls,
                  previewRequestId: widget.previewRequestId,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
              ),
            ),
          ),

          // Left Chevron (Previous)
          if (_currentIndex > 0)
            Positioned(
              left: 24.0,
              top: 0,
              bottom: 0,
              child: Center(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => _bookKey.currentState?.flipBackward(),
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.chevron_left, color: Colors.white, size: 36.0),
                    ),
                  ),
                ),
              ),
            ),

          if (_currentIndex < _totalSpreads - 1)
            Positioned(
              right: 24.0,
              top: 0,
              bottom: 0,
              child: Center(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => _bookKey.currentState?.flipForward(),
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.chevron_right, color: Colors.white, size: 36.0),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
