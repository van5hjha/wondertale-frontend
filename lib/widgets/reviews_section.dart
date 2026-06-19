import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../core/api/reviews_service.dart';
import '../models/review_model.dart';

class ReviewsSection extends StatefulWidget {
  const ReviewsSection({super.key});

  @override
  State<ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<ReviewsSection> {
  final ReviewsService _reviewsService = ReviewsService();
  List<ReviewModel> _reviews = [];
  bool _isLoading = true;

  static final List<ReviewModel> _fallbackReviews = [
    ReviewModel(
      id: 1,
      quote: "Seeing my son Aarav's face on the space explorer cover was priceless! He now reads it every single night.",
      name: "Priya Sharma",
      location: "Mumbai, Maharashtra",
      rating: 5,
    ),
    ReviewModel(
      id: 2,
      quote: "The quality is amazing, a forever keepsake. The AI matched my daughter's curls perfectly!",
      name: "Rajesh Patel",
      location: "Bengaluru, Karnataka",
      rating: 5,
    ),
    ReviewModel(
      id: 3,
      quote: "Best birthday gift ever. My nephew thinks he is a real superhero. Highly recommend to all parents!",
      name: "Sunita Rao",
      location: "Hyderabad, Telangana",
      rating: 5,
    ),
    ReviewModel(
      id: 4,
      quote: "I was skeptical about AI, but the art style is breathtaking. The stories are genuinely interesting too.",
      name: "Amit Verma",
      location: "Delhi, NCR",
      rating: 5,
    ),
    ReviewModel(
      id: 5,
      quote: "Got the hardcover for my son's 5th birthday. The print quality and paper thickness is outstanding.",
      name: "Vikram Malhotra",
      location: "Pune, Maharashtra",
      rating: 5,
    ),
    ReviewModel(
      id: 6,
      quote: "The process was so simple! Just uploaded a photo and got a preview in 2 minutes. Excellent service.",
      name: "Deepa Nair",
      location: "Kochi, Kerala",
      rating: 5,
    ),
    ReviewModel(
      id: 7,
      quote: "My daughter started jumping with joy when she saw herself as a little wizard. Super happy!",
      name: "Sanjay Gupta",
      location: "Kolkata, West Bengal",
      rating: 5,
    ),
    ReviewModel(
      id: 8,
      quote: "Outstanding storytelling and beautiful illustrations. It's not just a gimmick, it's a high-quality book.",
      name: "Meenakshi Sundaram",
      location: "Chennai, Tamil Nadu",
      rating: 5,
    ),
    ReviewModel(
      id: 9,
      quote: "The custom text options and easy checkout made this a great gifting experience. Will order again!",
      name: "Anil Deshmukh",
      location: "Nagpur, Maharashtra",
      rating: 5,
    ),
    ReviewModel(
      id: 10,
      quote: "A wonderful personalized gift that kids will treasure forever. Absolute value for money.",
      name: "Karan Joshi",
      location: "Ahmedabad, Gujarat",
      rating: 5,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      final fetchedReviews = await _reviewsService.fetchReviews();
      if (mounted) {
        setState(() {
          _reviews = fetchedReviews;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading reviews from API: $e. Falling back to static data.");
      if (mounted) {
        setState(() {
          _reviews = _fallbackReviews;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 768.0;

    final displayReviews = _reviews.isEmpty && !_isLoading ? _fallbackReviews : _reviews;

    // Split reviews between two rows
    final List<Widget> row1Reviews = [];
    final List<Widget> row2Reviews = [];

    for (int i = 0; i < displayReviews.length; i++) {
      final review = displayReviews[i];
      // Generate delay offset between 0.0 and 1.0 based on position
      final double delayFraction = (i * 0.15) % 1.0;
      
      final cardWidget = _buildFloatingCard(
        quote: review.quote,
        name: review.name,
        location: review.location,
        rating: review.rating,
        delayFraction: delayFraction,
      );

      if (i % 2 == 0) {
        row1Reviews.add(cardWidget);
      } else {
        row2Reviews.add(cardWidget);
      }
    }

    if (row1Reviews.isEmpty && !_isLoading) {
      row1Reviews.add(const SizedBox());
    }
    if (row2Reviews.isEmpty && !_isLoading) {
      row2Reviews.add(const SizedBox());
    }

    return Container(
      color: AppTheme.surface,
      padding: EdgeInsets.symmetric(
        vertical: isDesktop ? AppConstants.sectionGapDesktop : AppConstants.sectionGapMobile,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Section
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? AppConstants.gutter : AppConstants.mobileMargin,
            ),
            child: Column(
              children: [
                Text(
                  'What parents are saying',
                  style: (isDesktop
                          ? Theme.of(context).textTheme.displayLarge
                          : Theme.of(context).textTheme.displayMedium)
                      ?.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16.0),
                Container(
                  constraints: const BoxConstraints(maxWidth: 640.0),
                  child: Text(
                    'Discover how Stardust Tales has sparked imagination and joy in homes across India.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 64.0),

          if (_isLoading)
            const SizedBox(
              height: 524.0,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                ),
              ),
            )
          else ...[
            // Row 1 (Faster)
            SizedBox(
              height: 250.0, // Enough height for the 220px card + float offset
              child: AutoScrollRow(
                speed: 40.0,
                children: row1Reviews,
              ),
            ),
            const SizedBox(height: 24.0),

            // Row 2 (Slower)
            SizedBox(
              height: 250.0,
              child: AutoScrollRow(
                speed: 25.0,
                children: row2Reviews,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFloatingCard({
    required String quote,
    required String name,
    required String location,
    required int rating,
    required double delayFraction,
  }) {
    return FloatingWidget(
      delayFraction: delayFraction,
      child: ReviewCard(
        quote: quote,
        name: name,
        location: location,
        rating: rating,
      ),
    );
  }
}

class ReviewCard extends StatelessWidget {
  final String quote;
  final String name;
  final String location;
  final int rating;

  const ReviewCard({
    super.key,
    required this.quote,
    required this.name,
    required this.location,
    this.rating = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340.0, // Matches width in HTML design (350px - padding/margins)
      height: 220.0,
      margin: const EdgeInsets.only(right: 24.0),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: AppTheme.secondary.withOpacity(0.04),
            blurRadius: 32.0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(
            color: AppTheme.secondary.withOpacity(0.15),
            width: 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rating Stars
            Row(
              children: List.generate(
                rating,
                (index) => const Icon(
                  Icons.star,
                  color: AppTheme.tertiary, // Sunset Gold
                  size: 18.0,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            // Quote
            Expanded(
              child: Text(
                '"$quote"',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.onSurface,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16.0),
            // Author Name
            Text(
              name,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4.0),
            // Location
            Text(
              location.toUpperCase(),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppTheme.secondary, // Magic Lilac
                    fontSize: 11.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class FloatingWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double maxOffset;
  final double delayFraction;

  const FloatingWidget({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 6),
    this.maxOffset = 15.0,
    this.delayFraction = 0.0,
  });

  @override
  State<FloatingWidget> createState() => _FloatingWidgetState();
}

class _FloatingWidgetState extends State<FloatingWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    
    _animation = Tween<double>(begin: 0.0, end: widget.maxOffset).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.delayFraction > 0.0) {
      _controller.value = widget.delayFraction;
    }
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_animation.value),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class AutoScrollRow extends StatefulWidget {
  final List<Widget> children;
  final double speed; // pixels per second

  const AutoScrollRow({
    super.key,
    required this.children,
    this.speed = 30.0,
  });

  @override
  State<AutoScrollRow> createState() => _AutoScrollRowState();
}

class _AutoScrollRowState extends State<AutoScrollRow> {
  late final ScrollController _scrollController;
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScrolling();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _startScrolling() async {
    if (!mounted || _isScrolling) return;
    _isScrolling = true;

    // Wait until controller is attached
    while (mounted && !_scrollController.hasClients) {
      await Future.delayed(const Duration(milliseconds: 50));
    }

    while (mounted && _scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final viewportDim = _scrollController.position.viewportDimension;
      final totalWidth = maxScroll + viewportDim;
      final oneSetWidth = totalWidth / 2;

      final currentScroll = _scrollController.offset;

      if (currentScroll >= oneSetWidth) {
        _scrollController.jumpTo(currentScroll - oneSetWidth);
        continue;
      }

      final targetScroll = oneSetWidth;
      final distance = targetScroll - _scrollController.offset;
      if (distance <= 0.0) {
        _scrollController.jumpTo(0.0);
        continue;
      }

      final duration = Duration(
        milliseconds: (distance / widget.speed * 1000).toInt(),
      );

      try {
        await _scrollController.animateTo(
          targetScroll,
          duration: duration,
          curve: Curves.linear,
        );
      } catch (e) {
        // Disposed or scroll interrupted
        break;
      }

      if (mounted && _scrollController.hasClients) {
        _scrollController.jumpTo(0.0);
      }
    }
    _isScrolling = false;
  }

  @override
  Widget build(BuildContext context) {
    final doubleList = [...widget.children, ...widget.children];
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Row(
        children: doubleList,
      ),
    );
  }
}
