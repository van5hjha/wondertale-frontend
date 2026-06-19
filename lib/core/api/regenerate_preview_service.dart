import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'api_utils.dart';

class RegeneratePreviewService {
  /// Calls `POST /api/previews/<id>/regenerate/<page_number>/` to trigger page regeneration.
  Future<void> regeneratePreviewPage(String previewRequestId, int pageNumber) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/previews/$previewRequestId/regenerate/$pageNumber/');
    final response = await http.post(url);

    if (response.statusCode != 200) {
      final errorMsg = parseError(response.body);
      throw Exception('Failed to regenerate preview page: $errorMsg');
    }
  }
}
