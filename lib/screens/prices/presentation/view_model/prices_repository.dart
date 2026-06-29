import '../../data/prices_model.dart';
import '../../data/prices_service.dart';

class PricesRepository {
  final PricesService service;

  PricesRepository({
    required this.service,
  });

  Future<Map<String, PriceCategoryModel>> getPrices() {
    return service.fetchPrices();
  }
}