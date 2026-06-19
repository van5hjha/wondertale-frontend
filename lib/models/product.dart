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
  final List<String> previewImages;
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
    required this.previewImages,
    required this.features,
    this.bookTemplateId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final previewImgs = json['previewImages'] != null
        ? List<String>.from(json['previewImages'] as List)
        : <String>[];

    return Product(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      ageRange: json['ageRange'] as String? ?? '',
      description: json['description'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      priceHardcover: json['priceHardcover'] as int? ?? 0,
      priceSoftcover: json['priceSoftcover'] as int? ?? 0,
      coverImageUrl: json['coverImageUrl'] as String? ??
          (previewImgs.isNotEmpty ? previewImgs[0] : ''),
      previewImages: previewImgs,
      features: json['features'] != null
          ? List<String>.from(json['features'] as List)
          : [],
      bookTemplateId: json['bookTemplateId'] as int?,
    );
  }
}

