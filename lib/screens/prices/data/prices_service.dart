import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mine/screens/prices/data/prices_model.dart';

import '../../../constants/api_constants.dart';

abstract class PricesService {
  Future<Map<String, PriceCategoryModel>> fetchPrices();
}

class PricesServiceApi implements PricesService {
  @override
  Future<Map<String, PriceCategoryModel>> fetchPrices() async {
    final url = Uri.parse("${ApiConstants.baseUrl}/prices");

    final response = await http.get(
      url,
      headers: {
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      final Map<String, dynamic> data = body["data"];

      final Map<String, PriceCategoryModel> result = {};

      data.forEach((key, value) {
        result[key] = PriceCategoryModel.fromJson(value);
      });

      return result;
    }

    throw Exception("فشل تحميل الأسعار");
  }
}