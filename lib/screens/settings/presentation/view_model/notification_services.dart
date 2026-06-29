import 'package:dio/dio.dart';
import '../../../../constants/api_constants.dart';
import '../../../../core/helper/cache_helper.dart';

class NotificationService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: "${ApiConstants.baseUrl}",
  ));

  Future<Map<String, dynamic>> fetchNotifications() async {
    try {
      final response = await _dio.get(
        "/user-notifications",
        options: Options(
          headers: {
            "Authorization": "Bearer ${CacheHelper.getToken()}",
            "Accept": "application/json",
          },
        ),
      );

      print("Notifications Response: ${response.data}");
      return response.data;
    } on DioError catch (e) {
      if (e.response != null) {
        print("Notifications Error Response: ${e.response!.data}");
        return e.response!.data;
      } else {
        throw Exception("Network error");
      }
    }
  }
}
