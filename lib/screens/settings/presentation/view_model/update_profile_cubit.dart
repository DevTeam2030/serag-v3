import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../constants/api_constants.dart';
import '../../../../core/helper/cache_helper.dart';
import 'auth_repo.dart';
import 'package:http/http.dart' as http;
part 'update_profile_state.dart';

class UpdateProfileCubit extends Cubit<UpdateProfileState> {
  UpdateProfileCubit() : super(UpdateProfileInitial());

  static UpdateProfileCubit of(BuildContext context) => BlocProvider.of(context);

  Future<void> updateProfile({
    required BuildContext context,
    required int establishmentTypeId,
    // Common fields
    required String username,
    required String phone,
    required String email,
    required String? password,
    required String latitude,
    required String longitude,
    required int? cityId,
    required String? userArea,
    required int? areaId, // ✅ NEW: Area ID parameter
    // المدجنة specific
    String? name,
    String? tenantName,
    int? buildingTypeId,
    int? technicalConditionId,
    int? heatingSystemId,
    int? waterSourceId,
    int? powerSourceId,
    String? supervisingDoctor,
    String? licenseNumber,
    String? licenseDate,
    String? foundationDate,
    String? area,
    String? numberFloors,
    // Other establishment types
    String? establishmentName,
    // المفقس specific
    String? operationalStatus,
    String? machinesCount,
    String? machineType,
    // مسلخ specific
    String? cagesCount,
    // معمل علف specific
    String? eggFeedProduction,
    String? broilerFeedProduction,
    // معمل كرتون البيض specific
    String? dailyBundles,
    // Common for all other types
    String? otherInfo,
  }) async {
    emit(UpdateProfileLoading());

    try {
      final url = Uri.parse("${ApiConstants.baseUrl}/update-profile");

      // Build request body based on establishment type
      Map<String, dynamic> requestBody = _buildRequestBody(
        establishmentTypeId: establishmentTypeId,
        username: username,
        phone: phone,
        email: email,
        password: password,
        latitude: latitude,
        longitude: longitude,
        cityId: cityId,
        userArea: userArea,
        areaId: areaId, // ✅ Pass area ID
        name: name,
        tenantName: tenantName,
        buildingTypeId: buildingTypeId,
        technicalConditionId: technicalConditionId,
        heatingSystemId: heatingSystemId,
        waterSourceId: waterSourceId,
        powerSourceId: powerSourceId,
        supervisingDoctor: supervisingDoctor,
        licenseNumber: licenseNumber,
        licenseDate: licenseDate,
        foundationDate: foundationDate,
        area: area,
        numberFloors: numberFloors,
        establishmentName: establishmentName,
        operationalStatus: operationalStatus,
        machinesCount: machinesCount,
        machineType: machineType,
        cagesCount: cagesCount,
        eggFeedProduction: eggFeedProduction,
        broilerFeedProduction: broilerFeedProduction,
        dailyBundles: dailyBundles,
        otherInfo: otherInfo,
      );

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${CacheHelper.getToken()}",
          "Accept": "application/json",
        },
        body: jsonEncode(requestBody),
      );

      print("Sending update profile request to $url");
      print("Request body: ${jsonEncode(requestBody)}");
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Profile update successful: ${response.body}");

        // Save data to cache based on establishment type
        await _saveUserData(
          establishmentTypeId: establishmentTypeId,
          username: username,
          phone: phone,
          email: email,
          password: password,
          latitude: latitude,
          longitude: longitude,
          cityId: cityId,
          userArea: userArea,
          areaId: areaId, // ✅ Save area ID
          name: name,
          tenantName: tenantName,
          buildingTypeId: buildingTypeId,
          technicalConditionId: technicalConditionId,
          heatingSystemId: heatingSystemId,
          waterSourceId: waterSourceId,
          powerSourceId: powerSourceId,
          supervisingDoctor: supervisingDoctor,
          licenseNumber: licenseNumber,
          licenseDate: licenseDate,
          foundationDate: foundationDate,
          area: area,
          numberFloors: numberFloors,
          establishmentName: establishmentName,
          operationalStatus: operationalStatus,
          machinesCount: machinesCount,
          machineType: machineType,
          cagesCount: cagesCount,
          eggFeedProduction: eggFeedProduction,
          broilerFeedProduction: broilerFeedProduction,
          dailyBundles: dailyBundles,
          otherInfo: otherInfo,
        );

        emit(UpdateProfileSuccess("تم تحديث الملف الشخصي بنجاح"));
      } else if (response.statusCode == 401) {
        print("Unauthorized: ${response.body}");
        emit(UpdateProfileError("غير مصرح لك بالوصول"));
      } else if (response.statusCode == 404) {
        print("Not Found: ${response.body}");
        emit(UpdateProfileError("المورد غير موجود"));
      } else if (response.statusCode == 500) {
        print("Server Error: ${response.body}");
        emit(UpdateProfileError("خطأ في الخادم، يرجى المحاولة لاحقًا"));
      } else if (response.statusCode == 422) {
        final decoded = jsonDecode(response.body)["message"];
        print(decoded);
        emit(UpdateProfileError(decoded ?? "خطأ في التحقق من البيانات"));
      } else {
        print("Error: ${response.statusCode}");
        final decoded = jsonDecode(response.body);
        emit(UpdateProfileError(decoded["message"] ?? "فشل تحديث الملف الشخصي"));
      }
    } catch (e) {
      emit(UpdateProfileError("خطأ في الاتصال بالسيرفر: $e"));
    }
  }

  Map<String, dynamic> _buildRequestBody({
    required int establishmentTypeId,
    required String username,
    required String phone,
    required String email,
    required String? password,
    required String latitude,
    required String longitude,
    required int? cityId,
    required String? userArea,
    required int? areaId, // ✅ NEW: Area ID
    String? name,
    String? tenantName,
    int? buildingTypeId,
    int? technicalConditionId,
    int? heatingSystemId,
    int? waterSourceId,
    int? powerSourceId,
    String? supervisingDoctor,
    String? licenseNumber,
    String? licenseDate,
    String? foundationDate,
    String? area,
    String? numberFloors,
    String? establishmentName,
    String? operationalStatus,
    String? machinesCount,
    String? machineType,
    String? cagesCount,
    String? eggFeedProduction,
    String? broilerFeedProduction,
    String? dailyBundles,
    String? otherInfo,
  }) {
    Map<String, dynamic> body = {
      "establishment_type_id": establishmentTypeId,
      "city_id": cityId,
      "user_area": area, // ✅ مساحة المبنى (بالمتر)
      "area": areaId, // ✅ رقم المنطقة الجغرافية

      "latitude": latitude,
      "longitude": longitude,
    };

    switch (establishmentTypeId) {
      case 1: // المدجنة
        body.addAll({
          "username": username,
          "name": name,
          "tenant_name": tenantName,
          "email": email.isEmpty ? null : email,
          "phone": phone,
          if (password != null && password.isNotEmpty) "password": password,
          if (password != null && password.isNotEmpty) "password_confirmation": password,
          "building_type_id": buildingTypeId,
          "technical_condition_id": technicalConditionId,
          "heating_system_id": heatingSystemId,
          "water_source_id": waterSourceId,
          "power_source_id": powerSourceId,
          "supervising_doctor": supervisingDoctor,
          "license_number": licenseNumber,
          "license_date": licenseDate,
          "user_area": area, // ✅ مساحة المبنى (زي ما في API)
          "number_floors": numberFloors,
          "establishment_date": foundationDate,
        });
        break;

      case 2: // المفقس
        body.addAll({
          "establishment_name": establishmentName,
          "username": username,
          if (password != null && password.isNotEmpty) "password": password,
          if (password != null && password.isNotEmpty) "password_confirmation": password,
          "phone": phone,
          "email": email,
          "is_active": operationalStatus == "يعمل" ? 1 : 0,
          "machines_count": int.tryParse(machinesCount ?? '0') ?? 0,
          "machine_type": machineType,
          "other": otherInfo?.isEmpty ?? true ? null : otherInfo,
        });
        break;

      case 3: // مسلخ
        body.addAll({
          "establishment_name": establishmentName,
          "username": username,
          if (password != null && password.isNotEmpty) "password": password,
          if (password != null && password.isNotEmpty) "password_confirmation": password,
          "phone": phone,
          "email": email,
          "cages_count": int.tryParse(cagesCount ?? '0') ?? 0,
          "other": otherInfo?.isEmpty ?? true ? null : otherInfo,
        });
        break;

      case 4: // معمل علف
        body.addAll({
          "establishment_name": establishmentName,
          "username": username,
          if (password != null && password.isNotEmpty) "password": password,
          if (password != null && password.isNotEmpty) "password_confirmation": password,
          "phone": phone,
          "email": email,
          "feed_egg_avg": double.tryParse(eggFeedProduction ?? '0') ?? 0.0,
          "feed_broiler_avg": double.tryParse(broilerFeedProduction ?? '0') ?? 0.0,
          "other": otherInfo?.isEmpty ?? true ? null : otherInfo,
        });
        break;

      case 5: // معمل كرتون البيض
        body.addAll({
          "establishment_name": establishmentName,
          "username": username,
          if (password != null && password.isNotEmpty) "password": password,
          if (password != null && password.isNotEmpty) "password_confirmation": password,
          "phone": phone,
          "email": email,
          "carton_bundle_avg": double.tryParse(dailyBundles ?? '0') ?? 0.0,
          "other": otherInfo?.isEmpty ?? true ? null : otherInfo,
        });
        break;
    }

    return body;
  }

  Future<void> _saveUserData({
    required int establishmentTypeId,
    required String username,
    required String phone,
    required String email,
    required String? password,
    required String latitude,
    required String longitude,
    required int? cityId,
    required String? userArea,
    required int? areaId, // ✅ NEW: Area ID
    String? name,
    String? tenantName,
    int? buildingTypeId,
    int? technicalConditionId,
    int? heatingSystemId,
    int? waterSourceId,
    int? powerSourceId,
    String? supervisingDoctor,
    String? licenseNumber,
    String? licenseDate,
    String? foundationDate,
    String? area,
    String? numberFloors,
    String? establishmentName,
    String? operationalStatus,
    String? machinesCount,
    String? machineType,
    String? cagesCount,
    String? eggFeedProduction,
    String? broilerFeedProduction,
    String? dailyBundles,
    String? otherInfo,
  }) async {
    // Save common data
    await CacheHelper.saveData('establishment_type_id', establishmentTypeId);
    await CacheHelper.saveData('user_phone', phone);
    if (password != null && password.isNotEmpty) {
      await CacheHelper.saveData('user_password', password);
    }
    await CacheHelper.saveData('city_id', cityId);
    await CacheHelper.saveData('area', userArea); // ✅ اسم المنطقة
    await CacheHelper.saveData('area_id', areaId); // ✅ رقم المنطقة
    await CacheHelper.saveData('user_area', area); // ✅ مساحة المبنى بالمتر
    await CacheHelper.saveData('latitude', latitude);
    await CacheHelper.saveData('longitude', longitude);

    if (establishmentTypeId == 1) {
      // المدجنة
      await CacheHelper.saveData('username', username);
      await CacheHelper.saveData('user_name', name);
      await CacheHelper.saveData('tenant_name', tenantName);
      await CacheHelper.saveData('user_email', email);
      await CacheHelper.saveData('building_type_id', buildingTypeId);
      await CacheHelper.saveData('technical_condition_id', technicalConditionId);
      await CacheHelper.saveData('heating_system_id', heatingSystemId);
      await CacheHelper.saveData('water_source_id', waterSourceId);
      await CacheHelper.saveData('power_source_id', powerSourceId);
      await CacheHelper.saveData('supervising_doctor', supervisingDoctor);
      await CacheHelper.saveData('license_number', licenseNumber);
      await CacheHelper.saveData('license_date', licenseDate);
      await CacheHelper.saveData('user_area', area); // ✅ Changed key
      await CacheHelper.saveData('number_floors', numberFloors);
      await CacheHelper.saveData('establishment_date', foundationDate);
    } else {
      // Other types
      await CacheHelper.saveData('establishment_name', establishmentName);
      await CacheHelper.saveData('username', username);
      await CacheHelper.saveData('user_email', email);
      await CacheHelper.saveData('other_info', otherInfo);

      if (establishmentTypeId == 2) {
        // المفقس
        await CacheHelper.saveData('operational_status', operationalStatus);
        await CacheHelper.saveData('machines_count', machinesCount);
        await CacheHelper.saveData('machine_type', machineType);
      } else if (establishmentTypeId == 3) {
        // مسلخ
        await CacheHelper.saveData('cages_count', cagesCount);
      } else if (establishmentTypeId == 4) {
        // معمل علف
        await CacheHelper.saveData('egg_feed_production', eggFeedProduction);
        await CacheHelper.saveData('broiler_feed_production', broilerFeedProduction);
      } else if (establishmentTypeId == 5) {
        // معمل كرتون البيض
        await CacheHelper.saveData('daily_bundles', dailyBundles);
      }
    }
  }
}