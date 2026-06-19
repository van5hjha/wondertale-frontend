import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'api_utils.dart';

class PollPreviewService {
  /// Calls `GET /api/previews/<id>/status/` to poll for completion.
  /// Returns a map with 'status' (String) and 'pages' (List<String> of URLs).
  Future<Map<String, dynamic>> pollPreviewStatus(String previewRequestId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/previews/$previewRequestId/status/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final status = data['status'] as String;
      final pagesList = data['pages'] as List<dynamic>? ?? [];

      final List<String> imageUrls = [];
      for (var page in pagesList) {
        if (page['image_url'] != null) {
          imageUrls.add(page['image_url'] as String);
        }
      }

      return {
        'status': status,
        'pages': imageUrls,
      };
    } else {
      final errorMsg = parseError(response.body);
      throw Exception('Failed to check preview status: $errorMsg');
    }
  }
}
