import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../../constants/api_constants.dart';
import '../../../../../core/helper/cache_helper.dart';
import '../../../../../core/services/session_manager.dart';

class LoginRepository {
  final String baseUrl = "${ApiConstants.baseUrl}/auth";

  Future<void> login(String userName, String password) async {
    final url = Uri.parse("$baseUrl/login");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": userName,
        "password": password,
      }),
    );

    print("Data Sent to user is $userName And $password");
    print("RESPONSE OF LOGIN IS ${response.body}");

    final body = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      await CacheHelper.saveData("user_data", body['data']);

      // Common fields for all types
      final token = body['data']['access_token'];
      final tokenType = body['data']['token_type'];
      final expiresIn = body['data']['expires_in'];
      final id = body['data']['id'];
      final type = body['data']['type'];
      final userName = body['data']['name'];
      final tenantName = body['data']['tenant_name'];
      final userEmail = body['data']['email'];
      final userPhone = body['data']['phone'];
      final emailVerified = body['data']['email_verified_at'];
      final latitude = body['data']['latitude'];
      final longitude = body['data']['longitude'];
      final cityId = body['data']['city_id'];
      final city = body['data']['city'];
      final userArea = body['data']['user_area'];
      final establishmentTypeId = body['data']['establishment_type_id'];

      // المدجنة specific fields (establishment_type_id: 1)
      final buildingType = body['data']['building_type'];
      final buildingTypeId = body['data']['building_type_id'];
      final technicalCondition = body['data']['technical_condition'];
      final technicalConditionId = body['data']['technical_condition_id'];
      final heatingSystem = body['data']['heating_system'];
      final heatingSystemId = body['data']['heating_system_id'];
      final waterSource = body['data']['water_source'];
      final waterSourceId = body['data']['water_source_id'];
      final powerSource = body['data']['power_source'];
      final powerSourceId = body['data']['power_source_id'];
      final supervisingDoctor = body['data']['supervising_doctor'];
      final licenseNumber = body['data']['license_number'];
      final licenseDate = body['data']['license_date'];
      final area = body['data']['area'];
      final areaId = body['data']['area_id'];
      final numberFloors = body['data']['number_floors'];
      final establishmentDate = body['data']['establishment_date'];

      // Other establishment types fields
      final establishmentName = body['data']['establishment_name'];
      final isActive = body['data']['is_active'];
      final machinesCount = body['data']['machines_count'];
      final machineType = body['data']['machine_type'];
      final cagesCount = body['data']['cages_count'];
      final feedEggAvg = body['data']['feed_egg_avg'];
      final feedBroilerAvg = body['data']['feed_broiler_avg'];
      final cartonBundleAvg = body['data']['carton_bundle_avg'];
      final other = body['data']['other'];

      // Save all common data
      await CacheHelper.saveToken(token);
      await CacheHelper.saveData('access_token', token);
      await CacheHelper.saveData('token_type', tokenType);
      await CacheHelper.saveData('expires_in', expiresIn);
      await CacheHelper.saveData('user_id', id);
      await CacheHelper.saveData('user_type', type);
      await CacheHelper.saveData('username', userName);
      await CacheHelper.saveData('tenant_name', tenantName);
      await CacheHelper.saveData('user_email', userEmail);
      await CacheHelper.saveData('user_phone', userPhone);
      await CacheHelper.saveData('email_verified', emailVerified);
      await CacheHelper.saveData('user_password', password);
      await CacheHelper.saveData('latitude', latitude);
      await CacheHelper.saveData('longitude', longitude);
      await CacheHelper.saveData('city_id', cityId);
      await CacheHelper.saveData('city', city);
      await CacheHelper.saveData('user_area', userArea);
      await CacheHelper.saveData('establishment_type_id', establishmentTypeId);
      await SessionManager.saveLastLoginDate();

      // Save المدجنة specific data
      await CacheHelper.saveData('building_type', buildingType);
      await CacheHelper.saveData('building_type_id', buildingTypeId);
      await CacheHelper.saveData('technical_condition', technicalCondition);
      await CacheHelper.saveData('technical_condition_id', technicalConditionId);
      await CacheHelper.saveData('heating_system', heatingSystem);
      await CacheHelper.saveData('heating_system_id', heatingSystemId);
      await CacheHelper.saveData('water_source', waterSource);
      await CacheHelper.saveData('water_source_id', waterSourceId);
      await CacheHelper.saveData('power_source', powerSource);
      await CacheHelper.saveData('power_source_id', powerSourceId);
      await CacheHelper.saveData('supervising_doctor', supervisingDoctor);
      await CacheHelper.saveData('license_number', licenseNumber);
      await CacheHelper.saveData('license_date', licenseDate);
      await CacheHelper.saveData('area', area);
      await CacheHelper.saveData('area_id', areaId);
      await CacheHelper.saveData('number_floors', numberFloors);
      await CacheHelper.saveData('establishment_date', establishmentDate);

      // Save other establishment types data
      await CacheHelper.saveData('establishment_name', establishmentName);
      await CacheHelper.saveData('is_active', isActive);
      await CacheHelper.saveData('machines_count', machinesCount);
      await CacheHelper.saveData('machine_type', machineType);
      await CacheHelper.saveData('cages_count', cagesCount);
      await CacheHelper.saveData('feed_egg_avg', feedEggAvg);
      await CacheHelper.saveData('feed_broiler_avg', feedBroilerAvg);
      await CacheHelper.saveData('carton_bundle_avg', cartonBundleAvg);
      await CacheHelper.saveData('other', other);

    } else {
      print("Error is ${body['message']}");
      throw Exception(body['message'] ?? "خطأ أثناء تسجيل الدخول");
    }
  }}