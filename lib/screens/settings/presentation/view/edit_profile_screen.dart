import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:toastification/toastification.dart';
import 'package:mine/constants/app_colors.dart';
import 'package:mine/constants/app_text_styles.dart';
import 'package:mine/screens/auth/register/presentation/view_model/building_info_cubit.dart';
import 'package:mine/screens/auth/register/presentation/view_model/building_info_states.dart';
import 'package:mine/widgets/custom_button.dart';
import 'package:mine/widgets/custom_dropdown.dart';
import 'package:mine/widgets/custom_textfield.dart';
import 'package:mine/widgets/custom_appbar.dart';
import '../../../../core/helper/cache_helper.dart';
import '../../../../widgets/internet_loss_connection_widget.dart';
import '../../../auth/register/data/settings_model.dart';
import '../../../auth/register/presentation/view/add_location_screen.dart';
import '../../../auth/register/presentation/view/widgets/register_header.dart';
import '../../../auth/register/presentation/view_model/register_cubit.dart';
import '../view_model/update_profile_cubit.dart';

import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:toastification/toastification.dart';
import 'package:mine/constants/app_colors.dart';
import 'package:mine/constants/app_text_styles.dart';
import 'package:mine/screens/auth/register/presentation/view_model/building_info_cubit.dart';
import 'package:mine/screens/auth/register/presentation/view_model/building_info_states.dart';
import 'package:mine/widgets/custom_button.dart';
import 'package:mine/widgets/custom_dropdown.dart';
import 'package:mine/widgets/custom_textfield.dart';
import 'package:mine/widgets/custom_appbar.dart';
import '../../../../core/helper/cache_helper.dart';
import '../../../../widgets/internet_loss_connection_widget.dart';
import '../../../auth/register/presentation/view/add_location_screen.dart';
import '../../../auth/register/presentation/view/widgets/register_header.dart';
import '../../../auth/register/presentation/view_model/register_cubit.dart';
import '../view_model/update_profile_cubit.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Get establishment type from cache
  int? establishmentTypeId;

  // Common fields
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  // المدجنة specific
  final nameCtrl = TextEditingController();
  final tenantCtrl = TextEditingController();
  final foundationDateCtrl = TextEditingController();
  final licenseNumberCtrl = TextEditingController();
  final supervisingDoctorCtrl = TextEditingController();
  final areaCtrl = TextEditingController();
  final floorsCountCtrl = TextEditingController();
  final licenseDateCtrl = TextEditingController();

  // Other establishment types
  final establishmentNameCtrl = TextEditingController();

  // المفقس specific
  final machinesCountCtrl = TextEditingController();
  String? machineType;
  String? operationalStatus;

  // مسلخ specific
  final cagesCountCtrl = TextEditingController();

  // معمل علف specific
  final eggFeedProductionCtrl = TextEditingController();
  final broilerFeedProductionCtrl = TextEditingController();

  // معمل كرتون البيض specific
  final dailyBundlesCtrl = TextEditingController();

  // Common for all
  final otherInfoCtrl = TextEditingController();

  // Location & dropdown fields
  final latCtrl = TextEditingController();
  final lngCtrl = TextEditingController();
  final cityTypeCtrl = TextEditingController();
  final areaTypeCtrl = TextEditingController();

  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  LatLng? _userLocation;
  LatLng _initialPosition = const LatLng(33.5138, 36.2765);
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<bool> _isDeterminingLocation = ValueNotifier(false);
  @override
  void initState() {
    super.initState();

    // Get establishment type
    establishmentTypeId = int.parse(CacheHelper.getData('establishment_type_id').toString());

    // Initialize controllers based on establishment type
    _initializeControllers();

    final cubit = context.read<ProjectDataCubit>();
    if (cubit.settingsData == null) {
      cubit.fetchSettings();
    }
    _initializeCubitFromCache(cubit);
    _debugCacheData(); // Add this line

    // Initialize location
    final latitude = CacheHelper.getData('latitude');
    final longitude = CacheHelper.getData('longitude');
    if (latitude != null && longitude != null && latitude.isNotEmpty && longitude.isNotEmpty) {
      try {
        _selectedLocation = LatLng(double.parse(latitude), double.parse(longitude));
        _initialPosition = _selectedLocation!;
        latCtrl.text = latitude;
        lngCtrl.text = longitude;
      } catch (e) {
        print('Error parsing cached coordinates: $e');
      }
    }

    final bool isPermissionDenied = CacheHelper.getData('location_permission_denied') ?? false;
    if (!isPermissionDenied) {
      _determinePosition();
    }
  }
  void _reloadProfileData() {
    // Get establishment type
    establishmentTypeId = int.parse(CacheHelper.getData('establishment_type_id').toString());

    // Reinitialize controllers with new data
    _initializeControllers();

    // Reinitialize cubit from cache
    final cubit = context.read<ProjectDataCubit>();
    _initializeCubitFromCache(cubit);

    // Reload location if available
    final latitude = CacheHelper.getData('latitude');
    final longitude = CacheHelper.getData('longitude');
    if (latitude != null && longitude != null && latitude.isNotEmpty && longitude.isNotEmpty) {
      try {
        _selectedLocation = LatLng(double.parse(latitude), double.parse(longitude));
        _initialPosition = _selectedLocation!;
        latCtrl.text = latitude;
        lngCtrl.text = longitude;

        // Update map if controller is available
        if (_mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(_selectedLocation!, 10),
          );
        }
      } catch (e) {
        print('Error parsing cached coordinates: $e');
      }
    }

    // Trigger rebuild
    setState(() {});
  }
  void _debugCacheData() {
    print("=== Cache Debug ===");
    print("Username: ${CacheHelper.getData('username')}");
    print("User Area: ${CacheHelper.getData('user_area')}");
    print("City ID: ${CacheHelper.getData('city_id')}");
    print("Establishment Type: ${CacheHelper.getData('establishment_type_id')}");
    print("Area Name: ${CacheHelper.getData('area')}");
    print("Area ID: ${CacheHelper.getData('area_id')}");
    print("==================");
  }
  // void _initializeControllers() {
  //   // Common fields
  //   usernameCtrl.text = CacheHelper.getData('username') ?? "";
  //   passwordCtrl.text = CacheHelper.getData('user_password') ?? "";
  //   phoneCtrl.text = CacheHelper.getData('user_phone') ?? "";
  //   emailCtrl.text = CacheHelper.getData('user_email') ?? "";
  //   cityTypeCtrl.text = CacheHelper.getData('city_id')?.toString() ?? "";
  //   areaTypeCtrl.text = CacheHelper.getData('user_area')?.toString() ?? "";
  //
  //   switch (establishmentTypeId) {
  //     case 1: // المدجنة
  //       nameCtrl.text = CacheHelper.getData('user_name') ?? "";
  //       tenantCtrl.text = CacheHelper.getData('tenant_name') ?? "";
  //       foundationDateCtrl.text = CacheHelper.getData('establishment_date') ?? "";
  //       licenseNumberCtrl.text = CacheHelper.getData('license_number') ?? "";
  //       supervisingDoctorCtrl.text = CacheHelper.getData('supervising_doctor') ?? "";
  //       areaCtrl.text = CacheHelper.getData('area') ?? "";
  //       floorsCountCtrl.text = CacheHelper.getData('number_floors') ?? "";
  //       licenseDateCtrl.text = CacheHelper.getData('license_date') ?? "";
  //       break;
  //
  //     case 2: // المفقس
  //       establishmentNameCtrl.text = CacheHelper.getData('establishment_name') ?? "";
  //       machinesCountCtrl.text = CacheHelper.getData('machines_count').toString() ?? "";
  //       machineType = CacheHelper.getData('machine_type');
  //       operationalStatus = CacheHelper.getData('operational_status');
  //       otherInfoCtrl.text = CacheHelper.getData('other_info') ?? "";
  //       break;
  //
  //     case 3: // مسلخ
  //       establishmentNameCtrl.text = CacheHelper.getData('establishment_name') ?? "";
  //       cagesCountCtrl.text = CacheHelper.getData('cages_count').toString() ?? "";
  //       otherInfoCtrl.text = CacheHelper.getData('other_info') ?? "";
  //       break;
  //
  //     case 4: // معمل علف
  //       establishmentNameCtrl.text = CacheHelper.getData('establishment_name') ?? "";
  //       eggFeedProductionCtrl.text = CacheHelper.getData('egg_feed_production') ?? "";
  //       broilerFeedProductionCtrl.text = CacheHelper.getData('broiler_feed_production') ?? "";
  //       otherInfoCtrl.text = CacheHelper.getData('other_info') ?? "";
  //       break;
  //
  //     case 5: // معمل كرتون البيض
  //       establishmentNameCtrl.text = CacheHelper.getData('establishment_name') ?? "";
  //       dailyBundlesCtrl.text = CacheHelper.getData('daily_bundles') ?? "";
  //       otherInfoCtrl.text = CacheHelper.getData('other_info') ?? "";
  //       break;
  //   }
  // }
  void _initializeControllers() {
    // Common fields - MOVED OUTSIDE SWITCH
    usernameCtrl.text = CacheHelper.getData('username') ?? "";
    passwordCtrl.text = CacheHelper.getData('user_password') ?? "";
    phoneCtrl.text = CacheHelper.getData('user_phone') ?? "";
    emailCtrl.text = CacheHelper.getData('user_email') ?? "";
    cityTypeCtrl.text = CacheHelper.getData('city_id')?.toString() ?? "";
    areaTypeCtrl.text = CacheHelper.getData('area')?.toString() ?? ""; // ✅ اسم المنطقة

    switch (establishmentTypeId) {
      case 1: // المدجنة
        nameCtrl.text = CacheHelper.getData('user_name') ?? "";
        tenantCtrl.text = CacheHelper.getData('tenant_name') ?? "";
        foundationDateCtrl.text = CacheHelper.getData('establishment_date') ?? "";
        licenseNumberCtrl.text = CacheHelper.getData('license_number') ?? "";
        supervisingDoctorCtrl.text = CacheHelper.getData('supervising_doctor') ?? "";
        areaCtrl.text = CacheHelper.getData('user_area') ?? ""; // ✅ مساحة المبنى بالمتر
        floorsCountCtrl.text = CacheHelper.getData('number_floors') ?? "";
        licenseDateCtrl.text = CacheHelper.getData('license_date') ?? "";
        break;

      case 2: // المفقس
        establishmentNameCtrl.text = CacheHelper.getData('establishment_name') ?? "";
        machinesCountCtrl.text = CacheHelper.getData('machines_count')?.toString() ?? "";
        machineType = CacheHelper.getData('machine_type');
        operationalStatus = CacheHelper.getData('operational_status');
        otherInfoCtrl.text = CacheHelper.getData('other_info') ?? "";
        break;

      case 3: // مسلخ
        establishmentNameCtrl.text = CacheHelper.getData('establishment_name') ?? "";
        cagesCountCtrl.text = CacheHelper.getData('cages_count')?.toString() ?? "";
        otherInfoCtrl.text = CacheHelper.getData('other_info') ?? "";
        break;

      case 4: // معمل علف
        establishmentNameCtrl.text = CacheHelper.getData('establishment_name') ?? "";
        eggFeedProductionCtrl.text = CacheHelper.getData('egg_feed_production') ?? "";
        broilerFeedProductionCtrl.text = CacheHelper.getData('broiler_feed_production') ?? "";
        otherInfoCtrl.text = CacheHelper.getData('other_info') ?? "";
        break;

      case 5: // معمل كرتون البيض
        establishmentNameCtrl.text = CacheHelper.getData('establishment_name') ?? "";
        dailyBundlesCtrl.text = CacheHelper.getData('daily_bundles') ?? "";
        otherInfoCtrl.text = CacheHelper.getData('other_info') ?? "";
        break;
    }
  }

  void _initializeCubitFromCache(ProjectDataCubit cubit) {
    // Set city first
    final cityId = CacheHelper.getData('city_id');
    final areaId = CacheHelper.getData('area_id')??0;
    if (cityId != null) {
      cubit.setCity(int.parse(cityId.toString()));

      // Set area name after city is set
      final userArea = CacheHelper.getData('area') ?? "";
      if (userArea != null && userArea.toString().isNotEmpty) {
        // Use addPostFrameCallback to ensure city areas are loaded first
        WidgetsBinding.instance.addPostFrameCallback((_) {
          cubit.setArea(userArea.toString(),areaId);
          print("Area set from cache: $userArea"); // Debug print
        });
      }
    }

    if (establishmentTypeId == 1) {
      final buildingTypeId = CacheHelper.getData('building_type_id');
      if (buildingTypeId != null) {
        cubit.setBuildingType(int.parse(buildingTypeId.toString()));
      }

      final technicalConditionId = CacheHelper.getData('technical_condition_id');
      if (technicalConditionId != null) {
        cubit.setTechnicalCondition(int.parse(technicalConditionId.toString()));
      }

      final heatingSystemId = CacheHelper.getData('heating_system_id');
      if (heatingSystemId != null) {
        cubit.setHeatingSystem(int.parse(heatingSystemId.toString()));
      }

      final waterSourceId = CacheHelper.getData('water_source_id');
      if (waterSourceId != null) {
        cubit.setWaterSource(int.parse(waterSourceId.toString()));
      }

      final powerSourceId = CacheHelper.getData('power_source_id');
      if (powerSourceId != null) {
        cubit.setPowerSource(int.parse(powerSourceId.toString()));
      }
    }
  }
  Future<void> _determinePosition() async {
    if (!mounted) return;

    _isDeterminingLocation.value = true;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _isDeterminingLocation.value = false;
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          await CacheHelper.saveData('location_permission_denied', true);
          _isDeterminingLocation.value = false;
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        await CacheHelper.saveData('location_permission_denied', true);
        _isDeterminingLocation.value = false;
        return;
      }

      await CacheHelper.saveData('location_permission_denied', false);

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );
      if (!mounted) return;

      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        _selectedLocation ??= _userLocation;
        _initialPosition = _selectedLocation!;
        latCtrl.text = _userLocation!.latitude.toString();
        lngCtrl.text = _userLocation!.longitude.toString();
      });

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(_selectedLocation!, 10),
        );
      }
    } catch (e) {
      print('Error determining position: $e');
    } finally {
      if (mounted) {
        _isDeterminingLocation.value = false;
      }
    }
  }

  bool get _isSameLocation {
    if (_selectedLocation == null || _userLocation == null) return false;
    return (_selectedLocation!.latitude.toStringAsFixed(5) ==
        _userLocation!.latitude.toStringAsFixed(5) &&
        _selectedLocation!.longitude.toStringAsFixed(5) ==
            _userLocation!.longitude.toStringAsFixed(5));
  }

  void _onSelectCurrentLocation() {
    if (_isSameLocation) {
      toastification.show(
        context: context,
        title: Text('لقد قمت بتحديد الموقع الحالي', style: AppTextStyles.boldWhite12),
        type: ToastificationType.info,
        backgroundColor: AppColors.green,
        autoCloseDuration: const Duration(seconds: 2),
      );
      return;
    }

    if (_userLocation != null) {
      setState(() {
        _selectedLocation = _userLocation;
        latCtrl.text = _userLocation!.latitude.toString();
        lngCtrl.text = _userLocation!.longitude.toString();
      });
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(_userLocation!, 10),
        );
      }
    }
  }

  void _openFullMap() async {
    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            FullMapScreen(initialLocation: _selectedLocation ?? _initialPosition),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedLocation = result;
        latCtrl.text = result.latitude.toString();
        lngCtrl.text = result.longitude.toString();
      });
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(result, 10),
        );
      }
    }
  }

  void _onMapTap(LatLng latLng) {
    setState(() {
      _selectedLocation = latLng;
      latCtrl.text = latLng.latitude.toString();
      lngCtrl.text = latLng.longitude.toString();
    });
  }

  Future<void> _goToPlace(String query) async {
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final latLng = LatLng(locations.first.latitude, locations.first.longitude);
        setState(() {
          _selectedLocation = latLng;
          latCtrl.text = latLng.latitude.toString();
          lngCtrl.text = latLng.longitude.toString();
        });
        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 10));
      }
    } catch (e) {
      print('Error searching location: $e');
    }
  }

  Future<void> pickDate(TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppColors.green,
            colorScheme: const ColorScheme.light(primary: AppColors.green),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked != null) {
      controller.text =
      "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  List<Widget> _buildFieldsBasedOnType(
      ProjectDataCubit projectCubit,
      SettingsData? settingsData,
      ) {
    final cities = settingsData?.cities ?? [];

    switch (establishmentTypeId) {
      case 1: // المدجنة
        return _buildPoultryFarmFields(projectCubit, settingsData, cities);
      case 2: // المفقس
        return _buildHatcheryFields(projectCubit, cities);
      case 3: // مسلخ
        return _buildSlaughterhouseFields(projectCubit, cities);
      case 4: // معمل علف
        return _buildFeedFactoryFields(projectCubit, cities);
      case 5: // معمل كرتون البيض
        return _buildEggCartonFactoryFields(projectCubit, cities);
      default:
        return _buildPoultryFarmFields(projectCubit, settingsData, cities);
    }
  }

  // المدجنة
  List<Widget> _buildPoultryFarmFields(
      ProjectDataCubit projectCubit,
      SettingsData? settingsData,
      List<GeneralItem> cities,
      ) {
    return [
      CustomTextField(
        label: 'اسم المستخدم',
        hint: "اسم المستخدم",
        controller: usernameCtrl,
        validator: (val) => val!.isEmpty ? "أدخل اسم المستخدم" : null,
      ),
      CustomTextField(
        margin: 6.h,
        hint: "اسم المالك",
        controller: nameCtrl,
        label: 'اسم المالك',
        validator: (val) => val!.isEmpty ? "ادخل اسم المالك" : null,
      ),
      CustomTextField(
        margin: 6.h,
        hint: "اسم المستأجر (اختياري)",
        controller: tenantCtrl,
        label: 'اسم المستأجر',
      ),
      _buildCityAndAreaFields(projectCubit, cities),
      CustomTextField(
        margin: 16.h,
        hint: "البريد الإلكتروني (اختياري)",
        controller: emailCtrl,
        label: 'البريد الإلكتروني',
        inputType: TextInputType.emailAddress,
      ),
      CustomTextField(
        margin: 6.h,
        hint: "رقم الهاتف",
        controller: phoneCtrl,
        label: 'رقم الهاتف',
        validator: (val) => val!.length < 8 ? "ادخل رقم الهاتف" : null,
      ),
      CustomTextField(
        margin: 6.h,
        hint: "كلمة المرور (اتركه فارغاً إذا لم ترد تغييرها)",
        controller: passwordCtrl,
        label: 'كلمة المرور',
        obscure: true,
      ),
      CustomTextField(
        margin: 6.h,
        hint: "تاريخ التأسيس",
        controller: foundationDateCtrl,
        label: 'تاريخ التأسيس',
        inputType: TextInputType.datetime,
        readOnly: true,
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_month,
              color: AppColors.lightGrey, size: 20),
          onPressed: () => pickDate(foundationDateCtrl),
        ),
      ),
      CustomTextField(
        margin: 6.h,
        hint: "رقم الرخصة",
        controller: licenseNumberCtrl,
        label: 'رقم الرخصة',
        inputType: TextInputType.number,
        validator: (val) => val!.isEmpty ? "أدخل رقم الرخصة" : null,
      ),
      CustomTextField(
        margin: 15.h,
        hint: "تاريخ الرخصة",
        label: 'تاريخ الرخصة',
        controller: licenseDateCtrl,
        inputType: TextInputType.datetime,
        readOnly: true,
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_month,
              color: AppColors.lightGrey, size: 20),
          onPressed: () => pickDate(licenseDateCtrl),
        ),
      ),
      CustomTextField(
        margin: 15.h,
        hint: "الطبيب المشرف",
        controller: supervisingDoctorCtrl,
        label: 'الطبيب المشرف',
        inputType: TextInputType.text,
        validator: (val) => val!.isEmpty ? "أدخل اسم الطبيب المشرف" : null,
      ),
      CustomTextField(
        margin: 6.h,
        hint: "المساحة",
        controller: areaCtrl,
        label: 'المساحة',
        inputType: TextInputType.number,
      ),
      CustomTextField(
        margin: 15.h,
        hint: "عدد الطوابق",
        controller: floorsCountCtrl,
        label: 'عدد الطوابق',
        inputType: TextInputType.number,
      ),
      CustomDropdown(
        margin: 6.h,
        hint: "نوع المبنى",
        label: "نوع المبنى",
        items: settingsData?.buildingTypes.map((e) => e.name).toList() ?? [],
        value: projectCubit.buildingTypeId == null || settingsData == null
            ? null
            : settingsData.buildingTypes
            .firstWhere(
              (e) => e.id == projectCubit.buildingTypeId,
          orElse: () => settingsData.buildingTypes.first,
        )
            .name,
        onChanged: (name) {
          if (settingsData != null) {
            final selected = settingsData.buildingTypes
                .firstWhere((e) => e.name == name);
            projectCubit.setBuildingType(selected.id);
            CacheHelper.saveData('building_type_id', selected.id);
          }
        },
      ),
      CustomDropdown(
        margin: 15.h,
        hint: "الحالة الفنية",
        label: "الحالة الفنية",
        items: settingsData?.technicalConditions.map((e) => e.name).toList() ?? [],
        value: projectCubit.technicalConditionId == null || settingsData == null
            ? null
            : settingsData.technicalConditions
            .firstWhere(
              (e) => e.id == projectCubit.technicalConditionId,
          orElse: () => settingsData.technicalConditions.first,
        )
            .name,
        onChanged: (name) {
          if (settingsData != null) {
            final selected = settingsData.technicalConditions
                .firstWhere((e) => e.name == name);
            projectCubit.setTechnicalCondition(selected.id);
            CacheHelper.saveData('technical_condition_id', selected.id);
          }
        },
      ),
      CustomDropdown(
        margin: 15.h,
        hint: "نظام التدفئة",
        label: "نظام التدفئة",
        items: settingsData?.heatingSystems.map((e) => e.name).toList() ?? [],
        value: projectCubit.heatingSystemId == null || settingsData == null
            ? null
            : settingsData.heatingSystems
            .firstWhere(
              (e) => e.id == projectCubit.heatingSystemId,
          orElse: () => settingsData.heatingSystems.first,
        )
            .name,
        onChanged: (name) {
          if (settingsData != null) {
            final selected = settingsData.heatingSystems
                .firstWhere((e) => e.name == name);
            projectCubit.setHeatingSystem(selected.id);
            CacheHelper.saveData('heating_system_id', selected.id);
          }
        },
      ),
      CustomDropdown(
        margin: 15.h,
        hint: "مصدر المياه",
        label: "مصدر المياه",
        items: settingsData?.waterSources.map((e) => e.name).toList() ?? [],
        value: projectCubit.waterSourceId == null || settingsData == null
            ? null
            : settingsData.waterSources
            .firstWhere(
              (e) => e.id == projectCubit.waterSourceId,
          orElse: () => settingsData.waterSources.first,
        )
            .name,
        onChanged: (name) {
          if (settingsData != null) {
            final selected = settingsData.waterSources
                .firstWhere((e) => e.name == name);
            projectCubit.setWaterSource(selected.id);
            CacheHelper.saveData('water_source_id', selected.id);
          }
        },
      ),
      CustomDropdown(
        margin: 15.h,
        hint: "مصدر الطاقة",
        label: "مصدر الطاقة",
        items: settingsData?.powerSources.map((e) => e.name).toList() ?? [],
        value: projectCubit.powerSourceId == null || settingsData == null
            ? null
            : settingsData.powerSources
            .firstWhere(
              (e) => e.id == projectCubit.powerSourceId,
          orElse: () => settingsData.powerSources.first,
        )
            .name,
        onChanged: (name) {
          if (settingsData != null) {
            final selected = settingsData.powerSources
                .firstWhere((e) => e.name == name);
            projectCubit.setPowerSource(selected.id);
            CacheHelper.saveData('power_source_id', selected.id);
          }
        },
      ),
    ];
  }

  // المفقس
  List<Widget> _buildHatcheryFields(
      ProjectDataCubit projectCubit,
      List<GeneralItem> cities,
      ) {
    return [
      CustomTextField(
        label: 'اسم المفقس',
        hint: "اسم المفقس",
        controller: establishmentNameCtrl,
        validator: (val) => val!.isEmpty ? "أدخل اسم المفقس" : null,
      ),
      CustomTextField(
        label: 'اسم المستخدم',
        margin: 6.h,
        hint: "اسم المستخدم",
        controller: usernameCtrl,
        validator: (val) => val!.isEmpty ? "أدخل اسم المستخدم" : null,
      ),
      CustomTextField(
        label: 'كلمة المرور',
        margin: 6.h,
        hint: "كلمة المرور (اتركه فارغاً إذا لم ترد تغييرها)",
        controller: passwordCtrl,
        obscure: true,
      ),
      CustomTextField(
        label: 'رقم التواصل',
        margin: 6.h,
        hint: "رقم التواصل",
        controller: phoneCtrl,
        inputType: TextInputType.phone,
        validator: (val) => val!.length < 8 ? "أدخل رقم هاتف صحيح" : null,
      ),
      CustomTextField(
        label: 'البريد الإلكتروني (اختياري)',
        margin: 6.h,
        hint: "البريد الإلكتروني",
        controller: emailCtrl,
        inputType: TextInputType.emailAddress,
      ),
      _buildCityAndAreaFields(projectCubit, cities),
      CustomDropdown(
        label: "حالة العمل",
        hint: "يعمل أو لا يعمل",
        margin: 16.h,
        items: const ["يعمل", "لا يعمل"],
        value: operationalStatus,
        onChanged: (val) => setState(() => operationalStatus = val),
      ),
      CustomTextField(
        label: 'عدد المكانات',
        margin: 16.h,
        hint: "عدد المكانات",
        controller: machinesCountCtrl,
        inputType: TextInputType.number,
      ),
      CustomDropdown(
        label: "نوع المكنات",
        hint: "اختر نوع المكنات",
        margin: 0.h,
        items: const ["وطني", "باسرفورم", "فيكتوريا", "باترسايم"],
        value: machineType,
        onChanged: (val) => setState(() => machineType = val),
      ),
      CustomTextField(
        label: 'معلومات أخرى',
        margin: 16.h,
        hint: "معلومات إضافية",
        controller: otherInfoCtrl,
      ),
    ];
  }

  // مسلخ
  List<Widget> _buildSlaughterhouseFields(
      ProjectDataCubit projectCubit,
      List<GeneralItem> cities,
      ) {
    return [
      CustomTextField(
        label: 'اسم المسلخ',
        hint: "اسم المسلخ",
        controller: establishmentNameCtrl,
        validator: (val) => val!.isEmpty ? "أدخل اسم المسلخ" : null,
      ),
      CustomTextField(
        label: 'اسم المستخدم',
        margin: 6.h,
        hint: "اسم المستخدم",
        controller: usernameCtrl,
        validator: (val) => val!.isEmpty ? "أدخل اسم المستخدم" : null,
      ),
      CustomTextField(
        label: 'كلمة المرور',
        margin: 6.h,
        hint: "كلمة المرور (اتركه فارغاً إذا لم ترد تغييرها)",
        controller: passwordCtrl,
        obscure: true,
      ),
      CustomTextField(
        label: 'رقم التواصل',
        margin: 6.h,
        hint: "رقم التواصل",
        controller: phoneCtrl,
        inputType: TextInputType.phone,
        validator: (val) => val!.length < 8 ? "أدخل رقم هاتف صحيح" : null,
      ),
      CustomTextField(
        label: 'البريد الإلكتروني (اختياري)',
        margin: 6.h,
        hint: "البريد الإلكتروني",
        controller: emailCtrl,
        inputType: TextInputType.emailAddress,
      ),
      _buildCityAndAreaFields(projectCubit, cities),
      CustomTextField(
        label: 'عدد الأقفاص',
        margin: 16.h,
        hint: "عدد الأقفاص",
        controller: cagesCountCtrl,
        inputType: TextInputType.number,
      ),
      CustomTextField(
        label: 'معلومات أخرى',
        margin: 6.h,
        hint: "معلومات إضافية",
        controller: otherInfoCtrl,
      ),
    ];
  }

  // معمل علف
  List<Widget> _buildFeedFactoryFields(
      ProjectDataCubit projectCubit,
      List<GeneralItem> cities,
      ) {
    return [
      CustomTextField(
        label: 'اسم المعمل',
        hint: "اسم المعمل",
        controller: establishmentNameCtrl,
        validator: (val) => val!.isEmpty ? "أدخل اسم المعمل" : null,
      ),
      CustomTextField(
        label: 'اسم المستخدم',
        margin: 6.h,
        hint: "اسم المستخدم",
        controller: usernameCtrl,
        validator: (val) => val!.isEmpty ? "أدخل اسم المستخدم" : null,
      ),
      CustomTextField(
        label: 'كلمة المرور',
        margin: 6.h,
        hint: "كلمة المرور (اتركه فارغاً إذا لم ترد تغييرها)",
        controller: passwordCtrl,
        obscure: true,
      ),
      CustomTextField(
        label: 'رقم التواصل',
        margin: 6.h,
        hint: "رقم التواصل",
        controller: phoneCtrl,
        inputType: TextInputType.phone,
        validator: (val) => val!.length < 8 ? "أدخل رقم هاتف صحيح" : null,
      ),
      CustomTextField(
        label: 'البريد الإلكتروني (اختياري)',
        margin: 6.h,
        hint: "البريد الإلكتروني",
        controller: emailCtrl,
        inputType: TextInputType.emailAddress,
      ),
      _buildCityAndAreaFields(projectCubit, cities),
      CustomTextField(
        label: 'متوسط إنتاج علف البيض',
        margin: 16.h,
        hint: "متوسط الإنتاج",
        controller: eggFeedProductionCtrl,
        inputType: TextInputType.number,
      ),
      CustomTextField(
        label: 'متوسط إنتاج علف الفروج',
        margin: 6.h,
        hint: "متوسط الإنتاج",
        controller: broilerFeedProductionCtrl,
        inputType: TextInputType.number,
      ),
      CustomTextField(
        label: 'معلومات أخرى',
        margin: 6.h,
        hint: "معلومات إضافية",
        controller: otherInfoCtrl,
      ),
    ];
  }

  // معمل كرتون البيض
  List<Widget> _buildEggCartonFactoryFields(
      ProjectDataCubit projectCubit,
      List<GeneralItem> cities,
      ) {
    return [
      CustomTextField(
        label: 'اسم المعمل',
        hint: "اسم المعمل",
        controller: establishmentNameCtrl,
        validator: (val) => val!.isEmpty ? "أدخل اسم المعمل" : null,
      ),
      CustomTextField(
        label: 'اسم المستخدم',
        margin: 6.h,
        hint: "اسم المستخدم",
        controller: usernameCtrl,
        validator: (val) => val!.isEmpty ? "أدخل اسم المستخدم" : null,
      ),
      CustomTextField(
        label: 'كلمة المرور',
        margin: 6.h,
        hint: "كلمة المرور (اتركه فارغاً إذا لم ترد تغييرها)",
        controller: passwordCtrl,
        obscure: true,
      ),
      CustomTextField(
        label: 'رقم التواصل',
        margin: 6.h,
        hint: "رقم التواصل",
        controller: phoneCtrl,
        inputType: TextInputType.phone,
        validator: (val) => val!.length < 8 ? "أدخل رقم هاتف صحيح" : null,
      ),
      CustomTextField(
        label: 'البريد الإلكتروني (اختياري)',
        margin: 6.h,
        hint: "البريد الإلكتروني",
        controller: emailCtrl,
        inputType: TextInputType.emailAddress,
      ),
      _buildCityAndAreaFields(projectCubit, cities),
      CustomTextField(
        label: 'متوسط عدد الربطات اليومي',
        margin: 16.h,
        hint: "عدد الربطات",
        controller: dailyBundlesCtrl,
        inputType: TextInputType.number,
      ),
      CustomTextField(
        label: 'معلومات أخرى',
        margin: 6.h,
        hint: "معلومات إضافية",
        controller: otherInfoCtrl,
      ),
    ];
  }

  Widget _buildCityAndAreaFields(ProjectDataCubit projectCubit, List<GeneralItem> cities) {
    return BlocBuilder<ProjectDataCubit, ProjectDataState>(
      builder: (context, state) {
        final areas = projectCubit.getAreasForSelectedCity();

        return Column(
          children: [
            CustomDropdown(
              label: "المحافظة",
              hint: "اختر المحافظة",
              margin: 10.h,
              value: projectCubit.selectedCityId != null
                  ? cities.firstWhere(
                    (city) => city.id == projectCubit.selectedCityId,
                orElse: () => GeneralItem(id: -1, name: ""),
              ).name
                  : null,
              items: cities.map((c) => c.name).toList(),
              onChanged: (val) {
                final city = cities.firstWhere((c) => c.name == val);
                projectCubit.setCity(city.id);
                cityTypeCtrl.text = city.id.toString();
                CacheHelper.saveData('city_id', city.id);
              },
              validator: (val) => val == null || val.isEmpty ? "اختر المحافظة" : null,
            ),
            if (projectCubit.selectedCityId != null)
              CustomDropdown(
                label: "المنطقة",
                hint: areas.isEmpty ? "لا توجد مناطق متاحة" : "اختر المنطقة",
                margin: 15.h,
                value: projectCubit.selectedAreaName,
                items: areas.map((a) => a.name).toList(),
                onChanged: (val) {
                  final selectedArea = areas.firstWhere((a) => a.name == val);

                  projectCubit.setArea(val!,selectedArea.id);
                  areaTypeCtrl.text = val;
                  CacheHelper.saveData('area', val);
                  CacheHelper.saveData('area_id', selectedArea.id); // ✅ أضف ده

                },
                validator: (val) {
                  if (areas.isEmpty) return null;
                  return val == null || val.isEmpty ? "اختر المنطقة" : null;
                },
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final projectCubit = context.read<ProjectDataCubit>();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: InternetConnectionWrapper(
            onReconnect: () {
              projectCubit.fetchSettings();
            },
            child: BlocConsumer<UpdateProfileCubit, UpdateProfileState>(
              listener: (context, state) {
                if (state is UpdateProfileSuccess) {
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   SnackBar(
                  //     content: Text(state.message, style: AppTextStyles.boldWhite16),
                  //     backgroundColor: AppColors.green,
                  //     duration: const Duration(seconds: 2),
                  //   ),
                  // );


                  toastification.show(
                    context: context,
                    type: ToastificationType.success,
                    backgroundColor: AppColors.green,
                    title: Text(state.message, style: AppTextStyles.boldWhite16),
                     autoCloseDuration: const Duration(seconds: 2),
                  );
                } else if (state is UpdateProfileError) {
                  toastification.show(
                    context: context,
                    type: ToastificationType.error,
                    title: Text(state.error, style: AppTextStyles.boldWhite16),
                    primaryColor: Colors.red,
                    backgroundColor: Colors.red,
                    autoCloseDuration: const Duration(seconds: 2),
                  );
                }
              },
              builder: (context, state) {
                return BlocBuilder<ProjectDataCubit, ProjectDataState>(
                  builder: (context, projectState) {
                    if (projectState is BuildingInfoLoading) {
                      return Center(
                        child: SpinKitWave(color: AppColors.green),
                      );
                    }
                    if (projectState is BuildingInfoError) {
                      return Center(child: Text(projectState.message));
                    }

                    final settingsData = projectCubit.settingsData;

                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Form(
                        key: formKey,
                        child: ListView(
                          children: [
                            CustomHeader(title: 'تعديل البيانات الشخصية',showBack: Navigator.canPop(context),),
                            SizedBox(height: 20.h),

                            // Dynamic fields based on establishment type
                            ..._buildFieldsBasedOnType(projectCubit, settingsData),

                            SizedBox(height: 20.h),

                            // Map section
                            Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Container(
                                  width: 354.w,
                                  height: 320.h,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(25),
                                    child: GoogleMap(
                                      initialCameraPosition: CameraPosition(
                                        target: _initialPosition,
                                        zoom: 15,
                                      ),
                                      minMaxZoomPreference: const MinMaxZoomPreference(10, 18),
                                      onMapCreated: (controller) async {
                                        _mapController = controller;
                                        if (_selectedLocation != null) {
                                          final zoom = await controller.getZoomLevel();
                                          final newZoom = zoom < 10 ? 10 : (zoom > 17 ? 17 : zoom);
                                          controller.animateCamera(
                                            CameraUpdate.newLatLngZoom(_selectedLocation!, newZoom.toDouble()),
                                          );
                                        }
                                      },
                                      onTap: _onMapTap,
                                      markers: {
                                        if (_selectedLocation != null)
                                          Marker(
                                            markerId: const MarkerId("selected"),
                                            position: _selectedLocation!,
                                            icon: BitmapDescriptor.defaultMarkerWithHue(
                                              BitmapDescriptor.hueGreen,
                                            ),
                                          ),
                                      },
                                      zoomGesturesEnabled: true,
                                      scrollGesturesEnabled: true,
                                      rotateGesturesEnabled: true,
                                      tiltGesturesEnabled: true,
                                      myLocationButtonEnabled: true,
                                      zoomControlsEnabled: true,
                                      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                                        Factory<PanGestureRecognizer>(() => PanGestureRecognizer()),
                                        Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()),
                                        Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
                                        Factory<VerticalDragGestureRecognizer>(() => VerticalDragGestureRecognizer()),
                                      },
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 12,
                                  left: 20,
                                  right: 20,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 6,
                                              ),
                                            ],
                                          ),
                                          child: TextField(
                                            controller: _searchController,
                                            decoration: const InputDecoration(
                                              hintText: "ابحث عن عنوانك...",
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.all(10),
                                              prefixIcon: Icon(Icons.search,
                                                  color: Colors.grey),
                                            ),
                                            textInputAction: TextInputAction.search,
                                            onSubmitted: (value) {
                                              if (value.isNotEmpty) {
                                                _goToPlace(value);
                                                FocusScope.of(context).unfocus();
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      InkWell(
                                        onTap: _openFullMap,
                                        child: CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Colors.white,
                                          child: Icon(Icons.fullscreen_exit,
                                              color: AppColors.green, size: 24),
                                        ),
                                      ),
                                    ],
                                   ),
                                ),
                                Positioned(
                                  bottom: 24,
                                  child: ValueListenableBuilder<bool>(
                                    valueListenable: _isDeterminingLocation,
                                    builder: (context, isLoading, child) {
                                      return GlassySelectLocation(
                                        onTap: isLoading ? null : _onSelectCurrentLocation,
                                        isLoading: isLoading,
                                        isSameLocation: _isSameLocation,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20.h),
                            CustomButton(
                              isLoading: state is UpdateProfileLoading,
                              title: 'حفظ التغييرات',
                              onPressed: () => _handleSaveProfile(projectCubit),
                            ),
                            SizedBox(height: 40.h),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _handleSaveProfile(ProjectDataCubit projectCubit) {
    // if (!formKey.currentState!.validate() || _selectedLocation == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //         content: Text('يرجى تعبئة جميع الحقول المطلوبة واختيار الموقع')),
    //   );
    //   return;
    // }

    // Save based on establishment type
    switch (establishmentTypeId) {
      case 1: // المدجنة
        context.read<UpdateProfileCubit>().updateProfile(
          context: context,
          establishmentTypeId: establishmentTypeId!,
          username: usernameCtrl.text,
          phone: phoneCtrl.text,
          email: emailCtrl.text,
          password: passwordCtrl.text.isEmpty ? null : passwordCtrl.text,
          latitude: _selectedLocation!.latitude.toString(),
          longitude: _selectedLocation!.longitude.toString(),
          cityId: projectCubit.selectedCityId,
          userArea: areaTypeCtrl.text,
          areaId: projectCubit.selectedAreaId, // ✅ Added area ID

          // المدجنة specific
          name: nameCtrl.text,
          tenantName: tenantCtrl.text,
          buildingTypeId: projectCubit.buildingTypeId,
          technicalConditionId: projectCubit.technicalConditionId,
          heatingSystemId: projectCubit.heatingSystemId,
          waterSourceId: projectCubit.waterSourceId,
          powerSourceId: projectCubit.powerSourceId,
          supervisingDoctor: supervisingDoctorCtrl.text,
          licenseNumber: licenseNumberCtrl.text,
          licenseDate: licenseDateCtrl.text,
          area: areaCtrl.text.isEmpty ? null : areaCtrl.text,
          numberFloors: floorsCountCtrl.text.isEmpty ? null : floorsCountCtrl.text,
          foundationDate: foundationDateCtrl.text,
        );
        break;

      case 2: // المفقس
        context.read<UpdateProfileCubit>().updateProfile(
          context: context,
          establishmentTypeId: establishmentTypeId!,
          username: usernameCtrl.text,
          phone: phoneCtrl.text,
          email: emailCtrl.text,
          password: passwordCtrl.text.isEmpty ? null : passwordCtrl.text,
          latitude: _selectedLocation!.latitude.toString(),
          longitude: _selectedLocation!.longitude.toString(),
          cityId: projectCubit.selectedCityId,
          userArea: areaTypeCtrl.text,
          // المفقس specific
          establishmentName: establishmentNameCtrl.text,
          operationalStatus: operationalStatus,
          machinesCount: machinesCountCtrl.text,
          machineType: machineType,
          otherInfo: otherInfoCtrl.text.isEmpty ? null : otherInfoCtrl.text,
          areaId: projectCubit.selectedAreaId, // ✅ Added area ID

        );
        break;

      case 3: // مسلخ
        context.read<UpdateProfileCubit>().updateProfile(
          context: context,
          establishmentTypeId: establishmentTypeId!,
          username: usernameCtrl.text,
          phone: phoneCtrl.text,
          email: emailCtrl.text,
          password: passwordCtrl.text.isEmpty ? null : passwordCtrl.text,
          latitude: _selectedLocation!.latitude.toString(),
          longitude: _selectedLocation!.longitude.toString(),
          cityId: projectCubit.selectedCityId,
          userArea: areaTypeCtrl.text,
          // مسلخ specific
          establishmentName: establishmentNameCtrl.text,
          cagesCount: cagesCountCtrl.text,
          otherInfo: otherInfoCtrl.text.isEmpty ? null : otherInfoCtrl.text,
          areaId: projectCubit.selectedAreaId, // ✅ Added area ID

        );
        break;

      case 4: // معمل علف
        context.read<UpdateProfileCubit>().updateProfile(
          context: context,
          establishmentTypeId: establishmentTypeId!,
          username: usernameCtrl.text,
          phone: phoneCtrl.text,
          email: emailCtrl.text,
          password: passwordCtrl.text.isEmpty ? null : passwordCtrl.text,
          latitude: _selectedLocation!.latitude.toString(),
          longitude: _selectedLocation!.longitude.toString(),
          cityId: projectCubit.selectedCityId,
          userArea: areaTypeCtrl.text,
          // معمل علف specific
          establishmentName: establishmentNameCtrl.text,
          eggFeedProduction: eggFeedProductionCtrl.text,
          broilerFeedProduction: broilerFeedProductionCtrl.text,
          otherInfo: otherInfoCtrl.text.isEmpty ? null : otherInfoCtrl.text,
          areaId: projectCubit.selectedAreaId, // ✅ Added area ID

        );
        break;

      case 5: // معمل كرتون البيض
        context.read<UpdateProfileCubit>().updateProfile(
          context: context,
          establishmentTypeId: establishmentTypeId!,
          username: usernameCtrl.text,
          phone: phoneCtrl.text,
          email: emailCtrl.text,
          password: passwordCtrl.text.isEmpty ? null : passwordCtrl.text,
          latitude: _selectedLocation!.latitude.toString(),
          longitude: _selectedLocation!.longitude.toString(),
          cityId: projectCubit.selectedCityId,
          userArea: areaTypeCtrl.text,
          // معمل كرتون البيض specific
          establishmentName: establishmentNameCtrl.text,
          dailyBundles: dailyBundlesCtrl.text,
          otherInfo: otherInfoCtrl.text.isEmpty ? null : otherInfoCtrl.text,
          areaId: projectCubit.selectedAreaId, // ✅ Added area ID

        );
        break;

      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('نوع المنشأة غير مدعوم')),
        );
    }
  }
  @override
  void dispose() {
    usernameCtrl.dispose();
    passwordCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    nameCtrl.dispose();
    tenantCtrl.dispose();
    foundationDateCtrl.dispose();
    licenseNumberCtrl.dispose();
    supervisingDoctorCtrl.dispose();
    areaCtrl.dispose();
    floorsCountCtrl.dispose();
    licenseDateCtrl.dispose();
    establishmentNameCtrl.dispose();
    machinesCountCtrl.dispose();
    cagesCountCtrl.dispose();
    eggFeedProductionCtrl.dispose();
    broilerFeedProductionCtrl.dispose();
    dailyBundlesCtrl.dispose();
    otherInfoCtrl.dispose();
    latCtrl.dispose();
    lngCtrl.dispose();
    cityTypeCtrl.dispose();
    areaTypeCtrl.dispose();
    _searchController.dispose();
    _mapController?.dispose();
    _isDeterminingLocation.dispose();
    super.dispose();
  } 
}



class GlassySelectLocation extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isSameLocation;

  const GlassySelectLocation({
    super.key,
    this.onTap,
    this.isLoading = false,
    this.isSameLocation = false,
  });

  @override
  Widget build(BuildContext context) {
    // Check permission status from cache
    final bool isPermissionDenied = CacheHelper.getData('location_permission_denied') ?? false;

    final enabled = !isSameLocation && !isLoading;

    final child = Container(
      width: 227.w,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: enabled
              ? [
            Colors.white.withOpacity(0.5),
            Colors.greenAccent.withOpacity(0.05),
          ]
              : [
            Colors.grey.withOpacity(0.3),
            Colors.grey.withOpacity(0.1),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.35), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.rtl,
        children: [
          isLoading
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2,color: Colors.black,),
          )
              : const Icon(Icons.my_location, size: 20, color: Colors.black),
          const SizedBox(width: 8),
          Text(
           enabled? 'اختر موقعك الحالي' : isSameLocation ? 'أنت في موقعك الحالي' : isPermissionDenied ? 'إذن الموقع مرفوض' : 'جاري تحديد الموقع...',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
              color: enabled ? Colors.black : Colors.grey,
            ),
          ), 
        ],
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: InkWell(
          splashColor: Colors.white24,
          highlightColor: Colors.white10,
          onTap: () async {
            if (isSameLocation) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.red,
                  content: Text(
                    'انت بالفعل في موقعك الحالي',
                    style: AppTextStyles.boldWhite12,
                  ),
                ),
              );
            } else if (isPermissionDenied) {
              // Check current permission status
              final permission = await Geolocator.checkPermission();
              if (permission == LocationPermission.deniedForever) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.red,
                    content: Text(
                      'تم رفض إذن الموقع نهائيًا. يرجى تفعيله من الإعدادات.',
                      style: AppTextStyles.boldWhite12,
                    ),
                    action: SnackBarAction(
                      label: 'فتح الإعدادات',
                      textColor: Colors.white,
                      onPressed: () async {
                        await Geolocator.openAppSettings();
                      },
                    ),
                  ),
                );
              } else {
                // Request permission again
                context.findAncestorStateOfType<_EditProfileScreenState>()!._determinePosition();
              }
            } else {
              onTap?.call();
            }
          },
          child: child,
        ),
      ),
    );
  }
}