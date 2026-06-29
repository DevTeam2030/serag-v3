import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mine/core/helper/cache_helper.dart';
import '../../../../../constants/app_colors.dart';
import '../../../../../constants/app_text_styles.dart';
import '../../../../../widgets/custom_button.dart';
import '../../../data/establishment_model.dart';
import '../../view_model/establishment_cubit.dart';
import '../../view_model/establishment_state.dart';


class EstablishmentDialog extends StatefulWidget {
  const EstablishmentDialog({super.key});

  @override
  State<EstablishmentDialog> createState() => _EstablishmentDialogState();
}

class _EstablishmentDialogState extends State<EstablishmentDialog> {
  int? _selectedEstablishmentId;
  String? _selectedEstablishmentName;
  List<EstablishmentModel>? _cachedEstablishments;

  @override
  void initState() {
    super.initState();
    // Load currently selected establishment from cache
    _loadSelectedEstablishment();
    // Fetch establishments when dialog opens
    context.read<EstablishmentCubit>().getEstablishments();
  }

  void _loadSelectedEstablishment() {
    // Get the currently selected establishment from cache
    final cachedId = CacheHelper.getData('selected_establishment_id');
    final cachedName = CacheHelper.getData('selected_establishment_name');

    if (cachedId != null) {
      setState(() {
        _selectedEstablishmentId = cachedId is int ? cachedId : int.tryParse(cachedId.toString());
        _selectedEstablishmentName = cachedName?.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Container(
          padding: EdgeInsets.all(20.w),
          constraints: BoxConstraints(
            maxHeight: 500.h,
            maxWidth: 350.w,
          ),
          child: BlocConsumer<EstablishmentCubit, EstablishmentState>(
            listener: (context, state) {
              if (state is EstablishmentAssignSuccess) {
                // Save selected establishment name to cache
                if (_selectedEstablishmentName != null) {
                  CacheHelper.saveData(
                    'selected_establishment_name',
                    _selectedEstablishmentName!,
                  );
                  CacheHelper.saveData(
                    'selected_establishment_id',
                    _selectedEstablishmentId!,
                  );
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.of(context).pop(true); // Return true on success
              } else if (state is EstablishmentAssignError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
                print(state.message);
              }
            },
            builder: (context, state) {
              // Cache establishments when loaded
              if (state is EstablishmentLoaded) {
                _cachedEstablishments = state.establishments;
              }

              // Show loading only for initial fetch
              if (state is EstablishmentLoading) {
                return Center(
                  child: SpinKitWave(
                    color: AppColors.green,
                    size: 30.0,
                  ),
                );
              }

              if (state is EstablishmentError) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48.sp,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'حدث خطأ',
                      style: AppTextStyles.boldGrey17.copyWith(
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      state.message,
                      style: AppTextStyles.boldGrey17.copyWith(
                        fontSize: 14.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20.h),
                    CustomButton(
                      title: 'إعادة المحاولة',
                      onPressed: () {
                        context.read<EstablishmentCubit>().getEstablishments();
                      },
                    ),
                  ],
                );
              }

              // Use cached establishments for both Loaded and Assigning states
              final establishments = _cachedEstablishments ?? [];

              if (establishments.isEmpty) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 48.sp,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'لا توجد مدجنات متاحة',
                      style: AppTextStyles.boldGrey17,
                    ),
                    SizedBox(height: 20.h),
                    CustomButton(
                      title: 'إغلاق',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, size: 15),
                        padding: EdgeInsets.zero,
                      ),
                      Spacer(),
                      Text(
                        'اختر المدجنة',
                        style: AppTextStyles.boldBlack18.copyWith(fontSize: 16.sp),
                      ),
                      Spacer(flex: 2)
                    ],
                  ),

                  SizedBox(height: 10.h),

                  // Establishments List
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: establishments.length,
                      itemBuilder: (context, index) {
                        final establishment = establishments[index];
                        final isSelected = _selectedEstablishmentId == establishment.id;

                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 5.h),
                          decoration: BoxDecoration(
                            color: AppColors.lightGrey.withOpacity(.1),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.green
                                  : AppColors.lightGrey.withOpacity(.5),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: RadioListTile<int>(
                            value: establishment.id,
                            groupValue: _selectedEstablishmentId,
                            onChanged: (value) {
                              setState(() {
                                _selectedEstablishmentId = value;
                                _selectedEstablishmentName = establishment.name;
                              });
                            },
                            //radioSide: BorderSide(color: AppColors.lightGrey),
                            title: Text(
                              establishment.name,
                              style: AppTextStyles.regularGrey15.copyWith(
                                fontSize: 18.sp,
                                color: isSelected ? AppColors.green : null,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            activeColor: AppColors.green,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Submit Button
                  CustomButton(
                    isLoading: state is EstablishmentAssigning,
                    title: 'اختر',
                    onPressed:  () {
                      _selectedEstablishmentId == null
                          ? null
                          :
                      context.read<EstablishmentCubit>().assignEstablishment(
                        _selectedEstablishmentId!,
                        _selectedEstablishmentName!,
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}