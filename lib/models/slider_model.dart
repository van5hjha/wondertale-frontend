class SliderModel {
  final int id;
  final String title;
  final String type; // 'before_after' or 'static'
  final String? beforeImageUrl;
  final String? afterImageUrl;
  final String? imageUrl;

  SliderModel({
    required this.id,
    required this.title,
    this.type = 'before_after',
    this.beforeImageUrl,
    this.afterImageUrl,
    this.imageUrl,
  });

  bool get isBeforeAfter =>
      type == 'before_after' &&
      beforeImageUrl != null &&
      beforeImageUrl!.isNotEmpty &&
      afterImageUrl != null &&
      afterImageUrl!.isNotEmpty;

  String get effectiveImageUrl =>
      (imageUrl != null && imageUrl!.isNotEmpty)
          ? imageUrl!
          : (beforeImageUrl ?? afterImageUrl ?? '');

  factory SliderModel.fromJson(Map<String, dynamic> json) {
    return SliderModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      type: json['type'] as String? ?? 'before_after',
      beforeImageUrl: json['beforeImageUrl'] as String?,
      afterImageUrl: json['afterImageUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}
