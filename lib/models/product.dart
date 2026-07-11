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
  final String coverImageUrl;
  final List<PreviewItem> previewItems;
  final List<String> features;
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
    required this.coverImageUrl,
    required this.previewItems,
    required this.features,
    this.bookTemplateId,
  });

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

    return Product(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      ageRange: json['ageRange'] as String? ?? '',
      description: json['description'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      priceHardcover: json['priceHardcover'] as int? ?? 0,
      priceSoftcover: json['priceSoftcover'] as int? ?? 0,
      coverImageUrl: json['coverImageUrl'] as String? ?? defaultCover,
      previewItems: pItems,
      features: json['features'] != null
          ? List<String>.from(json['features'] as List)
          : [],
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
