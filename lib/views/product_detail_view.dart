import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:desktop_drop/desktop_drop.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../core/legal_config.dart';
import '../models/product.dart';
import '../core/api/products_service.dart';
import '../widgets/navbar.dart';
import '../widgets/footer.dart';
import '../widgets/story_card.dart';
import 'home_view.dart';
import 'package:google_fonts/google_fonts.dart';

import 'preview_loading_view.dart';
import 'products_view.dart';

class ProductDetailView extends StatefulWidget {
  final Product product;

  const ProductDetailView({super.key, required this.product});

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  List<Product> _allProducts = [];
  bool _isLoadingProducts = true;
  final ProductsService _productsService = ProductsService();

  @override
  void initState() {
    super.initState();
    _loadAllProducts();
  }

  Future<void> _loadAllProducts() async {
    try {
      final paginated = await _productsService.fetchProducts();
      if (mounted) {
        setState(() {
          _allProducts = paginated.products;
          _isLoadingProducts = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading products from API: $e. Falling back to local assets.');
      try {
        final paginated = await _productsService.loadLocalProducts();
        if (mounted) {
          setState(() {
            _allProducts = paginated.products;
            _isLoadingProducts = false;
          });
        }
      } catch (assetErr) {
        debugPrint('Error loading fallback products.json: $assetErr');
        if (mounted) {
          setState(() {
            _isLoadingProducts = false;
          });
        }
      }
    }
  }


  void _navigateBack(BuildContext context, int scrollIndex) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(scrollIndex);
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeView()),
      );
    }
  }

  Widget _buildCatalogSection(BuildContext context, bool isTablet) {
    final otherProducts = _allProducts.where((p) => p.id != widget.product.id).toList();

    if (_isLoadingProducts) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppTheme.secondary),
          ),
        ),
      );
    }

    if (otherProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EXPLORE MORE MAGICAL ADVENTURES',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: isTablet ? 20.0 : 16.0,
                        letterSpacing: 1.0,
                      ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Personalize another bedtime story for your little ones.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24.0),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final crossAxisCount = width >= 640 ? 2 : 1;
            final totalSpacing = 24.0 * (crossAxisCount - 1);
            final cardWidth = (width - totalSpacing) / crossAxisCount;
            final imageHeight = cardWidth * (2.0 / 3.0);
            final totalHeight = imageHeight + 200.0;
            final childAspectRatio = cardWidth / totalHeight;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 24.0,
                mainAxisSpacing: 24.0,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: otherProducts.length,
              itemBuilder: (context, index) {
                final prod = otherProducts[index];
                return StoryCard(
                  title: prod.title,
                  ageRange: prod.ageRange,
                  description: prod.description,
                  imageUrls: prod.previewImages,
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => ProductDetailView(product: prod),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 960.0;
    final isTablet = width >= 640.0;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: NavBar(
        activeIndex: -1,
        onHomeTap: () => _navigateBack(context, -1),
        onExploreStoriesTap: () => _navigateBack(context, 0),
        onHowItWorksTap: () => _navigateBack(context, 1),
        onPricingTap: () => _navigateBack(context, 2),
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
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: 40.0,
                horizontal: isTablet ? AppConstants.desktopMargin : AppConstants.mobileMargin,
              ),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: AppConstants.maxContainerWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSubHeader(context, isTablet),
                      const SizedBox(height: 24.0),
                      isDesktop
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 7,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      ProductPreviewSection(product: widget.product),
                                      const SizedBox(height: 32.0),
                                      FeaturesChips(features: widget.product.features),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: AppConstants.gutter * 2),
                                Expanded(
                                  flex: 5,
                                  child: CustomizationForm(product: widget.product),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ProductPreviewSection(product: widget.product),
                                const SizedBox(height: 32.0),
                                FeaturesChips(features: widget.product.features),
                                const SizedBox(height: 40.0),
                                CustomizationForm(product: widget.product),
                              ],
                            ),
                      const SizedBox(height: 80.0),
                      _buildCatalogSection(context, isTablet),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 60.0),
            const Footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildSubHeader(BuildContext context, bool isTablet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => _navigateBack(context, -1),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.arrow_back,
                  color: AppTheme.onSurfaceVariant,
                  size: 20.0,
                ),
                const SizedBox(width: 8.0),
                if (isTablet)
                  Text(
                    'BACK TO STORIES',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppTheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.0,
                        ),
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                widget.product.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: (isTablet
                        ? Theme.of(context).textTheme.headlineMedium
                        : Theme.of(context).textTheme.bodyLarge)
                    ?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.secondaryContainer,
            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star,
                color: AppTheme.secondary,
                size: 16.0,
              ),
              const SizedBox(width: 4.0),
              Text(
                '${widget.product.rating}/5',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppTheme.onSecondaryContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.0,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ProductPreviewSection extends StatefulWidget {
  final Product product;
  const ProductPreviewSection({super.key, required this.product});

  @override
  State<ProductPreviewSection> createState() => _ProductPreviewSectionState();
}

class _ProductPreviewSectionState extends State<ProductPreviewSection> {
  late String _activeImageUrl;
  bool _isSeeInsideBtnHovered = false;

  @override
  void initState() {
    super.initState();
    _activeImageUrl = widget.product.coverImageUrl;
  }

  Widget _buildThumbnail(String imageUrl) {
    final isSelected = _activeImageUrl == imageUrl;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeImageUrl = imageUrl;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 96.0,
        height: 64.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.radiusDefault),
          border: Border.all(
            color: isSelected ? AppTheme.secondary : Colors.transparent,
            width: 2.0,
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x33A258F3),
                    blurRadius: 8.0,
                    spreadRadius: 2.0,
                  )
                ]
              : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: imageUrl.startsWith('http')
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
              )
            : Image.asset(
                imageUrl,
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  void _showInsidePagesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800.0, maxHeight: 600.0),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            ),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sample Interior Pages',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 4 / 3,
                    ),
                    itemCount: widget.product.previewImages.length,
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(AppConstants.radiusDefault),
                        child: widget.product.previewImages[index].startsWith('http')
                            ? Image.network(
                                widget.product.previewImages[index],
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                widget.product.previewImages[index],
                                fit: BoxFit.cover,
                              ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            boxShadow: const [
              BoxShadow(
                color: AppTheme.shadowColor,
                blurRadius: 30.0,
                offset: Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: AppTheme.primary.withOpacity(0.05),
              width: 1.0,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: AspectRatio(
            aspectRatio: 3 / 2,
            child: _activeImageUrl.startsWith('http')
                ? Image.network(
                    _activeImageUrl,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    _activeImageUrl,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        const SizedBox(height: 24.0),
        if (widget.product.previewImages.isNotEmpty) ...[
          SizedBox(
            height: 64.0,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: widget.product.previewImages.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12.0),
              itemBuilder: (context, index) {
                return _buildThumbnail(widget.product.previewImages[index]);
              },
            ),
          ),
          const SizedBox(height: 32.0),
        ],
        MouseRegion(
          onEnter: (_) => setState(() => _isSeeInsideBtnHovered = true),
          onExit: (_) => setState(() => _isSeeInsideBtnHovered = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              _showInsidePagesDialog(context);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: _isSeeInsideBtnHovered ? AppTheme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(AppConstants.radiusDefault),
                border: Border.all(
                  color: AppTheme.primary,
                  width: 2.0,
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_stories,
                    color: _isSeeInsideBtnHovered ? Colors.white : AppTheme.primary,
                    size: 20.0,
                  ),
                  const SizedBox(width: 12.0),
                  Text(
                    'SEE INSIDE: SAMPLE PAGES',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: _isSeeInsideBtnHovered ? Colors.white : AppTheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                          letterSpacing: 0.8,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class FeaturesChips extends StatelessWidget {
  final List<String> features;
  const FeaturesChips({super.key, required this.features});

  Widget _buildFeatureCard(BuildContext context, {required IconData icon, required String text, required double width}) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.secondary, size: 24.0),
          const SizedBox(height: 12.0),
          Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                  fontSize: 12.0,
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultIcons = [Icons.menu_book, Icons.face, Icons.local_shipping];
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth = (constraints.maxWidth - 24.0) / 3.0;
        final double finalCardWidth = cardWidth < 120.0 ? 120.0 : cardWidth;
        
        return Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          alignment: WrapAlignment.center,
          children: List.generate(features.length, (index) {
            return _buildFeatureCard(
              context,
              icon: index < defaultIcons.length ? defaultIcons[index] : Icons.star,
              text: features[index],
              width: finalCardWidth,
            );
          }),
        );
      },
    );
  }
}

class CustomizationForm extends StatefulWidget {
  final Product product;
  const CustomizationForm({super.key, required this.product});

  @override
  State<CustomizationForm> createState() => _CustomizationFormState();
}

class _CustomizationFormState extends State<CustomizationForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _selectedAgeRange = '4-6 yrs';
  String _selectedGender = 'Neutral (They/Them)';
  bool _isUploading = false;
  final List<PlatformFile> _selectedFiles = [];
  String _selectedBookType = 'Hardcover';
  bool _hasConsent = false;
  bool _isGenerateBtnHovered = false;
  bool _isDragging = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _pickPhotos() async {
    if (_selectedFiles.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ You can upload a maximum of 3 photos.'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _isUploading = true;
        });

        // Simulate a brief analysis/loading animation
        await Future.delayed(const Duration(milliseconds: 800));

        setState(() {
          _isUploading = false;
          // Add files up to max of 3
          final remainingSlots = 3 - _selectedFiles.length;
          final newFiles = result.files.take(remainingSlots);
          _selectedFiles.addAll(newFiles);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✨ Loaded ${_selectedFiles.length} photo(s). AI Face scan ready.'),
              backgroundColor: AppTheme.secondary,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error picking files: $e');
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  void _onFilesDropped(List<dynamic> files) async {
    if (_selectedFiles.length >= 3) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ You can upload a maximum of 3 photos.'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Simulate a brief analysis/loading animation
      await Future.delayed(const Duration(milliseconds: 800));

      final remainingSlots = 3 - _selectedFiles.length;
      final droppedFiles = files.take(remainingSlots);

      final List<PlatformFile> newFiles = [];
      for (final file in droppedFiles) {
        final name = file.name;
        final extension = name.split('.').last.toLowerCase();
        final allowedExtensions = ['jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp', 'heic'];
        if (!allowedExtensions.contains(extension)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('⚠️ File "$name" is not a supported image format.'),
                backgroundColor: AppTheme.error,
              ),
            );
          }
          continue;
        }

        final bytes = await file.readAsBytes();
        newFiles.add(
          PlatformFile(
            name: name,
            size: bytes.length,
            bytes: bytes,
            path: kIsWeb ? null : file.path,
          ),
        );
      }

      setState(() {
        _selectedFiles.addAll(newFiles);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✨ Loaded ${_selectedFiles.length} photo(s). AI Face scan ready.'),
            backgroundColor: AppTheme.secondary,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error processing dropped files: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Widget _buildFileThumbnail(PlatformFile file) {
    if (kIsWeb) {
      if (file.bytes != null) {
        return Image.memory(
          file.bytes!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppTheme.surfaceContainerLow,
              child: const Center(
                child: Icon(
                  Icons.broken_image,
                  color: AppTheme.secondary,
                  size: 32.0,
                ),
              ),
            );
          },
        );
      }
    } else {
      if (file.path != null) {
        return Image.file(
          io.File(file.path!),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppTheme.surfaceContainerLow,
              child: const Center(
                child: Icon(
                  Icons.broken_image,
                  color: AppTheme.secondary,
                  size: 32.0,
                ),
              ),
            );
          },
        );
      }
    }
    return const Icon(Icons.insert_drive_file, color: AppTheme.secondary);
  }

  void _triggerGeneratePreview() {
    final childName = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (childName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Please enter your child\'s name to generate preview.'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Please enter your email address to proceed.'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    final bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
    if (!emailValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Please enter a valid email address.'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    if (!_hasConsent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ You must consent that you have permission to use the child\'s photos.'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    if (_selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Please upload at least one photo to generate custom AI faces.'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PreviewLoadingView(
          product: widget.product,
          contactEmail: email,
          childName: childName,
          ageRange: _selectedAgeRange,
          gender: _selectedGender,
          bookType: _selectedBookType,
          photos: List.from(_selectedFiles),
        ),
      ),
    );
  }



  Widget _buildSegmentedTab(String label) {
    final isSelected = _selectedAgeRange == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedAgeRange = label;
          });
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(AppConstants.radiusDefault - 2),
              boxShadow: isSelected
                  ? const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4.0,
                        offset: Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: isSelected ? AppTheme.secondary : AppTheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13.0,
                  ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderButton(String label, double maxWidth) {
    final isSelected = _selectedGender == label;
    double buttonWidth = (maxWidth - 16.0) / 3.0;
    if (buttonWidth < 100.0) buttonWidth = maxWidth;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = label;
        });
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: buttonWidth,
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.secondaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(AppConstants.radiusDefault),
            border: Border.all(
              color: isSelected ? AppTheme.secondary : AppTheme.primary.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: isSelected ? AppTheme.onSecondaryContainer : AppTheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12.0,
                ),
          ),
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(
          color: AppTheme.primary.withOpacity(0.05),
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Child\'s Name',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 8.0),
          Stack(
            alignment: Alignment.centerRight,
            children: [
              TextField(
                controller: _nameController,
                maxLength: 12,
                cursorColor: AppTheme.secondary,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.primary,
                    ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'e.g. Advait',
                  filled: true,
                  fillColor: AppTheme.surfaceContainerLow,
                  contentPadding: const EdgeInsets.all(16.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusDefault),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusDefault),
                    borderSide: const BorderSide(color: AppTheme.secondary, width: 2.0),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(
                  'MAX 12',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppTheme.onSurfaceVariant.withOpacity(0.5),
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24.0),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Age Range',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  color: AppTheme.primary,
                ),
              ),
              if (MediaQuery.of(context).size.width >= 400.0)
                Expanded(
                  child: Text(
                    '(Adapts story diff & text)',
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppTheme.onSurfaceVariant.withOpacity(0.7),
                          fontSize: 11.0,
                        ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12.0),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppConstants.radiusDefault),
            ),
            padding: const EdgeInsets.all(4.0),
            child: Row(
              children: [
                _buildSegmentedTab('0-3 yrs'),
                _buildSegmentedTab('4-6 yrs'),
                _buildSegmentedTab('7-9 yrs'),
              ],
            ),
          ),
          const SizedBox(height: 24.0),

          Text(
            'Gender / Pronoun',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 12.0),
          LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  _buildGenderButton('Boy (He/Him)', constraints.maxWidth),
                  _buildGenderButton('Girl (She/Her)', constraints.maxWidth),
                  _buildGenderButton('Neutral (They/Them)', constraints.maxWidth),
                ],
              );
            },
          ),
          const SizedBox(height: 24.0),



          Text(
            'Upload Child\'s Photo',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 12.0),
          DropTarget(
            onDragEntered: (detail) {
              setState(() {
                _isDragging = true;
              });
            },
            onDragExited: (detail) {
              setState(() {
                _isDragging = false;
              });
            },
            onDragDone: (detail) {
              _onFilesDropped(detail.files);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                border: Border.all(
                  color: _isDragging ? AppTheme.secondary : Colors.transparent,
                  width: 2.0,
                ),
                boxShadow: _isDragging
                    ? [
                        BoxShadow(
                          color: AppTheme.secondary.withOpacity(0.25),
                          blurRadius: 16.0,
                          spreadRadius: 2.0,
                        ),
                      ]
                    : [],
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_isUploading) ...[
                        Container(
                          height: 120.0,
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                            border: Border.all(
                              color: AppTheme.primary.withOpacity(0.15),
                              width: 2.0,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 24.0,
                                height: 24.0,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3.0,
                                  valueColor: AlwaysStoppedAnimation(AppTheme.secondary),
                                ),
                              ),
                              const SizedBox(height: 12.0),
                              Text(
                                'Analyzing photo face ID...',
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                      color: AppTheme.secondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ] else if (_selectedFiles.isEmpty) ...[
                        GestureDetector(
                          onTap: _pickPhotos,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                                border: Border.all(
                                  color: AppTheme.primary.withOpacity(0.15),
                                  width: 2.0,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
                              child: Column(
                                children: [
                                  Container(
                                    width: 44.0,
                                    height: 44.0,
                                    decoration: const BoxDecoration(
                                      color: AppTheme.secondaryContainer,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.photo_camera,
                                      color: AppTheme.secondary,
                                      size: 20.0,
                                    ),
                                  ),
                                  const SizedBox(height: 12.0),
                                  Text(
                                    'Click or drag & drop photo(s)',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primary,
                                        ),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    '(Select up to 3 photos of your child)',
                                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                          color: AppTheme.onSurfaceVariant,
                                          fontSize: 12.0,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryContainer.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                            border: Border.all(
                              color: AppTheme.secondary.withOpacity(0.3),
                              width: 2.0,
                            ),
                          ),
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Wrap(
                                spacing: 12.0,
                                runSpacing: 12.0,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  ...List.generate(_selectedFiles.length, (index) {
                                    final file = _selectedFiles[index];
                                    return Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Container(
                                          width: 80.0,
                                          height: 80.0,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(AppConstants.radiusDefault),
                                            border: Border.all(color: AppTheme.secondary, width: 1.5),
                                          ),
                                          clipBehavior: Clip.antiAlias,
                                          child: _buildFileThumbnail(file),
                                        ),
                                        Positioned(
                                          top: -6.0,
                                          right: -6.0,
                                          child: GestureDetector(
                                            onTap: () => _removePhoto(index),
                                            behavior: HitTestBehavior.opaque,
                                            child: MouseRegion(
                                              cursor: SystemMouseCursors.click,
                                              child: Container(
                                                width: 24.0,
                                                height: 24.0,
                                                decoration: const BoxDecoration(
                                                  color: Colors.red,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.close,
                                                    color: Colors.white,
                                                    size: 14.0,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                  if (_selectedFiles.length < 3)
                                    GestureDetector(
                                      onTap: _pickPhotos,
                                      child: MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: Container(
                                          width: 80.0,
                                          height: 80.0,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(AppConstants.radiusDefault),
                                            border: Border.all(
                                              color: AppTheme.secondary.withOpacity(0.5),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.add_a_photo,
                                            color: AppTheme.secondary,
                                            size: 24.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '✨ AI Face scan ready. ${_selectedFiles.length} photo(s) selected.',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: AppTheme.secondary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedFiles.clear();
                                      });
                                    },
                                    child: const Text(
                                      'Reset All',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (_isDragging)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.secondary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                          border: Border.all(
                            color: AppTheme.secondary,
                            width: 2.0,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 56.0,
                                height: 56.0,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.secondary.withOpacity(0.2),
                                      blurRadius: 10.0,
                                      spreadRadius: 2.0,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.file_upload,
                                  color: AppTheme.secondary,
                                  size: 28.0,
                                ),
                              ),
                              const SizedBox(height: 12.0),
                              Text(
                                'Drop to upload photo(s)',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.secondary,
                                      fontSize: 16.0,
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
          ),
          const SizedBox(height: 24.0),

          // Parent's Email Address
          Text(
            "Parent's Email Address",
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 12.0),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            cursorColor: AppTheme.secondary,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.primary,
                ),
            decoration: InputDecoration(
              hintText: 'Enter your email for preview delivery...',
              hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.onSurfaceVariant.withOpacity(0.5),
                  ),
              prefixIcon: const Icon(Icons.email, color: AppTheme.secondary),
              filled: true,
              fillColor: AppTheme.surfaceContainerLow,
              contentPadding: const EdgeInsets.all(16.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusDefault),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusDefault),
                borderSide: const BorderSide(color: AppTheme.secondary, width: 2.0),
              ),
            ),
          ),
          const SizedBox(height: 24.0),

          // Guardian Consent Checkbox
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _hasConsent = !_hasConsent;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _hasConsent ? AppTheme.secondary.withOpacity(0.05) : AppTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppConstants.radiusDefault),
                  border: Border.all(
                    color: _hasConsent ? AppTheme.secondary : AppTheme.primary.withOpacity(0.1),
                    width: 1.5,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Row(
                  children: [
                    Checkbox(
                      value: _hasConsent,
                      activeColor: AppTheme.secondary,
                      onChanged: (val) {
                        setState(() {
                          _hasConsent = val ?? false;
                        });
                      },
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        "I have the consent from guardians to use this child's photos",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 32.0),

          // Price and Delivery Summary Card
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppConstants.radiusDefault),
              border: Border.all(
                color: AppTheme.primary.withOpacity(0.05),
                width: 1.0,
              ),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Starting Price:',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppTheme.onSurfaceVariant,
                            fontSize: 12.0,
                          ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      '${LegalConfig.currencySymbol}${widget.product.priceSoftcover} - ${LegalConfig.currencySymbol}${widget.product.priceHardcover}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Text(
                      '🚚 Delivery Timeline:',
                      style: TextStyle(
                        color: AppTheme.secondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.0,
                      ),
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      LegalConfig.estimatedDeliveryTime,
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32.0),

          MouseRegion(
            onEnter: (_) => setState(() => _isGenerateBtnHovered = true),
            onExit: (_) => setState(() => _isGenerateBtnHovered = false),
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                _triggerGeneratePreview();
              },
              child: AnimatedScale(
                scale: _isGenerateBtnHovered ? 1.02 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.secondary,
                    borderRadius: BorderRadius.circular(AppConstants.radiusDefault),
                    boxShadow: _isGenerateBtnHovered
                        ? const [
                            BoxShadow(
                              color: Color(0x66A258F3),
                              blurRadius: 18.0,
                              offset: Offset(0, 6),
                            ),
                          ]
                        : const [
                            BoxShadow(
                              color: Color(0x33A258F3),
                              blurRadius: 10.0,
                              offset: Offset(0, 4),
                            ),
                          ],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'GENERATE MY FREE PREVIEW',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppTheme.onPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                              letterSpacing: 0.8,
                            ),
                      ),
                      const SizedBox(width: 8.0),
                      const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 18.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Text(
            '* Digital preview is 100% free. No payment details required to preview.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppTheme.onSurfaceVariant.withOpacity(0.7),
                  fontSize: 12.0,
                ),
          ),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.local_shipping, size: 14.0, color: AppTheme.onSurfaceVariant),
              SizedBox(width: 6.0),
              Text(
                'Free delivery in India via Delhivery & BlueDart',
                style: TextStyle(
                  color: AppTheme.onSurfaceVariant,
                  fontSize: 11.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
