import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;
import 'package:http/http.dart' as http;
import 'package:mine/screens/auth/login/presentation/view/login_screen.dart';
import 'package:mine/screens/auth/otp_screen/presentation/view/otp_screen.dart';
import '../../../../../constants/api_constants.dart';
import '../../../../../core/helper/cache_helper.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(RegisterInitial());

  static RegisterCubit of(BuildContext context) => BlocProvider.of(context);

  final formKey = GlobalKey<FormState>();

  // Common fields for all types
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  // المدجنة specific
  final ownerNameController = TextEditingController();
  final consultantNameController = TextEditingController();

  // Other establishment types
  final establishmentNameController = TextEditingController();

  // المفقس specific
  final machinesCountController = TextEditingController();
  String? machineType;
  String? operationalStatus;

  // مسلخ specific
  final cagesCountController = TextEditingController();

  // معمل علف specific
  final eggFeedProductionController = TextEditingController();
  final broilerFeedProductionController = TextEditingController();

  // معمل كرتون البيض specific
  final dailyBundlesController = TextEditingController();

  // Common for all
  final otherInfoController = TextEditingController();

  LatLng? selectedLocation;

  void setMachineType(String? value) {
    machineType = value;
    emit(RegisterFieldUpdated());
  }

  void setOperationalStatus(String? value) {
    operationalStatus = value;
    emit(RegisterFieldUpdated());
  }

  void setSelectedLocation(LatLng location) {
    selectedLocation = location;
    emit(SignupLocationUpdated(location));
  }

  // ✅ Updated signUp method with area ID parameter
  Future<void> signUp({
    required BuildContext context,
    required int establishmentTypeId,
    int? buildingTypeId,
    int? technicalConditionId,
    int? heatingSystemId,
    int? waterSourceId,
    int? powerSourceId,
    String? supervisingDoctor,
    String? licenseNumber,
    String? licenseDate,
    String? establishmentDate,
    String? buildingArea, // ✅ Renamed for clarity (building area)
    String? numberFloors,
    required String latitude,
    required String longitude,
    required int? cityId,
    required String? userArea, // ✅ Area name
    required int? areaId, // ✅ NEW: Area ID
  }) async {
    if (!formKey.currentState!.validate()) {
      emit(RegisterValidationError("الرجاء تعبئة جميع الحقول بشكل صحيح"));
      return;
    }

    emit(RegisterLoading());

    try {
      final url = Uri.parse("${ApiConstants.baseUrl}/auth/register");

      // Build request body based on establishment type
      Map<String, dynamic> requestBody = _buildRequestBody(
        establishmentTypeId: establishmentTypeId,
        buildingTypeId: buildingTypeId,
        technicalConditionId: technicalConditionId,
        heatingSystemId: heatingSystemId,
        waterSourceId: waterSourceId,
        powerSourceId: powerSourceId,
        supervisingDoctor: supervisingDoctor,
        licenseNumber: licenseNumber,
        licenseDate: licenseDate,
        establishmentDate: establishmentDate,
        buildingArea: buildingArea,
        numberFloors: numberFloors,
        latitude: latitude,
        longitude: longitude,
        cityId: cityId,
        userArea: userArea,
        areaId: areaId, // ✅ Pass area ID
      );

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestBody),
      );

      print("Sending registration request to $url");
      print("Request body: ${jsonEncode(requestBody)}");
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("Registration successful: ${response.body}");

        // Save common data
        await _saveUserData(
          establishmentTypeId: establishmentTypeId,
          buildingTypeId: buildingTypeId,
          technicalConditionId: technicalConditionId,
          heatingSystemId: heatingSystemId,
          waterSourceId: waterSourceId,
          powerSourceId: powerSourceId,
          supervisingDoctor: supervisingDoctor,
          licenseNumber: licenseNumber,
          licenseDate: licenseDate,
          establishmentDate: establishmentDate,
          buildingArea: buildingArea,
          numberFloors: numberFloors,
          latitude: latitude,
          longitude: longitude,
          cityId: cityId,
          userArea: userArea,
          areaId: areaId, // ✅ Save area ID
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("تم تسجيل المستخدم بنجاح"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => OtpScreen(),
            transitionDuration: const Duration(seconds: 1),
          ),
        );

        emit(RegisterSuccess("تم تسجيل المستخدم بنجاح"));
      } else if (response.statusCode == 422) {
        final decoded = jsonDecode(response.body)["message"];
        print(decoded);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(decoded ?? "خطأ في التحقق من البيانات"),
            backgroundColor: Colors.red,
          ),
        );
        String errorMessage = decoded ?? "خطأ في التحقق من البيانات";
        emit(RegisterError(errorMessage));
      } else if (response.statusCode == 401) {
        print("Unauthorized: ${response.body}");
        emit(RegisterError("غير مصرح لك بالوصول"));
      } else if (response.statusCode == 404) {
        print("Not Found: ${response.body}");
        emit(RegisterError("المورد غير موجود"));
      } else if (response.statusCode == 500) {
        print("Server Error: ${response.body}");
        emit(RegisterError("خطأ في الخادم، يرجى المحاولة لاحقًا"));
      } else {
        print("Error: ${response.statusCode}");
        final decoded = jsonDecode(response.body);
        emit(RegisterError(decoded["message"] ?? "فشل التسجيل"));
      }
    } catch (e) {
      emit(RegisterError("خطأ في الاتصال بالسيرفر: $e"));
    }
  }

  // ✅ Updated _buildRequestBody with area ID
  Map<String, dynamic> _buildRequestBody({
    required int establishmentTypeId,
    int? buildingTypeId,
    int? technicalConditionId,
    int? heatingSystemId,
    int? waterSourceId,
    int? powerSourceId,
    String? supervisingDoctor,
    String? licenseNumber,
    String? licenseDate,
    String? establishmentDate,
    String? buildingArea,
    String? numberFloors,
    required String latitude,
    required String longitude,
    required int? cityId,
    required String? userArea, // ✅ Area name
    required int? areaId, // ✅ Area ID
  }) {
    Map<String, dynamic> body = {
      "establishment_type_id": establishmentTypeId,
      "city_id": cityId,
      "user_area": userArea, // ✅ Area name as string
      "area": areaId, // ✅ Area ID for all types
      "latitude": latitude,
      "longitude": longitude,
    };

    switch (establishmentTypeId) {
      case 1: // المدجنة
        body.addAll({
          "username": usernameController.text,
          "name": ownerNameController.text,
          "tenant_name": consultantNameController.text,
          "email": emailController.text.isEmpty ? null : emailController.text,
          "phone": phoneController.text,
          "password": passwordController.text,
          "password_confirmation": passwordController.text,
          "building_type_id": buildingTypeId,
          "technical_condition_id": technicalConditionId,
          "heating_system_id": heatingSystemId,
          "water_source_id": waterSourceId,
          "power_source_id": powerSourceId,
          "supervising_doctor": supervisingDoctor,
          "license_number": licenseNumber,
          "license_date": licenseDate,
          "building_area": buildingArea, // ✅ Building area separate key
          "number_floors": numberFloors,
          "establishment_date": establishmentDate,
        });
        break;

      case 2: // المفقس
        body.addAll({
          "establishment_name": establishmentNameController.text,
          "username": usernameController.text,
          "password": passwordController.text,
          "password_confirmation": passwordController.text,
          "phone": phoneController.text,
          "email": emailController.text,
          "is_active": operationalStatus == "يعمل" ? 1 : 0,
          "machines_count": int.tryParse(machinesCountController.text) ?? 0,
          "machine_type": machineType,
          "other": otherInfoController.text.isEmpty ? null : otherInfoController.text,
        });
        break;

      case 3: // مسلخ
        body.addAll({
          "establishment_name": establishmentNameController.text,
          "username": usernameController.text,
          "password": passwordController.text,
          "password_confirmation": passwordController.text,
          "phone": phoneController.text,
          "email": emailController.text,
          "cages_count": int.tryParse(cagesCountController.text) ?? 0,
          "other": otherInfoController.text.isEmpty ? null : otherInfoController.text,
        });
        break;

      case 4: // معمل علف
        body.addAll({
          "establishment_name": establishmentNameController.text,
          "username": usernameController.text,
          "password": passwordController.text,
          "password_confirmation": passwordController.text,
          "phone": phoneController.text,
          "email": emailController.text,
          "feed_egg_avg": double.tryParse(eggFeedProductionController.text) ?? 0.0,
          "feed_broiler_avg": double.tryParse(broilerFeedProductionController.text) ?? 0.0,
          "other": otherInfoController.text.isEmpty ? null : otherInfoController.text,
        });
        break;

      case 5: // معمل كرتون البيض
        body.addAll({
          "establishment_name": establishmentNameController.text,
          "username": usernameController.text,
          "password": passwordController.text,
          "password_confirmation": passwordController.text,
          "phone": phoneController.text,
          "email": emailController.text,
          "carton_bundle_avg": double.tryParse(dailyBundlesController.text) ?? 0.0,
          "other": otherInfoController.text.isEmpty ? null : otherInfoController.text,
        });
        break;
    }

    return body;
  }

  // ✅ Updated _saveUserData with area ID
  Future<void> _saveUserData({
    required int establishmentTypeId,
    int? buildingTypeId,
    int? technicalConditionId,
    int? heatingSystemId,
    int? waterSourceId,
    int? powerSourceId,
    String? supervisingDoctor,
    String? licenseNumber,
    String? licenseDate,
    String? establishmentDate,
    String? buildingArea,
    String? numberFloors,
    required String latitude,
    required String longitude,
    required int? cityId,
    required String? userArea,
    required int? areaId, // ✅ NEW
  }) async {
    // Save common data
    await CacheHelper.saveData('establishment_type_id', establishmentTypeId);
    await CacheHelper.saveData('user_phone', phoneController.text);
    await CacheHelper.saveData('user_password', passwordController.text);
    await CacheHelper.saveData('city_id', cityId);
    await CacheHelper.saveData('user_area', userArea);
    await CacheHelper.saveData('area_id', areaId); // ✅ رقم المنطقة
    await CacheHelper.saveData('latitude', latitude);
    await CacheHelper.saveData('longitude', longitude);

    if (establishmentTypeId == 1) {
      // المدجنة
      await CacheHelper.saveData('username', usernameController.text);
      await CacheHelper.saveData('user_name', ownerNameController.text);
      await CacheHelper.saveData('tenant_name', consultantNameController.text);
      await CacheHelper.saveData('user_email', emailController.text);
      await CacheHelper.saveData('building_type_id', buildingTypeId);
      await CacheHelper.saveData('technical_condition_id', technicalConditionId);
      await CacheHelper.saveData('heating_system_id', heatingSystemId);
      await CacheHelper.saveData('water_source_id', waterSourceId);
      await CacheHelper.saveData('power_source_id', powerSourceId);
      await CacheHelper.saveData('supervising_doctor', supervisingDoctor);
      await CacheHelper.saveData('license_number', licenseNumber);
      await CacheHelper.saveData('license_date', licenseDate);
      await CacheHelper.saveData('user_area', userArea); // ✅ المساحة الحقيقية من المستخدم
      await CacheHelper.saveData('number_floors', numberFloors);
      await CacheHelper.saveData('establishment_date', establishmentDate);
    } else {
      // Other types
      await CacheHelper.saveData('establishment_name', establishmentNameController.text);
      await CacheHelper.saveData('username', usernameController.text);
      await CacheHelper.saveData('user_email', emailController.text);
      await CacheHelper.saveData('other_info', otherInfoController.text);

      if (establishmentTypeId == 2) {
        // المفقس
        await CacheHelper.saveData('operational_status', operationalStatus);
        await CacheHelper.saveData('machines_count', machinesCountController.text);
        await CacheHelper.saveData('machine_type', machineType);
      } else if (establishmentTypeId == 3) {
        // مسلخ
        await CacheHelper.saveData('cages_count', cagesCountController.text);
      } else if (establishmentTypeId == 4) {
        // معمل علف
        await CacheHelper.saveData('egg_feed_production', eggFeedProductionController.text);
        await CacheHelper.saveData('broiler_feed_production', broilerFeedProductionController.text);
      } else if (establishmentTypeId == 5) {
        // معمل كرتون البيض
        await CacheHelper.saveData('daily_bundles', dailyBundlesController.text);
      }
    }
  }


  // Add this method to RegisterCubit class

  /// Checks if username, email, or phone already exist in the system
  Future<bool> checkUserDataExists({
    required BuildContext context,
    required String username,
    String? email,
     String ?phone,
  }) async {
    try {
      emit(CheckUserExistLoading());
      final url = Uri.parse("${ApiConstants.baseUrl}/auth/check-user-data");

      final requestBody = {
        "username": username,
        "email": email ?? "",
        "phone": phone ??"",
      };

      print("Checking user data existence...");
      print("Request body: ${jsonEncode(requestBody)}");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestBody),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 422) {
        // User data exists - show error message
        String errorMessage = decoded["message"] ?? "البيانات موجودة بالفعل";

        // Extract specific field errors if available
        if (decoded["data"] != null) {
          final data = decoded["data"] as Map<String, dynamic>;
          List<String> errors = [];

          data.forEach((key, value) {
            if (value is List && value.isNotEmpty) {
              errors.add(value[0].toString());
            }
          });

          if (errors.isNotEmpty) {
            errorMessage = errors.join('\n');
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );

        return true; // Data exists
      } else if (response.statusCode == 201 || response.statusCode == 200) {
        // User data is available
        print("User data is available - proceeding with registration");
        return false; // Data doesn't exist
      } else {
        // Unexpected status code
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("خطأ غير متوقع: ${decoded["message"] ?? "حدث خطأ"}"),
            backgroundColor: Colors.orange,
          ),
        );
        return true; // Prevent navigation on error
      }
    } catch (e) {
      print("Error checking user data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("خطأ في الاتصال بالسيرفر: $e"),
          backgroundColor: Colors.red,
        ),
      );
      return true; // Prevent navigation on error
    }
  }

  Future<void> submitWithValidation(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      emit(RegisterValidationError("الرجاء تعبئة جميع الحقول بشكل صحيح"));
      return;
    }

    // Show loading indicator
    emit(RegisterLoading());

    // Check if user data exists
    final dataExists = await checkUserDataExists(
      context: context,
      username: usernameController.text,
      email: emailController.text.isEmpty ? null : emailController.text,
      phone: phoneController.text.isEmpty ? null : phoneController.text, // ✅ Optional
    );

    if (dataExists) {
      // User data exists, stop here
      emit(RegisterInitial());
      return;
    }

    // If data doesn't exist, proceed with validation success
    emit(RegisterValidation('تم تعبئة البيانات بنجاح'));
  }



  void submit() {
    if (formKey.currentState!.validate()) {
      emit(RegisterValidation('تم تعبئة البيانات بنجاح'));
    } else {
      emit(RegisterValidationError("الرجاء تعبئة جميع الحقول بشكل صحيح"));
    }
  }

  void clearControllers() {
    // Clear all text controllers
    usernameController.clear();
    ownerNameController.clear();
    consultantNameController.clear();
    emailController.clear();
    phoneController.clear();
    passwordController.clear();
    establishmentNameController.clear();
    machinesCountController.clear();
    cagesCountController.clear();
    eggFeedProductionController.clear();
    broilerFeedProductionController.clear();
    dailyBundlesController.clear();
    otherInfoController.clear();

    // Clear dropdown selections
    operationalStatus = null;
    machineType = null;

    // Notify listeners if needed
    emit(RegisterInitial());
  }
  @override
  Future<void> close() {
    usernameController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    emailController.dispose();
    ownerNameController.dispose();
    consultantNameController.dispose();
    establishmentNameController.dispose();
    machinesCountController.dispose();
    cagesCountController.dispose();
    eggFeedProductionController.dispose();
    broilerFeedProductionController.dispose();
    dailyBundlesController.dispose();
    otherInfoController.dispose();
    return super.close();
  }
}