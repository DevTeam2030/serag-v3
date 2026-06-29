import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../constants/api_constants.dart';

class ForgetPasswordService {
  Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    final url = Uri.parse(
        '${ApiConstants.baseUrl}/auth/password-reset-email');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': email}),
    );

    print('Sending password reset request to $url');
    print('Request body: ${jsonEncode({'email': email})}');
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    return {
      'statusCode': response.statusCode,
      'body': jsonDecode(response.body),
    };
  }
}