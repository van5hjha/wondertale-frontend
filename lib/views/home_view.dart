import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../models/product.dart';
import '../core/api/products_service.dart';
import '../widgets/navbar.dart';
import '../widgets/footer.dart';
import '../widgets/before_after_slideshow.dart';
import '../widgets/story_card.dart';
import '../widgets/how_it_works_section.dart';
import '../widgets/cta_section.dart';
import '../widgets/pricing_section.dart';
import '../widgets/reviews_section.dart';
import 'product_detail_view.dart';
import 'products_view.dart';
import '../widgets/stardust_particles.dart';
import '../widgets/hero_background_painters.dart';
import '../widgets/loading_screen.dart';
import '../widgets/interactive_elements.dart';


class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _activeIndex = 0;
  List<Product> _products = [];
  bool _isLoading = true;

  final ProductsService _productsService = ProductsService();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _storiesKey = GlobalKey();
  final GlobalKey _howItWorksKey = GlobalKey();
  final GlobalKey _pricingKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final startTime = DateTime.now();
    try {
      final paginated = await _productsService.fetchProducts();
      if (mounted) {
        setState(() {
          _products = paginated.products;
        });
      }
    } catch (e) {
      debugPrint('Error loading products from API: $e. Falling back to local assets.');
      try {
        final paginated = await _productsService.loadLocalProducts();
        if (mounted) {
          setState(() {
            _products = paginated.products;
          });
        }
      } catch (assetErr) {
        debugPrint('Error loading fallback products.json: $assetErr');
      }
    }

    final elapsed = DateTime.now().difference(startTime);
    final remaining = const Duration(milliseconds: 2000) - elapsed;
    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSection(GlobalKey key, int index) {
    setState(() {
      _activeIndex = index;
    });
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1024.0; // Breakpoint for 2-column layout in Hero
    final isTablet = width >= 768.0;

    final textWidget = Padding(
      padding: EdgeInsets.only(
        right: isDesktop ? 48.0 : 0.0,
        bottom: isDesktop ? 0.0 : 48.0,
      ),
      child: Column(
        crossAxisAlignment:
            isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: isDesktop ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              const PulsingSparkle(color: AppTheme.tertiary),
              const SizedBox(width: 8.0),
              Text(
                "MAGICAL AI STORYTELLING",
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppTheme.secondary,
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.0,
                    ),
              ),
              const SizedBox(width: 8.0),
              const PulsingSparkle(color: AppTheme.secondary),
            ],
          ),
          const SizedBox(height: 24.0),
          Column(
            crossAxisAlignment: isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              Text(
                "Make your Child the",
                style: (isTablet
                    ? Theme.of(context).textTheme.displayLarge
                    : Theme.of(context).textTheme.displayMedium)
                  ?.copyWith(
                    height: 1.1,
                    color: AppTheme.primary,
                  ),
                textAlign: isDesktop ? TextAlign.left : TextAlign.center,
              ),
              const SizedBox(height: 4.0),
              Wrap(
                alignment: isDesktop ? WrapAlignment.start : WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12.0,
                runSpacing: 8.0,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        bottom: 6.0,
                        left: -4.0,
                        right: -4.0,
                        height: 16.0,
                        child: Transform.rotate(
                          angle: -0.035,
                          child: Container(
                            color: AppTheme.tertiary.withOpacity(0.3),
                          ),
                        ),
                      ),
                      Text(
                        "Star",
                        style: (isTablet
                            ? Theme.of(context).textTheme.displayLarge
                            : Theme.of(context).textTheme.displayMedium)
                          ?.copyWith(
                            height: 1.1,
                            color: AppTheme.secondary,
                          ),
                      ),
                    ],
                  ),
                  Text(
                    "of their",
                    style: (isTablet
                        ? Theme.of(context).textTheme.displayLarge
                        : Theme.of(context).textTheme.displayMedium)
                      ?.copyWith(
                        height: 1.1,
                        color: AppTheme.primary,
                      ),
                  ),
                  Text(
                    "own Story!",
                    style: (isTablet
                        ? Theme.of(context).textTheme.displayLarge
                        : Theme.of(context).textTheme.displayMedium)
                      ?.copyWith(
                        height: 1.1,
                        color: AppTheme.secondary,
                      ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24.0),
          RichText(
            textAlign: isDesktop ? TextAlign.left : TextAlign.center,
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.onSurfaceVariant,
                    height: 1.6,
                  ),
              children: const [
                TextSpan(
                  text: "A keepsake they'll treasure for years to come. ",
                ),
                TextSpan(
                  text: "Upload a photo",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
                TextSpan(
                  text: " and watch them transform into a premium, custom-illustrated storybook.",
                ),
              ],
            ),
          ),
          const SizedBox(height: 40.0),
          isDesktop
              ? Wrap(
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 32.0,
                  runSpacing: 24.0,
                  children: [
                    _buildCtaButton(context),
                    _buildAvatarPile(context),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildCtaButton(context),
                    const SizedBox(height: 24.0),
                    _buildAvatarPile(context),
                  ],
                ),
          const SizedBox(height: 24.0),
          Row(
            mainAxisAlignment: isDesktop ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              Icon(
                Icons.timer,
                size: 16.0,
                color: AppTheme.onSurfaceVariant.withOpacity(0.7),
              ),
              const SizedBox(width: 8.0),
              Text(
                "takes only 2 minutes",
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.onSurfaceVariant.withOpacity(0.7),
                      fontSize: 13.0,
                    ),
              ),
            ],
          ),
        ],
      ),
    );

    const sliderWidget = RepaintBoundary(child: BeforeAfterSlideshow());

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      child: _isLoading
          ? const LoadingScreen(key: ValueKey('loading'))
          : Scaffold(
              key: const ValueKey('loaded'),
              extendBodyBehindAppBar: true,
              appBar: NavBar(
                activeIndex: _activeIndex,
                onHomeTap: () {
                  _scrollController.animateTo(
                    0.0,
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeInOut,
                  );
                  setState(() {
                    _activeIndex = -1;
                  });
                },
                onExploreStoriesTap: () => _scrollToSection(_storiesKey, 0),
                onHowItWorksTap: () => _scrollToSection(_howItWorksKey, 1),
                onPricingTap: () => _scrollToSection(_pricingKey, 2),
                onCreatePreviewTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ProductsView(),
                    ),
                  );
                },
              ),
              body: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: AppTheme.surface,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x1F110F2D), // Indigo Night tint at low opacity
                            blurRadius: 32.0,
                            offset: Offset(0, 16),
                          ),
                        ],
                      ),
                      child: ClipRect(
                        child: Stack(
                          children: [
                          Positioned.fill(
                            child: RepaintBoundary(
                              child: CustomPaint(
                                painter: WarmNebulaPainter(),
                              ),
                            ),
                          ),
                          const Positioned.fill(
                            child: RepaintBoundary(
                              child: StardustParticles(),
                            ),
                          ),
                          Center(
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: AppConstants.maxContainerWidth),
                              padding: EdgeInsets.only(
                                top: 160.0,
                                bottom: isTablet ? 120.0 : 64.0,
                              ),
                              child: isDesktop
                                  ? IntrinsicHeight(
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          // Left Content Column
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                left: AppConstants.gutter,
                                                right: AppConstants.gutter + 24.0,
                                                top: 24.0,
                                                bottom: 24.0,
                                              ),
                                              child: textWidget,
                                            ),
                                          ),
                                          // Right Image Column
                                          Expanded(
                                            child: Container(
                                              padding: const EdgeInsets.all(48.0),
                                              alignment: Alignment.center,
                                              child: sliderWidget,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: AppConstants.mobileMargin,
                                            vertical: 24.0,
                                          ),
                                          child: textWidget,
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: AppConstants.mobileMargin,
                                            vertical: 48.0,
                                          ),
                                          child: sliderWidget,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          if (isDesktop)
                            Positioned(
                              top: 0,
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  width: 6.0,
                                  color: AppTheme.surface,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                    // 2. Popular Stories Section
                    Container(
                      key: _storiesKey,
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 80.0 : 24.0,
                        vertical: 120.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppTheme.secondaryContainer,
                                      borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 6.0,
                                    ),
                                    child: Text(
                                      'POPULAR STORIES',
                                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                            color: AppTheme.onSecondaryContainer,
                                            fontSize: 12.0,
                                            letterSpacing: 1.5,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(height: 16.0),
                                  Text(
                                    'Trending Tales',
                                    style: isTablet
                                        ? Theme.of(context).textTheme.displayMedium
                                        : Theme.of(context).textTheme.headlineLarge,
                                  ),
                                ],
                              ),
                              if (isTablet)
                                MagneticHoverButton(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const ProductsView(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppTheme.outlineVariant,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24.0,
                                      vertical: 12.0,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'VIEW ALL STORIES',
                                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                                color: AppTheme.onSurface,
                                                fontSize: 12.0,
                                                letterSpacing: 1.0,
                                              ),
                                        ),
                                        const SizedBox(width: 8.0),
                                        const Icon(
                                          Icons.arrow_forward,
                                          size: 16.0,
                                          color: AppTheme.onSurface,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 48.0),

                          // Stories Grid
                          _isLoading
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(40.0),
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation(AppTheme.secondary),
                                    ),
                                  ),
                                )
                              : LayoutBuilder(
                                  builder: (context, constraints) {
                                    final width = constraints.maxWidth;
                                    final crossAxisCount = width >= 1024 ? 3 : (width >= 640 ? 2 : 1);
                                    final totalSpacing = 32.0 * (crossAxisCount - 1);
                                    final cardWidth = (width - totalSpacing) / crossAxisCount;
                                    final imageHeight = cardWidth * (2.0 / 3.0);
                                    final totalHeight = imageHeight + 200.0;
                                    final childAspectRatio = cardWidth / totalHeight;

                                    return GridView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: crossAxisCount,
                                        crossAxisSpacing: 32.0,
                                        mainAxisSpacing: 48.0,
                                        childAspectRatio: childAspectRatio,
                                      ),
                                      itemCount: _products.length,
                                      itemBuilder: (context, index) {
                                        final product = _products[index];
                                        return StoryCard(
                                          title: product.title,
                                          ageRange: product.ageRange,
                                          description: product.description,
                                          imageUrls: product.previewImages,
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) => ProductDetailView(product: product),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                ),
                          if (!isTablet) ...[
                            const SizedBox(height: 32.0),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const ProductsView(),
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppTheme.outlineVariant),
                                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'VIEW ALL STORIES',
                                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                            color: AppTheme.onSurface,
                                            fontSize: 14.0,
                                          ),
                                    ),
                                    const SizedBox(width: 8.0),
                                    const Icon(Icons.arrow_forward, size: 16.0),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

            // Reviews Section
            const ReviewsSection(),

            // 3. How It Works Section
            HowItWorksSection(key: _howItWorksKey),

            // 4. Pricing Section
            PricingSection(key: _pricingKey),

            // 5. CTA Section
            const CtaSection(),

            // 6. Footer
            const Footer(),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildAvatar(String text, Color bgColor, Color textColor) {
    return Align(
      alignment: Alignment.centerLeft,
      widthFactor: 0.6,
      child: Container(
        width: 32.0,
        height: 32.0,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.0),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 10.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCtaButton(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        MagneticHoverButton(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ProductsView(),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.secondary,
              borderRadius: BorderRadius.circular(AppConstants.radiusFull),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.secondary.withOpacity(0.3),
                  blurRadius: 15.0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 40.0,
              vertical: 20.0,
            ),
            child: Text(
              'GENERATE INSTANT PREVIEW',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppTheme.onPrimary,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),
        const Positioned(
          top: -12.0,
          right: -12.0,
          child: BouncingBadge(text: "FREE"),
        ),
      ],
    );
  }

  Widget _buildAvatarPile(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAvatar('JP', AppTheme.surfaceContainerHigh, AppTheme.primary),
            _buildAvatar('AM', AppTheme.secondary.withOpacity(0.2), AppTheme.secondary),
            _buildAvatar('SK', AppTheme.tertiary.withOpacity(0.2), AppTheme.tertiary),
          ],
        ),
        const SizedBox(height: 6.0),
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                  fontSize: 13.0,
                ),
            children: const [
              TextSpan(
                text: "Join 10,000+",
                style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
              ),
              TextSpan(text: " happy parents"),
            ],
          ),
        ),
      ],
    );
  }
}

