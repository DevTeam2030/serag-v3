import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:mine/constants/app_colors.dart';
import 'package:mine/constants/app_text_styles.dart';
import 'package:mine/screens/auth/register/presentation/view/widgets/register_header.dart';
import 'package:mine/widgets/custom_button.dart';
import 'package:toastification/toastification.dart';
import '../../../../../core/helper/cache_helper.dart';
import '../../../otp_screen/presentation/view/otp_screen.dart';
import '../view_model/building_info_cubit.dart';
import '../view_model/register_cubit.dart';
import '../view_model/register_state.dart';

class AddLocationScreen extends StatefulWidget {
  const AddLocationScreen({super.key});

  @override
  State<AddLocationScreen> createState() => _AddLocationScreenState();
}

class _AddLocationScreenState extends State<AddLocationScreen> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  LatLng? _userLocation;
  LatLng _initialPosition = const LatLng(33.5138, 36.2765); // دمشق افتراضي
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<bool> _isDeterminingLocation = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    final registerCubit = context.read<RegisterCubit>();
    if (registerCubit.selectedLocation != null) {
      _selectedLocation = registerCubit.selectedLocation;
      _initialPosition = _selectedLocation!;
    }
    _determinePosition();
  }

  bool get _isSameLocation {
    if (_selectedLocation == null || _userLocation == null) return false;
    return (_selectedLocation!.latitude.toStringAsFixed(5) ==
        _userLocation!.latitude.toStringAsFixed(5) &&
        _selectedLocation!.longitude.toStringAsFixed(5) ==
            _userLocation!.longitude.toStringAsFixed(5));
  }

  Future<void> _determinePosition({bool fromButton = false}) async {
    _isDeterminingLocation.value = true;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى تفعيل خدمات الموقع')),
        );
        _isDeterminingLocation.value = false;
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          await CacheHelper.saveData('location_permission_denied', true);
          if (fromButton) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('الرجاء تفعيل إذن الموقع أولاً')),
            );
          }
          _isDeterminingLocation.value = false;
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        await CacheHelper.saveData('location_permission_denied', true);
        if (fromButton) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'تم رفض إذن الموقع نهائيًا. يرجى تفعيله من الإعدادات')),
          );
        }
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

      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        _selectedLocation ??= _userLocation;
        _initialPosition = _selectedLocation!;
      });

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(_selectedLocation!, 15),
        );
      }
    } catch (e) {
      if (fromButton) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحديد الموقع: $e')),
        );
      }
    } finally {
      _isDeterminingLocation.value = false;
    }
  }

  void _onSelectCurrentLocation() async {
    final denied =
        await CacheHelper.getData('location_permission_denied') ?? false;

    if (denied) {
      await _determinePosition(fromButton: true);
      return;
    }

    if (_isSameLocation) {
      toastification.show(
        context: context,
        title: const Text('لقد قمت بتحديد الموقع الحالي'),
        type: ToastificationType.info,
      );
      return;
    }

    if (_userLocation != null) {
      setState(() {
        _selectedLocation = _userLocation;
      });
      context.read<RegisterCubit>().setSelectedLocation(_userLocation!);
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_userLocation!, 15),
      );
    } else {
      await _determinePosition(fromButton: true);
    }
  }

  void _openFullMap() async {
    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (_) => FullMapScreen(
            initialLocation: _selectedLocation ?? _initialPosition),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedLocation = result;
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(result, 15),
        );
      });
      context.read<RegisterCubit>().setSelectedLocation(result);
    }
  }

  void _onMapTap(LatLng latLng) {
    setState(() {
      _selectedLocation = latLng;
    });
    context.read<RegisterCubit>().setSelectedLocation(latLng);
  }

  void _goToPlace(String query) async {
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final latLng =
        LatLng(locations.first.latitude, locations.first.longitude);
        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15));
        setState(() {
          _selectedLocation = latLng;
        });
        context.read<RegisterCubit>().setSelectedLocation(latLng);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لم يتم العثور على الموقع')),
        );
      }
    } catch (e) {
      print('Error in geocoding: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لم يتم العثور على الموقع')),
      );
    }
  }

  // void _registerNewLocation() {
  //   final registerCubit = context.read<RegisterCubit>();
  //   final buildingInfoCubit = context.read<ProjectDataCubit>();
  //   final establishmentTypeId = buildingInfoCubit.selectedEstablishmentTypeId;
  //
  //   // Check if location is selected
  //   if (_selectedLocation == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('الرجاء اختيار موقعك أولاً')),
  //     );
  //     return;
  //   }
  //
  //   // Common validations for all types
  //   if (registerCubit.phoneController.text.isEmpty ||
  //       registerCubit.passwordController.text.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('الرجاء تعبئة رقم الهاتف وكلمة المرور')),
  //     );
  //     return;
  //   }
  //
  //   // Validate city and area for all types
  //   if (buildingInfoCubit.selectedCityId == null ||
  //       buildingInfoCubit.selectedAreaName == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('الرجاء تحديد المحافظة والمنطقة')),
  //     );
  //     return;
  //   }
  //
  //   // Type-specific validations
  //   if (establishmentTypeId == 1) {
  //     // المدجنة - validate building info
  //     if (registerCubit.ownerNameController.text.isEmpty) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('الرجاء إدخال اسم المالك')),
  //       );
  //       return;
  //     }
  //
  //     if (buildingInfoCubit.licenseDateController.text.isEmpty ||
  //         buildingInfoCubit.licenseNumberController.text.isEmpty ||
  //         buildingInfoCubit.supervisingDoctorController.text.isEmpty) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('الرجاء تعبئة جميع بيانات المنشأة')),
  //       );
  //       return;
  //     }
  //
  //     if (buildingInfoCubit.buildingTypeId == null) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('الرجاء اختيار نوع المبني')),
  //       );
  //       return;
  //     }
  //
  //     // Call signUp for المدجنة with building info
  //     registerCubit.signUp(
  //       context: context,
  //       establishmentTypeId: 1,
  //       buildingTypeId: buildingInfoCubit.buildingTypeId,
  //       technicalConditionId: buildingInfoCubit.technicalConditionId,
  //       heatingSystemId: buildingInfoCubit.heatingSystemId,
  //       waterSourceId: buildingInfoCubit.waterSourceId,
  //       powerSourceId: buildingInfoCubit.powerSourceId,
  //       supervisingDoctor: buildingInfoCubit.supervisingDoctorController.text,
  //       licenseNumber: buildingInfoCubit.licenseNumberController.text,
  //       licenseDate: buildingInfoCubit.licenseDateController.text,
  //       area: buildingInfoCubit.areaController.text,
  //       numberFloors: buildingInfoCubit.floorsCountController.text,
  //       latitude: _selectedLocation!.latitude.toString(),
  //       longitude: _selectedLocation!.longitude.toString(),
  //       establishmentDate: buildingInfoCubit.foundationDateController.text,
  //       cityId: buildingInfoCubit.selectedCityId,
  //       userArea: buildingInfoCubit.selectedAreaName, // ✅ Send area name as string
  //     );
  //   } else {
  //     // Other types (2-5) - validate establishment name
  //     if (registerCubit.establishmentNameController.text.isEmpty) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('الرجاء إدخال اسم المنشأة')),
  //       );
  //       return;
  //     }
  //
  //     if (registerCubit.usernameController.text.isEmpty) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('الرجاء إدخال اسم المستخدم')),
  //       );
  //       return;
  //     }
  //
  //     // Call signUp for other types without building info
  //     registerCubit.signUp(
  //       context: context,
  //       establishmentTypeId: establishmentTypeId!,
  //       latitude: _selectedLocation!.latitude.toString(),
  //       longitude: _selectedLocation!.longitude.toString(),
  //       cityId: buildingInfoCubit.selectedCityId,
  //       userArea: buildingInfoCubit.selectedAreaName, // ✅ Send area name as string
  //     );
  //   }
  // }
// Replace the _registerNewLocation method in AddLocationScreen with this:

  void _registerNewLocation() {
    final registerCubit = context.read<RegisterCubit>();
    final buildingInfoCubit = context.read<ProjectDataCubit>();
    final establishmentTypeId = buildingInfoCubit.selectedEstablishmentTypeId;

    // Check if location is selected
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار موقعك أولاً')),
      );
      return;
    }

    // Common validations for all types
    if (
        registerCubit.passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء تعبئة رقم الهاتف وكلمة المرور')),
      );
      return;
    }

    // ✅ Validate city, area name, AND area ID for all types
    if (buildingInfoCubit.selectedCityId == null ||
        buildingInfoCubit.selectedAreaName == null ||
        buildingInfoCubit.selectedAreaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء تحديد المحافظة والمنطقة')),
      );
      return;
    }

    Map<String, dynamic>? signUpData;
    String? emailOrUsername;

    // Type-specific validations and data preparation
    if (establishmentTypeId == 1) {
      // المدجنة - validate building info
      if (registerCubit.ownerNameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء إدخال اسم المالك')),
        );
        return;
      }

      if (buildingInfoCubit.licenseDateController.text.isEmpty ||
          buildingInfoCubit.licenseNumberController.text.isEmpty ||
          buildingInfoCubit.supervisingDoctorController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء تعبئة جميع بيانات المنشأة')),
        );
        return;
      }

      if (buildingInfoCubit.buildingTypeId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء اختيار نوع المبني')),
        );
        return;
      }

      // ✅ Prepare signup data for المدجنة with area ID
      signUpData = {
        'establishmentTypeId': 1,
        'buildingTypeId': buildingInfoCubit.buildingTypeId,
        'technicalConditionId': buildingInfoCubit.technicalConditionId,
        'heatingSystemId': buildingInfoCubit.heatingSystemId,
        'waterSourceId': buildingInfoCubit.waterSourceId,
        'powerSourceId': buildingInfoCubit.powerSourceId,
        'supervisingDoctor': buildingInfoCubit.supervisingDoctorController.text,
        'licenseNumber': buildingInfoCubit.licenseNumberController.text,
        'licenseDate': buildingInfoCubit.licenseDateController.text,
        'buildingArea': buildingInfoCubit.areaController.text, // ✅ Building area
        'numberFloors': buildingInfoCubit.floorsCountController.text,
        'latitude': _selectedLocation!.latitude.toString(),
        'longitude': _selectedLocation!.longitude.toString(),
        'establishmentDate': buildingInfoCubit.foundationDateController.text,
        'cityId': buildingInfoCubit.selectedCityId,
        'userArea': buildingInfoCubit.userAreaController.text, // ✅ صح - المساحة بالمتر
        'areaId': buildingInfoCubit.selectedAreaId, // ✅ Area ID
      };

      emailOrUsername = registerCubit.ownerNameController.text.trim();
    } else {
      // ✅ Other types (2-5) - validate establishment name
      if (registerCubit.establishmentNameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء إدخال اسم المنشأة')),
        );
        return;
      }

      if (registerCubit.usernameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء إدخال اسم المستخدم')),
        );
        return;
      }

      // ✅ Prepare signup data for other types with area ID
      signUpData = {
        'establishmentTypeId': establishmentTypeId!,
        'latitude': _selectedLocation!.latitude.toString(),
        'longitude': _selectedLocation!.longitude.toString(),
        'cityId': buildingInfoCubit.selectedCityId,
        'userArea': buildingInfoCubit.selectedAreaName, // ✅ Area name
        'areaId': buildingInfoCubit.selectedAreaId, // ✅ Area ID
      };

      emailOrUsername = registerCubit.usernameController.text.trim();
    }

    // Navigate to OTP screen with signup data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<RegisterCubit>(),
          child: OtpScreen(
            email: emailOrUsername,
            signUpData: signUpData,
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                CustomHeader(title: "أضف موقعك"),
                Padding(
                  padding:
                  EdgeInsets.symmetric(horizontal: 16.0, vertical: 36.h),
                  child: Text(
                    'يمكنك البحث عن عنوانك أو الضغط على موقعك الحالي أو تحديد موقعك على الخريطة',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontFamily: 'Cairo',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      width: 354.w,
                      height: 336.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: _selectedLocation ?? _initialPosition,
                            zoom: 14,
                          ),
                          onMapCreated: (controller) {
                            _mapController = controller;
                            if (_selectedLocation != null) {
                              controller.animateCamera(
                                CameraUpdate.newLatLngZoom(
                                    _selectedLocation!, 15),
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
                                    BitmapDescriptor.hueGreen),
                              ),
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
                                  prefixIcon:
                                  Icon(Icons.search, color: Colors.grey),
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
                SizedBox(height: 10.h),
                const Spacer(),
                CustomButton(
                  isLoading: context.watch<RegisterCubit>().state
                  is RegisterLoading,
                  withShadow: false,
                  width: 360.w,
                  title: 'تسجيل جديد',
                  onPressed: _registerNewLocation,
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _isDeterminingLocation.dispose();
    _searchController.dispose();
    _mapController?.dispose();
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
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.black,
            ),
          )
              : const Icon(Icons.my_location, size: 20, color: Colors.black),
          const SizedBox(width: 8),
          Text(
            enabled ? 'اختر موقعك الحالي' : 'انت في موقعك الحالي',
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
        child: enabled
            ? InkWell(
          onTap: onTap,
          splashColor: Colors.white24,
          highlightColor: Colors.white10,
          child: child,
        )
            : InkWell(
          splashColor: Colors.white24,
          highlightColor: Colors.white10,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppColors.red,
                content: Text(
                  'انت بالفعل في موقعك الحالي',
                  style: AppTextStyles.boldWhite12,
                ),
              ),
            );
          },
          child: child,
        ),
      ),
    );
  }
}

class FullMapScreen extends StatefulWidget {
  final LatLng initialLocation;
  const FullMapScreen({super.key, required this.initialLocation});

  @override
  State<FullMapScreen> createState() => _FullMapScreenState();
}

class _FullMapScreenState extends State<FullMapScreen> {
  GoogleMapController? mapController;
  LatLng? selectedLatLng;

  @override
  void initState() {
    super.initState();
    selectedLatLng = widget.initialLocation;
  }

  void _confirmSelection() {
    Navigator.pop(context, selectedLatLng);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          Navigator.pop(context, selectedLatLng);
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: widget.initialLocation,
                zoom: 14,
              ),
              onMapCreated: (controller) => mapController = controller,
              onTap: (latLng) async {
                setState(() {
                  selectedLatLng = latLng;
                });
                context.read<RegisterCubit>().setSelectedLocation(latLng);
                final zoom = await mapController?.getZoomLevel() ?? 14;
                final newZoom = zoom < 10 ? 10 : (zoom > 17 ? 17 : zoom);
                mapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(latLng, newZoom.toDouble()),
                );
              },
              markers: selectedLatLng != null
                  ? {
                Marker(
                  markerId: const MarkerId("selected"),
                  position: selectedLatLng!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen,
                  ),
                ),
              }
                  : {},
              zoomControlsEnabled: true,
              myLocationEnabled: true,
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<PanGestureRecognizer>(() => PanGestureRecognizer()),
                Factory<ScaleGestureRecognizer>(
                        () => ScaleGestureRecognizer()),
                Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
                Factory<VerticalDragGestureRecognizer>(
                        () => VerticalDragGestureRecognizer()),
              },
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: _confirmSelection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "تأكيد الموقع",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }
}