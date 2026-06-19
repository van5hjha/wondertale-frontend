import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../models/product.dart';
import '../widgets/navbar.dart';
import '../widgets/footer.dart';
import '../widgets/book_widget.dart';
import 'products_view.dart';

class PreviewView extends StatefulWidget {
  final Product product;
  final String childName;
  final String ageRange;
  final String gender;
  final String bookType;
  final List<String> generatedPageUrls;
  final String previewRequestId;

  const PreviewView({
    super.key,
    required this.product,
    required this.childName,
    required this.ageRange,
    required this.gender,
    required this.bookType,
    required this.generatedPageUrls,
    required this.previewRequestId,
  });

  @override
  State<PreviewView> createState() => _PreviewViewState();
}

class _PreviewViewState extends State<PreviewView> {
  final GlobalKey<BookWidgetState> _bookKey = GlobalKey<BookWidgetState>();
  final TextEditingController _addressController = TextEditingController();

  String _selectedBookType = 'Hardcover';

  // Page index tracking
  int _currentSpreadIndex = 0;

  // Checkout Options
  bool _addStickers = false;
  bool _addPdf = false;
  bool _isPayBtnHovered = false;

  // Checkout checkbox hover states
  bool _isStickersHovered = false;
  bool _isPdfHovered = false;

  late List<String> _pageUrls;

  @override
  void initState() {
    super.initState();
    _selectedBookType = widget.bookType;
    _pageUrls = List<String>.from(widget.generatedPageUrls);
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  int get _basePrice {
    return _selectedBookType == 'Hardcover'
        ? widget.product.priceHardcover
        : widget.product.priceSoftcover;
  }

  int get _totalAmount {
    int total = _basePrice;
    if (_addStickers) total += 199;
    if (_addPdf) total += 99;
    return total;
  }

  void _triggerPaymentFlow() {
    final address = _addressController.text.trim();
    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Please enter your shipping address to finalize the order.'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    // Secure payment loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Simulate steps
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop(); // close loader
                _showSuccessOrderDialog();
              }
            });

            return AlertDialog(
              backgroundColor: AppTheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              ),
              content: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(AppTheme.secondary),
                    ),
                    const SizedBox(height: 24.0),
                    Text(
                      'Securing Payment Gateway...',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Processing payment of ₹$_totalAmount',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.0,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showSuccessOrderDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final orderId = 'ST-${DateTime.now().year}-${1000 + math.Random().nextInt(9000)}';
        return AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          ),
          title: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.green, size: 28.0),
              SizedBox(width: 12.0),
              Text('Order Finalized!'),
            ],
          ),
          content: Text(
            '🎉 Custom storybook order placed successfully for ${widget.childName}!\n\n'
            'Order ID: $orderId\n'
            'Book Type: $_selectedBookType\n'
            'Total Amount Paid: ₹$_totalAmount\n\n'
            'We have begun custom face-mapping and printing. Your magical keepsake will ship in 3-5 business days.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.0,
              height: 1.5,
              color: AppTheme.primary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Navigate back to HomeView (pop everything until the first route)
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Text(
                'Return to Home',
                style: GoogleFonts.plusJakartaSans(
                  color: AppTheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1024.0;
    final isTablet = width >= 768.0;
    final isMobile = width < 640.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: NavBar(
        activeIndex: -1, // No active section highlight
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
        onCreatePreviewTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const ProductsView(),
            ),
          );
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 120.0), // Spacer for navbar

            // Book Section at the top
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1000.0),
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? AppConstants.gutter : AppConstants.mobileMargin,
                  vertical: 24.0,
                ),
                child: Column(
                  children: [
                    // Dynamic Interactive Book
                    BookWidget(
                      key: _bookKey,
                      product: widget.product,
                      childName: widget.childName,
                      ageRange: widget.ageRange,
                      gender: widget.gender,
                      bookType: _selectedBookType,
                      generatedPageUrls: _pageUrls,
                      previewRequestId: widget.previewRequestId,
                      onPageChanged: (index) {
                        setState(() {
                          _currentSpreadIndex = index;
                        });
                      },
                    ),

                    const SizedBox(height: 32.0),

                    // Book Pagination Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Previous Button
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              final canGoBack = _currentSpreadIndex > 0;
                              if (canGoBack) {
                                _bookKey.currentState?.flipBackward();
                              }
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.chevron_left,
                                  color: (_currentSpreadIndex > 0)
                                      ? AppTheme.secondary
                                      : AppTheme.outlineVariant,
                                ),
                                const SizedBox(width: 4.0),
                                Text(
                                  "Previous Page",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.0,
                                    color: (_currentSpreadIndex > 0)
                                        ? AppTheme.primary
                                        : AppTheme.outlineVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 32.0),

                        // Page Counter pill
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                          child: Text(
                            isMobile
                                ? "Page ${_currentSpreadIndex + 1} of ${math.max(1, _pageUrls.length)}"
                                : "Pages ${_currentSpreadIndex * 2 + 1}-${_currentSpreadIndex * 2 + 2} of ${math.max(1, _pageUrls.length)}",
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.0,
                              color: AppTheme.secondary,
                            ),
                          ),
                        ),

                        const SizedBox(width: 32.0),

                        // Next Button
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              final totalSpreads = math.max(1, (_pageUrls.length / 2).ceil());
                              final canGoForward = _currentSpreadIndex < totalSpreads - 1;
                              if (canGoForward) {
                                _bookKey.currentState?.flipForward();
                              }
                            },
                            child: Row(
                              children: [
                                Text(
                                  "Next Page",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.0,
                                    color: (_currentSpreadIndex < math.max(1, (_pageUrls.length / 2).ceil()) - 1)
                                        ? AppTheme.primary
                                        : AppTheme.outlineVariant,
                                  ),
                                ),
                                const SizedBox(width: 4.0),
                                Icon(
                                  Icons.chevron_right,
                                  color: (_currentSpreadIndex < math.max(1, (_pageUrls.length / 2).ceil()) - 1)
                                      ? AppTheme.secondary
                                      : AppTheme.outlineVariant,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 48.0),

            // Checkout Section (Split Grid)
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: AppConstants.maxContainerWidth),
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? AppConstants.gutter : AppConstants.mobileMargin,
                ),
                child: isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: _buildSummaryColumn()),
                          const SizedBox(width: 48.0),
                          Expanded(flex: 2, child: _buildPaymentColumn()),
                        ],
                      )
                    : Column(
                        children: [
                          _buildSummaryColumn(),
                          const SizedBox(height: 48.0),
                          _buildPaymentColumn(),
                        ],
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

  // Summary and Shipping Column
  Widget _buildSummaryColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ORDER SUMMARY',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
            letterSpacing: 1.0,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(height: 8.0),
        Container(
          height: 4.0,
          width: 80.0,
          decoration: BoxDecoration(
            color: AppTheme.secondary,
            borderRadius: BorderRadius.circular(2.0),
          ),
        ),
        const SizedBox(height: 32.0),

        // 1. Book Format Selection
        Text(
          'SELECT BOOK FORMAT',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 14.0,
            letterSpacing: 1.0,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(height: 12.0),
        Row(
          children: [
            Expanded(
              child: _buildBookFormatSelectionCard(
                'Softcover',
                widget.product.priceSoftcover,
                'Lightweight & flexible cover',
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: _buildBookFormatSelectionCard(
                'Hardcover',
                widget.product.priceHardcover,
                'Sturdy & premium keepsake',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24.0),

        // Selected Format Line-Item
        Container(
          decoration: BoxDecoration(
            color: AppTheme.secondaryContainer.withOpacity(0.08),
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            border: Border.all(color: AppTheme.secondary.withOpacity(0.3), width: 1.5),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.product.title} ($_selectedBookType)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
              Text(
                '₹$_basePrice',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16.0),

        // 2. Add-on Checkbox 1: Stickers
        MouseRegion(
          onEnter: (_) => setState(() => _isStickersHovered = true),
          onExit: (_) => setState(() => _isStickersHovered = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _addStickers = !_addStickers;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: _addStickers
                    ? AppTheme.secondaryContainer.withOpacity(0.15)
                    : Colors.white,
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                border: Border.all(
                  color: _addStickers
                      ? AppTheme.secondary
                      : (_isStickersHovered ? AppTheme.secondary.withOpacity(0.5) : AppTheme.outlineVariant),
                  width: 2.0,
                ),
              ),
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24.0,
                        height: 24.0,
                        decoration: BoxDecoration(
                          color: _addStickers ? AppTheme.secondary : Colors.transparent,
                          borderRadius: BorderRadius.circular(6.0),
                          border: Border.all(
                            color: _addStickers ? AppTheme.secondary : AppTheme.outlineVariant,
                            width: 2.0,
                          ),
                        ),
                        child: _addStickers
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16.0,
                              )
                            : null,
                      ),
                      const SizedBox(width: 16.0),
                      Text(
                        'Add matching personalized stickers',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15.0,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '+₹199',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 16.0),

        // 3. Add-on Checkbox 2: PDF
        MouseRegion(
          onEnter: (_) => setState(() => _isPdfHovered = true),
          onExit: (_) => setState(() => _isPdfHovered = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _addPdf = !_addPdf;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: _addPdf
                    ? AppTheme.secondaryContainer.withOpacity(0.15)
                    : Colors.white,
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                border: Border.all(
                  color: _addPdf
                      ? AppTheme.secondary
                      : (_isPdfHovered ? AppTheme.secondary.withOpacity(0.5) : AppTheme.outlineVariant),
                  width: 2.0,
                ),
              ),
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24.0,
                        height: 24.0,
                        decoration: BoxDecoration(
                          color: _addPdf ? AppTheme.secondary : Colors.transparent,
                          borderRadius: BorderRadius.circular(6.0),
                          border: Border.all(
                            color: _addPdf ? AppTheme.secondary : AppTheme.outlineVariant,
                            width: 2.0,
                          ),
                        ),
                        child: _addPdf
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16.0,
                              )
                            : null,
                      ),
                      const SizedBox(width: 16.0),
                      Text(
                        'Add high-res digital PDF copy',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15.0,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '+₹99',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 32.0),

        // 4. Shipping Address Field
        Text(
          'SHIPPING ADDRESS',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.0,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: AppTheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12.0),
        TextField(
          controller: _addressController,
          maxLines: 2,
          cursorColor: AppTheme.secondary,
          style: GoogleFonts.plusJakartaSans(color: AppTheme.primary),
          decoration: InputDecoration(
            hintText: 'Enter your delivery address...',
            hintStyle: GoogleFonts.plusJakartaSans(color: AppTheme.outlineVariant),
            prefixIcon: const Icon(Icons.local_shipping, color: AppTheme.secondary),
            filled: true,
            fillColor: AppTheme.surfaceContainerLow,
            contentPadding: const EdgeInsets.all(20.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              borderSide: const BorderSide(color: AppTheme.secondary, width: 2.0),
            ),
          ),
        ),
      ],
    );
  }

  // Payment Sticky Card Column
  Widget _buildPaymentColumn() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(
          color: AppTheme.secondary.withOpacity(0.1),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D110F2D),
            blurRadius: 30.0,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Total Amount Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'TOTAL AMOUNT',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              Text(
                '₹$_totalAmount',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondary,
                  letterSpacing: -1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32.0),

          // Pay Button
          MouseRegion(
            onEnter: (_) => setState(() => _isPayBtnHovered = true),
            onExit: (_) => setState(() => _isPayBtnHovered = false),
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: _triggerPaymentFlow,
              child: AnimatedScale(
                scale: _isPayBtnHovered ? 1.02 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.secondary,
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x4DA258F3),
                        blurRadius: 15.0,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'PAY & FINALIZE ORDER',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      const Icon(Icons.rocket_launch, color: Colors.white, size: 18.0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32.0),

          // Secure Payments Subheading
          Center(
            child: Text(
              'SECURE PAYMENTS VIA',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: AppTheme.onSurfaceVariant.withOpacity(0.6),
              ),
            ),
          ),
          const SizedBox(height: 16.0),

          // Payment Icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(Icons.credit_card, color: AppTheme.primary.withOpacity(0.6), size: 28.0),
              Container(width: 1.0, height: 20.0, color: AppTheme.outlineVariant),
              Icon(Icons.account_balance, color: AppTheme.primary.withOpacity(0.6), size: 28.0),
              Container(width: 1.0, height: 20.0, color: AppTheme.outlineVariant),
              Icon(Icons.contactless, color: AppTheme.primary.withOpacity(0.6), size: 28.0),
            ],
          ),

          const SizedBox(height: 32.0),

          // Guarantee badge
          Container(
            decoration: BoxDecoration(
              color: AppTheme.secondary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(AppConstants.radiusDefault),
              border: Border.all(color: AppTheme.secondary.withOpacity(0.1)),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2.0),
                  child: Icon(Icons.verified_user, color: AppTheme.secondary, size: 16.0),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    'Your order is protected by our magic guarantee. Hand-crafted with care and shipped within 3-5 business days.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.0,
                      height: 1.4,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookFormatSelectionCard(String format, int price, String description) {
    final isSelected = _selectedBookType == format;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBookType = format;
        });
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.secondaryContainer.withOpacity(0.15) : Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            border: Border.all(
              color: isSelected ? AppTheme.secondary : AppTheme.outlineVariant,
              width: 2.0,
            ),
          ),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    format,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                  Container(
                    width: 20.0,
                    height: 20.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppTheme.secondary : AppTheme.outlineVariant,
                        width: 2.0,
                      ),
                      color: isSelected ? AppTheme.secondary : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.circle,
                            color: Colors.white,
                            size: 10.0,
                          )
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 6.0),
              Text(
                description,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.0,
                  color: AppTheme.onSurfaceVariant.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 12.0),
              Text(
                '₹$price',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
