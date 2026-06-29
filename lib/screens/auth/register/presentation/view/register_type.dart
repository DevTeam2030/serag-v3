import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mine/constants/app_colors.dart';
import 'package:mine/constants/app_text_styles.dart';
import 'package:mine/screens/auth/register/presentation/view/widgets/register_header.dart';
import 'package:mine/widgets/back_button.dart';
import 'package:mine/widgets/custom_button.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../view_model/building_info_cubit.dart';
import '../view_model/building_info_states.dart';
import 'register_screen.dart';

class EstablishmentTypeScreen extends StatelessWidget {
  const EstablishmentTypeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: BlocBuilder<ProjectDataCubit, ProjectDataState>(
            builder: (context, state) {
              final cubit = ProjectDataCubit.of(context);
              final establishmentTypes = cubit.settingsData?.establishmentTypes ?? [];

              if (establishmentTypes.isEmpty) {
                return const Center(child: SpinKitWave(
                  color: AppColors.green,
                  size: 50.0,
                ));
              }

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(height: 10.h),
                    BkBtn(),
                    Align(
                      alignment: Alignment.center,
                      child: Text('نوع التسجيل',
                        style: AppTextStyles.boldBlack30.copyWith(fontSize: 25.sp),

                      ),
                    ),
                    SizedBox(height: 20.h),
                    Expanded(
                      child: ListView.builder(
                        itemCount: establishmentTypes.length,
                        itemBuilder: (context, index) {
                          final type = establishmentTypes[index];
                          final isSelected = cubit.selectedEstablishmentTypeId == type.id;
                          print("type id: ${type.id}, selected id: ${cubit.selectedEstablishmentTypeId}");

                          return GestureDetector(
                            onTap: () => cubit.setEstablishmentType(type.id),
                            child: Container(
                              margin: EdgeInsets.only(bottom: 22.h),
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color:const Color(0xFFF7F8F9),
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                ),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.grey[200],
                                          ),
                                          child: Image.asset(
                                           type.id==1?
                                           'assets/madgana.png':
                                           type.id==2?
                                           "assets/maf2as.png":
                                            type.id==3?
                                            "assets/masla5.png":
                                              type.id==4?
                                             "assets/ma3mal.png":
                                            "assets/egg_ma3mal.png",



                                            width: 40.w, height: 40.w,fit:BoxFit.cover ,)),
                                      SizedBox(width: 16.w),
                                      Text(
                                        type.name,
                                        style: AppTextStyles.regularBlack12.copyWith(fontSize: 16.sp)
                                      ),
                                    ],
                                  ),

                                  SizedBox(width: 16.w),
                                  Container(
                                    width: 24.w,
                                    height: 24.w,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected ? AppColors.green : Colors.grey[400]!,
                                      ),
                                      color: isSelected ? AppColors.green : Colors.transparent,
                                    ),
                                    child: isSelected
                                        ? Icon(Icons.check, size: 16.w, color: Colors.white)
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    CustomButton(
                      title: 'التالي',
                      onPressed: (){
                        cubit.selectedEstablishmentTypeId != null
                            ?
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: cubit,
                                child: const RegisterScreen(),
                              ),
                            ),
                          )

                            : null;
                      },
                      withShadow: false,
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}