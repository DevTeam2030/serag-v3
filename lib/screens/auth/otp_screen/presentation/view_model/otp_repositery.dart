import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:mine/constants/app_colors.dart';
import 'package:mine/constants/app_text_styles.dart';
import 'package:toastification/toastification.dart';

import '../../../../../constants/api_constants.dart';

class OtpRepository {
  final String baseUrl = "${ApiConstants.baseUrl}/auth";

  Future<bool> verifyOtp(String otp) async {
    await Future.delayed(const Duration(seconds: 1));
    return true; // Simulated success
  }

  Future<void> activateAccount({
    required String email,
    required String verificationCode,
    required BuildContext context,
  }) async {
    final url = Uri.parse("$baseUrl/activate-acount");

    print('🔵 Activating account...');
    print('📍 URL: $url');
    print('👤 Username: $email');
    print('🔑 Verification Code: $verificationCode');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": email,
          "verification_code": verificationCode,
        }),
      );

      print('📊 Response Status Code: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');
      print('🔗 Response URL: ${response.request?.url}');

      // Check if response is HTML (error page)
      if (response.body.trim().startsWith('<!DOCTYPE') ||
          response.body.trim().startsWith('<html')) {
        print('❌ Server returned HTML instead of JSON');
        throw Exception(
            "خطأ في الاتصال بالخادم. الرجاء التحقق من صحة رابط API"
        );
      }

      // Try to decode JSON
      dynamic body;
      try {
        body = jsonDecode(response.body);
        print('✅ JSON decoded successfully: $body');
      } catch (e) {
        print('❌ Failed to decode JSON: $e');
        throw Exception(
            "خطأ في معالجة استجابة الخادم. الرجاء المحاولة مرة أخرى"
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Account activated successfully');

        // toastification.show(
        //   context: context,
        //   title: Text(
        //     "تم التحقق من الرمز بنجاح",
        //     style: AppTextStyles.boldWhite12,
        //   ),
        //   autoCloseDuration: const Duration(seconds: 2),
        //   backgroundColor: AppColors.green,
        // );

        // Don't navigate here - let the Cubit handle it
      } else {
        print('❌ Activation failed with status: ${response.statusCode}');
        final errorMessage = body is Map ?
        (body['message'] ?? body['error'] ?? "حدث خطأ اثناء التفعيل") :
        "حدث خطأ اثناء التفعيل";

        throw Exception(errorMessage);
      }
    } on FormatException catch (e) {
      print('❌ FormatException: $e');
      throw Exception(
          "خطأ في معالجة البيانات. الرجاء التحقق من صحة رابط API"
      );
    } catch (e) {
      print('❌ General error: $e');
      rethrow;
    }
  }
}