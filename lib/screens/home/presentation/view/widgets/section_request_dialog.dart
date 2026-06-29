// widgets/section_request_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../../constants/app_colors.dart';
import '../../../../../constants/app_text_styles.dart';
import '../../../../../widgets/custom_button.dart';
import '../../../../../widgets/custom_textfield.dart';
import '../../../../auth/register/presentation/view/add_location_screen.dart';
import '../../view_model/section_request_cubit.dart';
import '../../view_model/section_request_state.dart';

class SectionRequestDialog extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const SectionRequestDialog({
    Key? key,
    required this.categoryId,
    required this.categoryName,
  }) : super(key: key);

  @override
  State<SectionRequestDialog> createState() => _SectionRequestDialogState();
}

class _SectionRequestDialogState extends State<SectionRequestDialog> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  final LatLng _initialPosition = const LatLng(33.5138, 36.2765); // Damascus
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<bool> _isDeterminingLocation = ValueNotifier<bool>(false);
  bool _isSameLocation = false;

  String _workingStatus = "يعمل"; // Default value
  late final SectionRequestCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<SectionRequestCubit>();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition();
        setState(() {
          _selectedLocation = LatLng(position.latitude, position.longitude);
        });
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_selectedLocation!, 15),
        );
        _cubit.setLocation(_selectedLocation!);
      }
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _selectedLocation = position;
      _isSameLocation = false;
    });
    _cubit.setLocation(position);
  }

  Future<void> _onSelectCurrentLocation() async {
    _isDeterminingLocation.value = true;

    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _isSameLocation = true;
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_selectedLocation!, 15),
      );

      _cubit.setLocation(_selectedLocation!);
    } catch (e) {
      print("Error getting location: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل تحديد الموقع الحالي'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      _isDeterminingLocation.value = false;
    }
  }

  Future<void> _goToPlace(String address) async {
    // Implement geocoding here if needed
    // For now, just a placeholder
    print("Searching for: $address");
  }

  void _openFullMap() {
    // Implement full map screen navigation if needed
    print("Open full map");
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SectionRequestCubit, SectionRequestState>(
      listener: (context, state) {
        if (state is SectionRequestSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else if (state is SectionRequestError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is SectionRequestLoading;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Dialog(
            backgroundColor: Colors.white,
            insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 40.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: EdgeInsets.all(20.w),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Row(
                      children: [
                        Spacer(),
                        Text(
                          'من فضلك قم بملء النموذج التالي',
                          style: AppTextStyles.boldBlack12.copyWith(fontSize: 14),
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(
                            Icons.close,
                            color: AppColors.black,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),

                    // Name Field
                    CustomTextField(
                      label: 'الاسم',
                      hint: 'أدخل الاسم',
                      controller: _cubit.nameController,
                      validator: (val) => val!.isEmpty ? "أدخل الاسم" : null,
                    ),

                    SizedBox(height: 8.h),

                    // Working Status Radio Buttons
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 5.h),
                            decoration: BoxDecoration(
                              color: AppColors.lightGrey.withOpacity(.1),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: AppColors.lightGrey),
                            ),
                            child: RadioListTile<String>(
                              title: Text(
                                'يعمل',
                                style: AppTextStyles.regularGrey15,
                              ),
                              value: 'يعمل',
                              groupValue: _workingStatus,
                              activeColor: AppColors.green,
                              contentPadding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                              onChanged: (value) {
                                setState(() {
                                  _workingStatus = value!;
                                });
                                _cubit.setWorkingStatus(value);
                              },
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 5.h),
                            decoration: BoxDecoration(
                              color: AppColors.lightGrey.withOpacity(.1),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: AppColors.lightGrey),
                            ),
                            child: RadioListTile<String>(
                              title: Text(
                                'لا يعمل',
                                style: AppTextStyles.regularGrey15,
                              ),
                              value: 'لا يعمل',
                              groupValue: _workingStatus,
                              activeColor: AppColors.green,
                              contentPadding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                              onChanged: (value) {
                                setState(() {
                                  _workingStatus = value!;
                                });
                                _cubit.setWorkingStatus(value);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    // Map Section
                    Text(
                      'الموقع الجغرافي',
                      style: AppTextStyles.boldGrey17.copyWith(
                        color: Colors.black,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),

                    // Map Widget with Stack
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Container(
                          width: double.infinity,
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
                                    CameraUpdate.newLatLngZoom(_selectedLocation!, 15),
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
                            ),
                          ),
                        ),
                        // Search bar and fullscreen button
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
                                      prefixIcon: Icon(Icons.search, color: Colors.grey),
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
                                  child: Icon(
                                    Icons.fullscreen_exit,
                                    color: AppColors.green,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Select current location button
                        Positioned(
                          bottom: 24,
                          child: ValueListenableBuilder<bool>(
                            valueListenable: _isDeterminingLocation,
                            builder: (context, isLocationLoading, child) {
                              return GlassySelectLocation(
                                onTap: isLocationLoading ? null : _onSelectCurrentLocation,
                                isLoading: isLocationLoading,
                                isSameLocation: _isSameLocation,
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    // Submit Button
                    CustomButton(
                      title: isLoading ? 'جاري الإرسال...' : 'إرسال الطلب',
                      withShadow: false,
                      onPressed: () {
                        if (_cubit.nameController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('الرجاء إدخال الاسم'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        if (_selectedLocation == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('الرجاء تحديد الموقع على الخريطة'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        _cubit.setWorkingStatus(_workingStatus);
                        _cubit.submitRequest(widget.categoryId);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    _isDeterminingLocation.dispose();
    super.dispose();
  }
}