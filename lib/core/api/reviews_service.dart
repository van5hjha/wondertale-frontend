import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/review_model.dart';
import 'api_config.dart';
import 'api_utils.dart';

class ReviewsService {
  /// Calls `GET /api/reviews/` to fetch active reviews.
  Future<List<ReviewModel>> fetchReviews() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/reviews/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ReviewModel.fromJson(json)).toList();
    } else {
      final errorMsg = parseError(response.body);
      throw Exception('Failed to fetch reviews: $errorMsg');
    }
  }
}
