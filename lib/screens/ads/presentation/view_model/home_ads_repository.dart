import '../../data/home_ads_model.dart';
import '../../data/home_ads_service.dart';

class HomeAdsRepository {

  final HomeAdsService service;

  HomeAdsRepository({
    required this.service,
  });

  Future<List<HomeAdModel>> getAds() {

    return service.fetchAds();

  }
}