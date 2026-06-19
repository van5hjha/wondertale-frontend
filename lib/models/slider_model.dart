class SliderModel {
  final int id;
  final String title;
  final String beforeImageUrl;
  final String afterImageUrl;

  SliderModel({
    required this.id,
    required this.title,
    required this.beforeImageUrl,
    required this.afterImageUrl,
  });

  factory SliderModel.fromJson(Map<String, dynamic> json) {
    return SliderModel(
      id: json['id'] as int,
      title: json['title'] as String,
      beforeImageUrl: json['beforeImageUrl'] as String,
      afterImageUrl: json['afterImageUrl'] as String,
    );
  }
}
