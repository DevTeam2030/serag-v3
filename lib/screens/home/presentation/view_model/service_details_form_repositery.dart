
import 'service_details_form_service.dart';

class ServiceDetailsFormRepository {
  final ServiceDetailsFormService service;
  ServiceDetailsFormRepository({required this.service});

  Future<void> submitDetails(Map<String, dynamic> payload) async {
    await service.submitServiceDetails(payload);
  }
}
