import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mine/core/helper/cache_helper.dart';
import 'package:mine/core/services/session_manager.dart';
import 'package:mine/main.dart';
import '../../data/settings_model.dart';
import '../../data/settings_service.dart';
import 'building_info_states.dart';

class ProjectDataCubit extends Cubit<ProjectDataState> {
  final SettingsService _service = SettingsService();

  ProjectDataCubit() : super(BuildingInfoInitial()) {
    meatQuantityCtrl.addListener(_calculateConversionRate);
    feedQuantityCtrl.addListener(_calculateConversionRate);
  }

  static ProjectDataCubit of(BuildContext context) =>
      BlocProvider.of<ProjectDataCubit>(context);

  final formKey = GlobalKey<FormState>();

  final foundationDateController = TextEditingController();
  final licenseNumberController = TextEditingController();
  final licenseDateController = TextEditingController();
  final supervisingDoctorController = TextEditingController();
  final areaController = TextEditingController();
  final floorsCountController = TextEditingController();
  final areaNameController = TextEditingController();
  final userAreaController = TextEditingController(); // ✳️ للمساحة فقط

  int? buildingTypeId;
  int? technicalConditionId;
  int? heatingSystemId;
  int? waterSourceId;
  int? powerSourceId;
  int? selectedCityId;
  int? selectedEstablishmentTypeId;
  String? selectedAreaName;
  int? selectedAreaId; // ✅ NEW: Store area ID
  SettingsData? settingsData;

  final projectNameCtrl = TextEditingController();
  final chickSourceCtrl = TextEditingController();
  final chicksNumberCtrl = TextEditingController();
  final startDateCtrl = TextEditingController();
  final endDateCtrl = TextEditingController();
  final feedSourceCtrl = TextEditingController();
  final feedQuantityCtrl = TextEditingController();
  final conversionRateCtrl = TextEditingController();
  final deadBirdsCtrl = TextEditingController();
  final meatQuantityCtrl = TextEditingController();

  final otherDiseaseCtrl = TextEditingController();
  final otherVaccinationCtrl = TextEditingController();

  // Dropdown selections
  int? selectedCategoryId;
  int? selectedDistributionChannelId;
  int? selectedDiseaseTypeId;
  int? selectedVaccinationProgramId;

  void setEstablishmentType(int? id) {
    selectedEstablishmentTypeId = id;
    if (settingsData != null) emit(BuildingInfoLoaded(settingsData!));
  }

  double? _calculateConversionRate() {
    final meat = double.tryParse(meatQuantityCtrl.text.trim());
    final feed = double.tryParse(feedQuantityCtrl.text.trim());

    if (meat != null && feed != null && feed > 0) {
      final rate = (meat / feed) * 100;
      conversionRateCtrl.text = rate % 1 == 0 ? rate.toInt().toString() : rate.toStringAsFixed(2);
      return rate;
    } else {
      conversionRateCtrl.text = '';
      return null;
    }
  }

  Future<void> _checkSessionAfterSettingsLoad() async {
    final token = CacheHelper.getToken();
    if (token == null || token.isEmpty || settingsData == null) {
      return;
    }

    final inactivityDays =
        SessionManager.parseInactivityDays(settingsData!.inactivityDays);
    final expired = await SessionManager.isSessionExpired(inactivityDays);

    if (expired) {
      await SessionManager.logout(navigatorKey.currentContext);
    }
  }

  Future<void> fetchSettings() async {
    if (settingsData != null) {
      emit(BuildingInfoLoaded(settingsData!));
      await _checkSessionAfterSettingsLoad();
      return;
    }

    emit(BuildingInfoLoading());

    int retryCount = 0;
    const maxRetries = 2;

    while (retryCount <= maxRetries) {
      try {
        final response = await _service.fetchSettings().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception("انتهت مهلة الاتصال. يرجى المحاولة لاحقاً");
          },
        );
        settingsData = response.data;
        emit(BuildingInfoLoaded(settingsData!));
        await _checkSessionAfterSettingsLoad();
        return;
      } catch (e) {
        retryCount++;
        print('Settings fetch attempt $retryCount failed: $e');

        if (retryCount > maxRetries) {
          print('All settings fetch attempts failed, continuing without settings');
          emit(BuildingInfoInitial());
          return;
        }

        await Future.delayed(Duration(seconds: retryCount * 2));
      }
    }
  }

  Map<String, dynamic> buildAddProjectRequest(
      int selectedSubCategoryId,
      String? otherDiseaseName,
      String? otherVaccinationName,
      String? projectName,
      ) {
    final conversionRate = _calculateConversionRate();
    return {
      "category_id": 1,
      "sub_category_id": selectedSubCategoryId,
      "name": projectName,
      "distribution_channel_id": selectedDistributionChannelId,
      "chick_source": chickSourceCtrl.text.trim(),
      "number_of_chicks": chicksNumberCtrl.text.trim(),
      "start_date": startDateCtrl.text.trim(),
      "expected_end_date": endDateCtrl.text.trim(),
      "feed_source": feedSourceCtrl.text.trim(),
      "feed_quantity": feedQuantityCtrl.text.trim(),
      "conversion_rate": conversionRate != null
          ? (conversionRate % 1 == 0 ? conversionRate.toInt() : double.parse(conversionRate.toStringAsFixed(2)))
          : null,
      "dead_birds": deadBirdsCtrl.text.trim(),
      "disease_type_id": selectedDiseaseTypeId,
      "vaccination_program_id": selectedVaccinationProgramId,
      "disease_type": otherDiseaseCtrl.text.trim().isEmpty ? null : otherDiseaseName,
      "vaccination_program": otherVaccinationCtrl.text.trim().isEmpty ? null : otherVaccinationName,
      "quantity_sold_meat": meatQuantityCtrl.text.trim(),
    };
  }

  Map<String, dynamic> buildEditProjectRequest(
      int selectedSubCategoryId,
      String? otherDiseaseName,
      String? otherVaccinationName,
      String? projectName,
      ) {
    final conversionRate = _calculateConversionRate();

    return {
      "category_id": 1,
      "sub_category_id": selectedSubCategoryId,
      "name": projectName,
      "distribution_channel_id": selectedDistributionChannelId,
      "chick_source": chickSourceCtrl.text.trim(),
      "number_of_chicks": chicksNumberCtrl.text.trim(),
      "start_date": startDateCtrl.text.trim(),
      "expected_end_date": endDateCtrl.text.trim(),
      "feed_source": feedSourceCtrl.text.trim(),
      "feed_quantity": feedQuantityCtrl.text.trim(),
      "conversion_rate": conversionRate != null
          ? (conversionRate % 1 == 0 ? conversionRate.toInt() : double.parse(conversionRate.toStringAsFixed(2)))
          : null,
      "dead_birds": deadBirdsCtrl.text.trim(),
      "disease_type_id": selectedDiseaseTypeId,
      "vaccination_program_id": selectedVaccinationProgramId,
      "disease_type": otherDiseaseCtrl.text.trim().isEmpty ? null : otherDiseaseName,
      "vaccination_program": otherVaccinationCtrl.text.trim().isEmpty ? null : otherVaccinationName,
      "quantity_sold_meat": meatQuantityCtrl.text.trim(),
      "establishment_date": foundationDateController.text.trim(),
    };
  }

  void setBuildingType(int? id) {
    buildingTypeId = id;
    if (settingsData != null) emit(BuildingInfoLoaded(settingsData!));
  }

  void setTechnicalCondition(int? id) {
    technicalConditionId = id;
    if (settingsData != null) emit(BuildingInfoLoaded(settingsData!));
  }

  void setHeatingSystem(int? id) {
    heatingSystemId = id;
    if (settingsData != null) emit(BuildingInfoLoaded(settingsData!));
  }

  void setWaterSource(int? id) {
    waterSourceId = id;
    if (settingsData != null) emit(BuildingInfoLoaded(settingsData!));
  }

  void setPowerSource(int? id) {
    powerSourceId = id;
    if (settingsData != null) emit(BuildingInfoLoaded(settingsData!));
  }

  Map<String, dynamic> getSelectedBuildingInfo() {
    return {
      "foundationDate": foundationDateController.text,
      "licenseNumber": licenseNumberController.text,
      "licenseDate": licenseDateController.text,
      "supervisingDoctor": supervisingDoctorController.text,
      "area": areaController.text,
      "floorsCount": floorsCountController.text,
      "building_type_id": buildingTypeId,
      "technical_condition_id": technicalConditionId,
      "heating_system_id": heatingSystemId,
      "water_source_id": waterSourceId,
      "power_source_id": powerSourceId,
    };
  }

  // ✅ Updated: Accept both area name and ID
  void setArea(String areaName, int areaId) {
    selectedAreaName = areaName;
    selectedAreaId = areaId;
    print("Area set in cubit: $areaName (ID: $areaId)");
    emit(ProjectAreaSelected(areaName));
  }
  // Set city and reset area selection
  void setCity(int cityId) {
    selectedCityId = cityId;
    selectedAreaName = null;
    selectedAreaId = null; // ✅ Reset area ID too
    emit(ProjectCitySelected(cityId));
  }

  // Get areas for currently selected city
  List<Area> getAreasForSelectedCity() {
    if (selectedCityId == null || settingsData == null) {
      return [];
    }
    return settingsData!.getAreasForCity(selectedCityId!);
  }

  void submit() {
    if (!formKey.currentState!.validate()) {
      emit(BuildingInfoValidationError("الرجاء تعبئة جميع الحقول الإلزامية"));
      return;
    }

    if (buildingTypeId == null) {
      emit(BuildingInfoValidationError("الرجاء اختيار نوع المبني"));
      return;
    }

    final foundationDate = foundationDateController.text.trim().isEmpty
        ? null
        : foundationDateController.text.trim();

    final licenseNumber = licenseNumberController.text.trim();
    final licenseDate = licenseDateController.text.trim();
    final supervisingDoctor = supervisingDoctorController.text.trim();

    final area = areaController.text.trim().isEmpty ? null : areaController.text.trim();

    final floorsCount = floorsCountController.text.trim().isEmpty ? null : floorsCountController.text.trim();

    print({
      "foundationDate": foundationDate,
      "licenseNumber": licenseNumber,
      "licenseDate": licenseDate,
      "supervisingDoctor": supervisingDoctor,
      "area": area,
      "floorsCount": floorsCount,
      "buildingTypeId": buildingTypeId,
      "technicalConditionId": technicalConditionId,
      "heatingSystemId": heatingSystemId,
      "waterSourceId": waterSourceId,
      "powerSourceId": powerSourceId,
    });

    emit(BuildingInfoSuccess());
  }

  void clearAllData() {
    foundationDateController.clear();
    licenseNumberController.clear();
    licenseDateController.clear();
    chicksNumberCtrl.clear();
    startDateCtrl.clear();
    endDateCtrl.clear();
    areaController.clear();
    chickSourceCtrl.clear();
    feedSourceCtrl.clear();
    feedQuantityCtrl.clear();
    conversionRateCtrl.clear();
    deadBirdsCtrl.clear();
    meatQuantityCtrl.clear();

    selectedCategoryId = null;
    selectedDistributionChannelId = null;
    selectedDiseaseTypeId = null;
    selectedVaccinationProgramId = null;
    selectedAreaId = null;
    selectedCityId = null;
  }

  @override
  Future<void> close() {
    foundationDateController.dispose();
    licenseNumberController.dispose();
    licenseDateController.dispose();
    supervisingDoctorController.dispose();
    areaController.dispose();
    floorsCountController.dispose();
    projectNameCtrl.dispose();
    chickSourceCtrl.dispose();
    chicksNumberCtrl.dispose();
    startDateCtrl.dispose();
    endDateCtrl.dispose();
    feedSourceCtrl.dispose();
    feedQuantityCtrl.dispose();
    conversionRateCtrl.dispose();
    deadBirdsCtrl.dispose();
    meatQuantityCtrl.dispose();
    areaNameController.dispose();
    meatQuantityCtrl.removeListener(_calculateConversionRate);
    feedQuantityCtrl.removeListener(_calculateConversionRate);
    return super.close();
  }
}