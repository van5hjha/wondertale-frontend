import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'api_utils.dart';

class CreatePreviewService {
  /// Calls `POST /api/previews/` with user selections and photos.
  /// Returns the generated `preview_request_id`.
  Future<String> createPreviewRequest({
    required String productId,
    required int? bookTemplateId,
    required String contactEmail,
    required String childName,
    required String ageRange,
    required String gender,
    required List<PlatformFile> photos,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/previews/');
    final request = http.MultipartRequest('POST', url);

    // Use dynamic bookTemplateId from backend catalog mapping, falling back to 2
    request.fields['book_template_id'] = bookTemplateId?.toString() ?? '2';
    request.fields['contact_email'] = contactEmail;
    request.fields['child_name'] = childName;
    request.fields['child_age'] = extractAge(ageRange).toString();
    request.fields['child_gender'] = normalizeGender(gender);

    if (photos.isEmpty) {
      throw Exception('At least one photo is required to generate a preview.');
    }

    // Pad photos to always submit exactly 3 photo fields (photo1, photo2, photo3)
    final List<PlatformFile> paddedPhotos = [];
    if (photos.length == 1) {
      paddedPhotos.addAll([photos[0], photos[0], photos[0]]);
    } else if (photos.length == 2) {
      paddedPhotos.addAll([photos[0], photos[0], photos[1]]);
    } else {
      paddedPhotos.addAll(photos.take(3));
    }

    for (int i = 0; i < 3; i++) {
      final file = paddedPhotos[i];
      final fieldName = 'photo${i + 1}';

      if (kIsWeb) {
        if (file.bytes == null) {
          throw Exception('File bytes are empty for ${file.name} on Web platform.');
        }
        request.files.add(
          http.MultipartFile.fromBytes(
            fieldName,
            file.bytes!,
            filename: file.name,
          ),
        );
      } else {
        if (file.path != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              fieldName,
              file.path!,
              filename: file.name,
            ),
          );
        } else if (file.bytes != null) {
          request.files.add(
            http.MultipartFile.fromBytes(
              fieldName,
              file.bytes!,
              filename: file.name,
            ),
          );
        } else {
          throw Exception('Could not read file data for ${file.name}.');
        }
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return data['preview_request_id'] as String;
    } else {
      final errorMsg = parseError(response.body);
      throw Exception('Failed to create preview session: $errorMsg');
    }
  }
}
