// data/section_request_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../../constants/api_constants.dart';
import '../../../../../core/helper/cache_helper.dart';
import '../../data/section_request_model.dart';

class SectionRequestService {
  Future<SectionRequestResponse> submitSectionRequest(
      SectionRequestModel request) async {
    final url = Uri.parse("${ApiConstants.baseUrl}/section-request");
    final token = await CacheHelper.getToken();

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(request.toJson()),
    );

    print("Section Request URL: $url");
    print("Section Request Body: ${jsonEncode(request.toJson())}");
    print("Response Status: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return SectionRequestResponse.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'فشل إرسال الطلب');
    }
  }
}