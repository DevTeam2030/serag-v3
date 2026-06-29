import '../../data/ads_model.dart';
import '../../data/ads_service.dart';

class AdsRepository {

  final AdsService service;

  AdsRepository({

    required this.service,

  });

  Future<List<AdModel>>
  getAds(){

    return service.fetchAds();

  }

  Future<AdModel>
  getAdDetails(
      int id
      ){

    return service
        .fetchAdDetails(
      id,
    );

  }

}