class PreviewItem {
  final String type;
  final List<String> urls;

  PreviewItem({required this.type, required this.urls});

  factory PreviewItem.fromJson(Map<String, dynamic> json) {
    return PreviewItem(
      type: json['type'] as String? ?? 'static',
      urls: json['urls'] != null ? List<String>.from(json['urls'] as List) : [],
    );
  }
}

class Product {
  final String id;
  final String title;
  final String ageRange;
  final String description;
  final double rating;
  final int reviewCount;
  final int priceHardcover;
  final int priceSoftcover;
  final int originalPriceHardcover;
  final int originalPriceSoftcover;
  final String coverImageUrl;
  final List<PreviewItem> previewItems;
  final List<String> features;
  final List<String> tags;
  final int? bookTemplateId;

  Product({
    required this.id,
    required this.title,
    required this.ageRange,
    required this.description,
    required this.rating,
    required this.reviewCount,
    required this.priceHardcover,
    required this.priceSoftcover,
    this.originalPriceHardcover = 1999,
    this.originalPriceSoftcover = 1499,
    required this.coverImageUrl,
    required this.previewItems,
    required this.features,
    this.tags = const [],
    this.bookTemplateId,
  });

  int get discountPercent {
    final orig = originalPriceSoftcover > 0 ? originalPriceSoftcover : 1499;
    if (orig <= priceSoftcover) return 0;
    return (((orig - priceSoftcover) / orig) * 100).round();
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    final List<PreviewItem> pItems = [];
    if (json['previewItems'] != null) {
      for (var item in (json['previewItems'] as List)) {
        pItems.add(PreviewItem.fromJson(item as Map<String, dynamic>));
      }
    } else if (json['previewImages'] != null) {
      // Fallback for old data format
      final oldImgs = List<String>.from(json['previewImages'] as List);
      for (var img in oldImgs) {
        pItems.add(PreviewItem(type: 'static', urls: [img]));
      }
    }

    String defaultCover = '';
    if (pItems.isNotEmpty && pItems.first.urls.isNotEmpty) {
      defaultCover = pItems.first.urls.first;
    }

    final pSoft = json['priceSoftcover'] as int? ?? 999;
    final pHard = json['priceHardcover'] as int? ?? 1499;
    final oSoft = json['originalPriceSoftcover'] as int? ?? (pSoft > 0 ? (pSoft * 1.5).round() : 1499);
    final oHard = json['originalPriceHardcover'] as int? ?? (pHard > 0 ? (pHard * 1.4).round() : 1999);

    final String productId = json['id'] as String? ?? '';
    final String productTitle = (json['title'] as String? ?? '').toLowerCase();
    List<String> defaultTags = [];
    if (productId == 'galactic-kid' || productTitle.contains('galactic')) {
      defaultTags = ['Persistence', 'Kindness', 'Curiosity'];
    } else if (productId == 'jurassic-friend' || productTitle.contains('jurassic')) {
      defaultTags = ['Teamwork', 'Bravery', 'Friendship'];
    } else if (productId == 'wild-safari' || productTitle.contains('safari')) {
      defaultTags = ['Empathy', 'Discovery', 'Patience'];
    } else if (productId == 'personalized-alphabet-book' || productTitle.contains('alphabet')) {
      defaultTags = ['Learning', 'Creativity', 'Fun'];
    }

    final rawTags = json['tags'];
    final List<String> parsedTags = (rawTags != null && (rawTags as List).isNotEmpty)
        ? List<String>.from(rawTags)
        : defaultTags;

    return Product(
      id: productId,
      title: json['title'] as String? ?? '',
      ageRange: json['ageRange'] as String? ?? '',
      description: json['description'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      priceHardcover: pHard,
      priceSoftcover: pSoft,
      originalPriceHardcover: oHard,
      originalPriceSoftcover: oSoft,
      coverImageUrl: json['coverImageUrl'] as String? ?? defaultCover,
      previewItems: pItems,
      features: json['features'] != null
          ? List<String>.from(json['features'] as List)
          : [],
      tags: parsedTags,
      bookTemplateId: json['bookTemplateId'] as int?,
    );
  }

  List<String> getCardImages() {
    // Return the slide images for the product card. If not found, return the first static image or empty list.
    for (var item in previewItems) {
      if (item.type == 'slide' && item.urls.isNotEmpty) {
        return item.urls;
      }
    }
    // Fallback to static images if no slide exists
    List<String> allStatic = [];
    for (var item in previewItems) {
      if (item.type == 'static') {
        allStatic.addAll(item.urls);
      }
    }
    return allStatic;
  }

  List<String> get previewImages {
    List<String> all = [];
    for (var item in previewItems) {
      all.addAll(item.urls);
    }
    return all;
  }
}
