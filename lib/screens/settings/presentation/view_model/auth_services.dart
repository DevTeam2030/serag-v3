import 'package:dio/dio.dart';

import '../../../../constants/api_constants.dart';
import '../../../../core/helper/cache_helper.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: "${ApiConstants.baseUrl}",
  ));

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _dio.post(
        "/change-password",
        data: {
          "current_password": currentPassword,
          "password": newPassword,
          "password_confirmation": confirmPassword,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer ${CacheHelper.getToken()}",
            "Accept": "application/json",
            "Content-Type": "application/json",
          },
        ),
      );
print("Response data: ${response.data}");
print("Response status code: ${response.statusCode}");
      return response.data;
    } on DioError catch (e) {
      if (e.response != null) {
        print("Response data: ${e.response!.data}");
        return e.response!.data;
      } else {
        throw Exception("Network error");
      }
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String tenantName,
    required String phone,
    required String email,
  }) async {
    try {
      final response = await _dio.post(
        "/update-profile",
        data: {
          "name": name,
          "tenant_name": tenantName,
          "phone": phone,
          "email": email,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer ${CacheHelper.getToken()}",
            "Accept": "application/json",
            "Content-Type": "application/json",
          },
        ),
      );

      print("Response data: ${response.data}");
      return response.data;
    } on DioError catch (e) {
      if (e.response != null) {
        print("Response error data: ${e.response!.data}");
        return e.response!.data;
      } else {
        throw Exception("Network error");
      }
    }

  }
  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final response = await _dio.post(
        "/delete-account",
        options: Options(
          headers: {
            "Authorization": "Bearer ${CacheHelper.getToken()}",
            "Accept": "application/json",
            "Content-Type": "application/json",
          },
        ),
      );

      print("Response data: ${response.data}");
      return response.data;
    } on DioError catch (e) {
      if (e.response != null) {
        print("Response error data: ${e.response!.data}");
        return e.response!.data;
      } else {
        throw Exception("Network error");
      }
    }
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await _dio.post(
        "/auth/logout",
        options: Options(
          headers: {
            "Authorization": "Bearer ${CacheHelper.getToken()}",
            "Accept": "application/json",
            "Content-Type": "application/json",
          },
        ),
      );

      print("Response data: ${response.data}");
      print("Response status code: ${response.statusCode}");
      print("Response headers: ${response.headers}");
      return response.data;
    } on DioError catch (e) {
      if (e.response != null) {
        print("Response error data: ${e.response!.data}");
        return e.response!.data;
      } else {
        throw Exception("Network error");
      }
    }
  }



}
