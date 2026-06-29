import 'dart:convert';

import 'package:http/http.dart' as http;

import 'ads_model.dart';

abstract class AdsService {

  Future<List<AdModel>> fetchAds();

  Future<AdModel> fetchAdDetails(
      int id,
      );

}

class AdsServiceApi
    implements AdsService{

  static const baseUrl=

      'https://devteam.website/serag-farm/public/api';

  @override

  Future<List<AdModel>>
  fetchAds() async{

    final response=
    await http.get(

      Uri.parse(
        '$baseUrl/get-ads',
      ),

      headers:{

        "Accept":
        "application/json",

      },

    );

    if(
    response.statusCode==200
    ){

      final body=
      jsonDecode(
        response.body,
      );

      return (body['data']
      as List)

          .map(
            (e)=>

            AdModel.fromJson(
              e,
            ),

      )

          .toList();

    }

    throw Exception(
      'فشل تحميل الإعلانات',
    );

  }

  @override

  Future<AdModel>
  fetchAdDetails(
      int id
      ) async{

    final response=
    await http.get(

      Uri.parse(
        '$baseUrl/get-ad?id=$id',
      ),

      headers:{

        "Accept":
        "application/json",

      },

    );

    if(
    response.statusCode==200
    ){

      final body=
      jsonDecode(
        response.body,
      );

      return AdModel.fromJson(
        body['data'],
      );

    }

    throw Exception(
      'فشل تحميل التفاصيل',
    );

  }

}