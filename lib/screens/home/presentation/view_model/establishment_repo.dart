import '../../data/establishment_model.dart';
import 'establishment_service.dart';

class EstablishmentRepository {
  final EstablishmentService _service;

  EstablishmentRepository(this._service);

  Future<List<EstablishmentModel>> getEstablishments() async {
    try {
      final response = await _service.getEstablishments();
      return response.data;
      
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }

  Future<AssignEstablishmentResponse> assignEstablishment(int id) async {
    try {
      final response = await _service.assignEstablishment(id);
      return response; // Return the full response object
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }
}