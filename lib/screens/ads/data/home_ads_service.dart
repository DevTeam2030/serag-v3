import 'dart:convert';

import 'package:http/http.dart' as http;

import 'home_ads_model.dart';

abstract class HomeAdsService {

  Future<List<HomeAdModel>> fetchAds();

}

class HomeAdsServiceApi implements HomeAdsService {

  @override
  Future<List<HomeAdModel>> fetchAds() async {

    final url = Uri.parse(
      'https://devteam.website/serag-farm/public/api/get-home-ads',
    );

    final response = await http.get(
      url,
      headers: {
        "Accept": "application/json",
      },
    );

    print(response.body);

    if (response.statusCode == 200) {

      final body = jsonDecode(response.body);

      return (body["data"] as List)
          .map(
            (e) => HomeAdModel.fromJson(e),
      )
          .toList();
    }

    throw Exception("فشل تحميل الإعلانات");
  }
}