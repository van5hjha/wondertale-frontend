import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/slider_model.dart';
import 'api_config.dart';
import 'api_utils.dart';

class SlidersService {
  /// Calls `GET /api/sliders/` to fetch active before-after slides.
  Future<List<SliderModel>> fetchSliders() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/sliders/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => SliderModel.fromJson(json)).toList();
    } else {
      final errorMsg = parseError(response.body);
      throw Exception('Failed to fetch sliders: $errorMsg');
    }
  }
}
