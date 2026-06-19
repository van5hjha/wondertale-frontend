class ReviewModel {
  final int id;
  final String name;
  final String location;
  final String quote;
  final int rating;
  final String? productId;
  final String? userId;

  ReviewModel({
    required this.id,
    required this.name,
    required this.location,
    required this.quote,
    required this.rating,
    this.productId,
    this.userId,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as int,
      name: json['name'] as String,
      location: json['location'] as String,
      quote: json['quote'] as String,
      rating: json['rating'] as int,
      productId: json['product_id'] != null ? json['product_id'].toString() : null,
      userId: json['user_id'] != null ? json['user_id'].toString() : null,
    );
  }
}
