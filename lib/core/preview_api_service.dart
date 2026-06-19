import 'package:file_picker/file_picker.dart';
import 'api/create_preview_service.dart';
import 'api/start_preview_service.dart';
import 'api/poll_preview_service.dart';
import 'api/regenerate_preview_service.dart';

class PreviewApiService {
  final CreatePreviewService _createService = CreatePreviewService();
  final StartPreviewService _startService = StartPreviewService();
  final PollPreviewService _pollService = PollPreviewService();
  final RegeneratePreviewService _regenerateService = RegeneratePreviewService();

  // Constructor preserved for compatibility
  PreviewApiService({String? baseUrl});

  /// 1. Create Preview Request: Upload photos and details.
  Future<String> createPreviewRequest({
    required String productId,
    required int? bookTemplateId,
    required String contactEmail,
    required String childName,
    required String ageRange,
    required String gender,
    required List<PlatformFile> photos,
  }) {
    return _createService.createPreviewRequest(
      productId: productId,
      bookTemplateId: bookTemplateId,
      contactEmail: contactEmail,
      childName: childName,
      ageRange: ageRange,
      gender: gender,
      photos: photos,
    );
  }


  /// 2. Start Preview Generation: Triggers Celery task in the backend.
  Future<void> startPreviewGeneration(String previewRequestId) {
    return _startService.startPreviewGeneration(previewRequestId);
  }

  /// 3. Poll Preview Status: Checks generation progress and gets finished page URLs.
  Future<Map<String, dynamic>> pollPreviewStatus(String previewRequestId) {
    return _pollService.pollPreviewStatus(previewRequestId);
  }

  /// 4. Regenerate Preview Page: Triggers regeneration of a specific page.
  Future<void> regeneratePreviewPage(String previewRequestId, int pageNumber) {
    return _regenerateService.regeneratePreviewPage(previewRequestId, pageNumber);
  }
}
