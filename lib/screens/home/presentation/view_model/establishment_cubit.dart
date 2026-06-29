import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/helper/cache_helper.dart';
import '../../data/establishment_model.dart';
import 'establishment_repo.dart';
import 'establishment_state.dart';

class EstablishmentCubit extends Cubit<EstablishmentState> {
  final EstablishmentRepository _repository;

  EstablishmentCubit(this._repository) : super(EstablishmentInitial());

  Future<void> getEstablishments() async {
    emit(EstablishmentLoading());
    try {
      final establishments = await _repository.getEstablishments();
      emit(EstablishmentLoaded(establishments));
    } catch (e) {
      emit(EstablishmentError(e.toString()));
    }
  }

  Future<void> assignEstablishment(int id, String name) async {
    emit(EstablishmentAssigning());
    try {
      final response = await _repository.assignEstablishment(id);

      // ✅ Save all user data to cache from the response
      await _saveUserDataFromResponse(response.data!, name);
      print("USER DATA ASSIGNED IS ${response.data}");

      emit(EstablishmentAssignSuccess(response.message));
    } catch (e) {
      emit(EstablishmentAssignError(e.toString()));
    }
  }
  Future<void> _saveUserDataFromResponse(
      EstablishmentUserData userData,
      String establishmentName,
      ) async {
    print("USER DATA: area=${userData.area}, areaId=${userData.areaId}, userArea=${userData.userArea}");

    // 🏢 Save establishment info
    await CacheHelper.saveData('selected_establishment_name', establishmentName);
    await CacheHelper.saveData('selected_establishment_id', userData.id);

    // 🔑 Token
    await CacheHelper.saveData('token', userData.accessToken);

    // 👤 Common user data
    await CacheHelper.saveData('username', userData.name ?? '');
    await CacheHelper.saveData('user_phone', userData.phone ?? '');
    await CacheHelper.saveData('user_email', userData.email ?? '');
    await CacheHelper.saveData('latitude', userData.latitude ?? '');
    await CacheHelper.saveData('longitude', userData.longitude ?? '');

    // 🏙️ Location data
    await CacheHelper.saveData('city_id', int.tryParse(userData.cityId ?? '0') ?? 0);
    await CacheHelper.saveData('area', userData.area ?? ''); // ✅ اسم المنطقة
    await CacheHelper.saveData('area_id', userData.areaId ?? 0); // ✅ رقم المنطقة
    await CacheHelper.saveData('user_area', userData.userArea ?? ''); // ✅ المساحة بالمتر

    // 🏭 Establishment type
    final establishmentTypeId = int.tryParse(userData.establishmentTypeId ?? '0') ?? 0;
    await CacheHelper.saveData('establishment_type_id', establishmentTypeId);

    // 🧱 Type-specific caching
    if (establishmentTypeId == 1) {
      // 🐔 المدجنة
      await CacheHelper.saveData('user_name', userData.name ?? '');
      await CacheHelper.saveData('tenant_name', userData.tenantName ?? '');
      await CacheHelper.saveData('building_type_id', userData.buildingTypeId ?? 0);
      await CacheHelper.saveData('technical_condition_id', userData.technicalConditionId ?? 0);
      await CacheHelper.saveData('heating_system_id', userData.heatingSystemId ?? 0);
      await CacheHelper.saveData('water_source_id', userData.waterSourceId ?? 0);
      await CacheHelper.saveData('power_source_id', userData.powerSourceId ?? 0);
      await CacheHelper.saveData('supervising_doctor', userData.supervisingDoctor ?? '');
      await CacheHelper.saveData('license_number', userData.licenseNumber ?? '');
      await CacheHelper.saveData('license_date', userData.licenseDate ?? '');
      await CacheHelper.saveData('number_floors', userData.numberFloors ?? '');
      await CacheHelper.saveData('establishment_date', ''); // لو مش موجود بالريسبونس
    }
    else if (establishmentTypeId == 2) {
      // 🐣 المفقس
      await CacheHelper.saveData('establishment_name', userData.establishmentName ?? establishmentName);
      await CacheHelper.saveData('other_info', userData.other ?? '');
      await CacheHelper.saveData('operational_status', userData.isActive ? 'يعمل' : 'لا يعمل');
      await CacheHelper.saveData('machines_count', userData.machinesCount?.toString() ?? '');
      await CacheHelper.saveData('machine_type', userData.machineType ?? '');
    }
    else if (establishmentTypeId == 3) {
      // 🔪 المسلخ
      await CacheHelper.saveData('establishment_name', userData.establishmentName ?? establishmentName);
      await CacheHelper.saveData('other_info', userData.other ?? '');
      await CacheHelper.saveData('cages_count', userData.cagesCount?.toString() ?? '');
    }
    else if (establishmentTypeId == 4) {
      // 🌾 معمل العلف
      await CacheHelper.saveData('establishment_name', userData.establishmentName ?? establishmentName);
      await CacheHelper.saveData('other_info', userData.other ?? '');
      await CacheHelper.saveData('egg_feed_production', userData.feedEggAvg?.toString() ?? '');
      await CacheHelper.saveData('broiler_feed_production', userData.feedBroilerAvg?.toString() ?? '');
    }
    else if (establishmentTypeId == 5) {
      // 📦 معمل كرتون البيض
      await CacheHelper.saveData('establishment_name', userData.establishmentName ?? establishmentName);
      await CacheHelper.saveData('other_info', userData.other ?? '');
      await CacheHelper.saveData('daily_bundles', userData.cartonBundleAvg?.toString() ?? '');
    }
  }


  // ✅ Save all user data from assignment response to cache
  // Future<void> _saveUserDataFromResponse(
  //     EstablishmentUserData userData,
  //     String establishmentName,
  //     ) async {
  //   print("USER DATA ${userData.userArea}${userData.area}${userData.areaId}");
  //   // Save establishment info
  //   await CacheHelper.saveData('selected_establishment_name', establishmentName);
  //   await CacheHelper.saveData('selected_establishment_id', userData.id);
  //
  //   // Save token
  //   await CacheHelper.saveData('token', userData.accessToken);
  //
  //   // Save common data
  //   await CacheHelper.saveData('username', userData.name);
  //   await CacheHelper.saveData('user_phone', userData.phone);
  //   await CacheHelper.saveData('user_email', userData.email ?? '');
  //   await CacheHelper.saveData('latitude', userData.latitude);
  //   await CacheHelper.saveData('longitude', userData.longitude);
  //   await CacheHelper.saveData('city_id', int.parse(userData.cityId));
  //   await CacheHelper.saveData('area', userData.area);
  //   await CacheHelper.saveData('area_id', userData.areaId);
  //   await CacheHelper.saveData(
  //     'establishment_type_id',
  //     int.parse(userData.establishmentTypeId),
  //   );
  //
  //   // Save based on establishment type
  //   final establishmentTypeId = int.parse(userData.establishmentTypeId);
  //
  //   if (establishmentTypeId == 1) {
  //     // المدجنة
  //     await CacheHelper.saveData('username', userData.name ?? '');
  //     await CacheHelper.saveData('user_name', userData.name ?? '');
  //     await CacheHelper.saveData('tenant_name', userData.tenantName ?? '');
  //     await CacheHelper.saveData('building_type_id', userData.buildingTypeId);
  //     await CacheHelper.saveData('technical_condition_id', userData.technicalConditionId);
  //     await CacheHelper.saveData('heating_system_id', userData.heatingSystemId);
  //     await CacheHelper.saveData('water_source_id', userData.waterSourceId);
  //     await CacheHelper.saveData('power_source_id', userData.powerSourceId);
  //     await CacheHelper.saveData('supervising_doctor', userData.supervisingDoctor ?? '');
  //     await CacheHelper.saveData('license_number', userData.licenseNumber ?? '');
  //     await CacheHelper.saveData('license_date', userData.licenseDate ?? '');
  //     await CacheHelper.saveData('user_area', userData.userArea ?? '');
  //     await CacheHelper.saveData('number_floors', userData.numberFloors ?? '');
  //     await CacheHelper.saveData('establishment_date', ''); // Not in response
  //   } else {
  //     // Other types (المفقس، مسلخ، معمل علف، معمل كرتون البيض)
  //     await CacheHelper.saveData('establishment_name', userData.establishmentName ?? establishmentName);
  //     await CacheHelper.saveData('username', userData.name ?? '');
  //     await CacheHelper.saveData('other_info', userData.other ?? '');
  //
  //     if (establishmentTypeId == 2) {
  //       // المفقس
  //       await CacheHelper.saveData(
  //         'operational_status',
  //         userData.isActive ? 'يعمل' : 'لا يعمل',
  //       );
  //       await CacheHelper.saveData('machines_count', userData.machinesCount.toString());
  //       await CacheHelper.saveData('machine_type', userData.machineType ?? '');
  //     } else if (establishmentTypeId == 3) {
  //       // مسلخ
  //       await CacheHelper.saveData('cages_count', userData.cagesCount.toString());
  //     } else if (establishmentTypeId == 4) {
  //       // معمل علف
  //       await CacheHelper.saveData('egg_feed_production', userData.feedEggAvg.toString());
  //       await CacheHelper.saveData('broiler_feed_production', userData.feedBroilerAvg.toString());
  //     } else if (establishmentTypeId == 5) {
  //       // معمل كرتون البيض
  //       await CacheHelper.saveData('daily_bundles', userData.cartonBundleAvg.toString());
  //     }
  //   }
  // }

  void resetToLoaded(List<dynamic> establishments) {
    if (state is EstablishmentLoaded) {
      emit(EstablishmentLoaded((state as EstablishmentLoaded).establishments));
    }
  }
}