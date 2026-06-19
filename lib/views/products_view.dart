import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../models/product.dart';
import '../core/api/products_service.dart';
import '../widgets/navbar.dart';
import '../widgets/footer.dart';
import '../widgets/story_card.dart';
import 'product_detail_view.dart';

class ProductsView extends StatefulWidget {
  const ProductsView({super.key});

  @override
  State<ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<ProductsView> {
  List<Product> _products = [];
  bool _isLoading = true;
  final ProductsService _productsService = ProductsService();

  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCount = 0;
  bool _hasNext = false;
  bool _hasPrevious = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts({int page = 1}) async {
    setState(() {
      _isLoading = true;
      _currentPage = page;
    });
    try {
      final paginated = await _productsService.fetchProducts(page: page);
      if (mounted) {
        setState(() {
          _products = paginated.products;
          _totalCount = paginated.count;
          _totalPages = (paginated.count / 6).ceil();
          _hasNext = paginated.nextUrl != null;
          _hasPrevious = paginated.previousUrl != null;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading products from API: $e. Falling back to local assets.');
      try {
        final paginated = await _productsService.loadLocalProducts();
        if (mounted) {
          setState(() {
            _products = paginated.products;
            _totalCount = paginated.count;
            _totalPages = (paginated.count / 6).ceil();
            _hasNext = paginated.nextUrl != null;
            _hasPrevious = paginated.previousUrl != null;
            _isLoading = false;
          });
        }
      } catch (assetErr) {
        debugPrint('Error loading fallback products.json: $assetErr');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTablet = width >= 768.0;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      extendBodyBehindAppBar: true,
      appBar: NavBar(
        activeIndex: -1,
        onHomeTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
        onExploreStoriesTap: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        onHowItWorksTap: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        onPricingTap: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        onCreatePreviewTap: () {},
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 120.0), // Navbar height spacer

            // Header Section
            Container(
              padding: EdgeInsets.symmetric(
                vertical: isTablet ? 60.0 : 40.0,
                horizontal: isTablet ? AppConstants.gutter : AppConstants.mobileMargin,
              ),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800.0),
                  child: Column(
                    children: [
                      Text(
                        'CHOOSE YOUR MAGICAL ADVENTURE',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: isTablet ? 36.0 : 28.0,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        'Select from our bestselling custom themes to start creating your personalized storybook preview.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16.0,
                          color: AppTheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      Container(
                        height: 4.0,
                        width: 80.0,
                        decoration: BoxDecoration(
                          color: AppTheme.secondary,
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Products Grid
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: AppConstants.maxContainerWidth),
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? AppConstants.gutter : AppConstants.mobileMargin,
                ),
                child: _isLoading
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

                          return Column(
                             crossAxisAlignment: CrossAxisAlignment.stretch,
                             children: [
                               GridView.builder(
                                 shrinkWrap: true,
                                 physics: const NeverScrollableScrollPhysics(),
                                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                   crossAxisCount: crossAxisCount,
                                   crossAxisSpacing: 32.0,
                                   mainAxisSpacing: 32.0,
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
                               ),
                               if (_totalPages > 1) ...[
                                 const SizedBox(height: 40.0),
                                 Row(
                                   mainAxisAlignment: MainAxisAlignment.center,
                                   children: [
                                     IconButton(
                                       icon: const Icon(Icons.arrow_back_ios, size: 18.0),
                                       onPressed: _hasPrevious ? () => _loadProducts(page: _currentPage - 1) : null,
                                       color: _hasPrevious ? AppTheme.primary : AppTheme.outlineVariant,
                                     ),
                                     const SizedBox(width: 16.0),
                                     Text(
                                       'Page $_currentPage of $_totalPages',
                                       style: GoogleFonts.plusJakartaSans(
                                         fontSize: 16.0,
                                         fontWeight: FontWeight.w600,
                                         color: AppTheme.onSurface,
                                       ),
                                     ),
                                     const SizedBox(width: 16.0),
                                     IconButton(
                                       icon: const Icon(Icons.arrow_forward_ios, size: 18.0),
                                       onPressed: _hasNext ? () => _loadProducts(page: _currentPage + 1) : null,
                                       color: _hasNext ? AppTheme.primary : AppTheme.outlineVariant,
                                     ),
                                   ],
                                 ),
                               ],
                             ],
                           );
                        },
                      ),
              ),
            ),

            const SizedBox(height: 100.0),

            // Footer
            const Footer(),
          ],
        ),
      ),
    );
  }
}
