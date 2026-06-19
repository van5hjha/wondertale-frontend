import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'api_utils.dart';

class StartPreviewService {
  /// Calls `POST /api/previews/<id>/start/` to trigger generation.
  Future<void> startPreviewGeneration(String previewRequestId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/previews/$previewRequestId/start/');
    final response = await http.post(url);

    if (response.statusCode != 200) {
      final errorMsg = parseError(response.body);
      throw Exception('Failed to start preview generation: $errorMsg');
    }
  }
}
