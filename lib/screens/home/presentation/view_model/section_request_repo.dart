// data/section_request_repository.dart
import '../../data/section_request_model.dart';
import 'section_request_service.dart';

class SectionRequestRepository {
  final SectionRequestService _service = SectionRequestService();

  Future<SectionRequestResponse> submitRequest({
    required String name,
    required bool isWorking,
    required String longitude,
    required String latitude,
    required int categoryId,
  }) async {
    final request = SectionRequestModel(
      name: name,
      isWorking: isWorking,
      longitude: longitude,
      latitude: latitude,
      categoryId: categoryId,
    );

    return await _service.submitSectionRequest(request);
  }
}