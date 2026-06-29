// services/settings_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mine/screens/auth/register/data/settings_model.dart';
import '../../../../constants/api_constants.dart';
import '../models/settings_response.dart';

class SettingsService {
  static const String _baseUrl =
      "${ApiConstants.baseUrl}/settings?lang=ar";

  Future<SettingsResponse> fetchSettings() async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 15), // Increased timeout for Syria users
        onTimeout: () {
          throw Exception("انتهت مهلة الاتصال. يرجى المحاولة لاحقاً");
        },
      );

      print("Fetching settings from $_baseUrl");
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 401) {
        throw Exception("Unauthorized access. Please log in again.");
      }
      if (response.statusCode == 404) {
        throw Exception("Settings not found. Please check the URL.");
      }
      if (response.statusCode == 500) {
        throw Exception("Server error. Please try again later.");
      }

      if (response.statusCode == 200) {
        return settingsResponseFromJson(response.body);
      } else {
        throw Exception("Failed to load settings: ${response.statusCode}");
      }
    } catch (e) {
      print("Settings fetch error: $e");
      rethrow; // Re-throw to be handled by the cubit
    }
  }
}
