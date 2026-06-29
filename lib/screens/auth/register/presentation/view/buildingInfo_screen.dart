import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mine/constants/app_colors.dart';
import 'package:mine/screens/auth/register/presentation/view/widgets/register_header.dart';
import 'package:mine/screens/auth/register/presentation/view/add_location_screen.dart';
import 'package:mine/widgets/custom_button.dart';
import 'package:mine/widgets/custom_dropdown.dart';
import 'package:mine/widgets/custom_textfield.dart';
import 'package:mine/widgets/internet_loss_connection_widget.dart';
import '../../data/settings_model.dart';
import '../view_model/building_info_cubit.dart';
import '../view_model/building_info_states.dart';

class BuildingInformationScreen extends StatefulWidget {
  const BuildingInformationScreen({super.key});

  @override
  State<BuildingInformationScreen> createState() =>
      _BuildingInformationScreenState();
}

class _BuildingInformationScreenState extends State<BuildingInformationScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final cubit = ProjectDataCubit.of(context);
    if (cubit.settingsData == null) {
      cubit.fetchSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final cubit = ProjectDataCubit.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: InternetConnectionWrapper(
          onReconnect: () {
            final cubit = ProjectDataCubit.of(context);
            if (cubit.settingsData == null) {
              cubit.fetchSettings();
            }
          },
          child: SafeArea(
            child: BlocConsumer<ProjectDataCubit, ProjectDataState>(
              listener: (context, state) {
                if (state is BuildingInfoValidationError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
                if (state is BuildingInfoSuccess) {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const AddLocationScreen(),
                      transitionDuration: const Duration(seconds: 1),
                      transitionsBuilder: (_, a, __, c) =>
                          FadeTransition(opacity: a, child: c),
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is BuildingInfoLoading) {
                  return const Center(
                    child: SpinKitWave(color: AppColors.green),
                  );
                }
                if (state is BuildingInfoError) {
                  return Center(child: Text(state.message));
                }

                final settingsData = cubit.settingsData;

                return _buildForm(context, cubit, settingsData);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(
      BuildContext context, ProjectDataCubit cubit, SettingsData? data) {
    Future<void> pickDate(TextEditingController controller) async {
      DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2100),
        initialEntryMode: DatePickerEntryMode.calendar,
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
              primaryColor: AppColors.green,
              colorScheme: ColorScheme.light(primary: AppColors.green),
              buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
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

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: ListView(
        children: [
          CustomHeader(title: "بيانات المنشأة"),
          SizedBox(height: 20.h),
          Form(
            key: cubit.formKey,
            child: Column(
              children: [
                CustomTextField(
                  label: 'تاريخ التأسيس',
                  hint: "تاريخ التأسيس",
                  controller: cubit.foundationDateController,
                  inputType: TextInputType.datetime,
                  readOnly: true,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_month,
                        color: AppColors.lightGrey, size: 20),
                    onPressed: () => pickDate(cubit.foundationDateController),
                  ),
                ),
                CustomTextField(
                  label: 'رقم الرخصة',
                  hint: "رقم الرخصة",
                  controller: cubit.licenseNumberController,
                  inputType: TextInputType.number,
                  validator: (val) =>
                      val!.isEmpty ? "أدخل رقم الرخصة" : null,
                ),

                CustomTextField(
                  label: 'تاريخ الرخصة',
                  hint: "تاريخ الرخصة",
                  readOnly: true,
                  controller: cubit.licenseDateController,
                  inputType: TextInputType.datetime,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_month,
                        color: AppColors.lightGrey, size: 20),
                    onPressed: () => pickDate(cubit.licenseDateController),
                  ),
                  validator: (val) =>
                      val!.isEmpty ? "أدخل تاريخ الرخصة" : null,
                ),

                CustomTextField(
                  label: 'الطبيب المشرف',
                  hint: "الطبيب المشرف",
                  controller: cubit.supervisingDoctorController,
                  inputType: TextInputType.text,
                  validator: (val) =>
                      val!.isEmpty ? "أدخل اسم الطبيب المشرف" : null,
                ),

                CustomTextField(
                  label: 'المساحة',
                  hint: "المساحة بالمتر",
                  controller: cubit.userAreaController, // ✳️ استخدم controller خاص بالـ user_area
                  inputType: TextInputType.number,
                ),

                CustomTextField(
                  label: 'عدد الطوابق',
                  hint: "عدد الطوابق",
                  controller: cubit.floorsCountController,
                  inputType: TextInputType.number,
                ),

                Builder(builder: (_) {
                  return CustomDropdown(
                    margin: 15.h,
                    hint: "نوع المبني",
                    label: "نوع المبني",
                    validator: (val) => val == null || val.isEmpty ? "اختر نوع المبني" : null,
                    items:
                        data?.buildingTypes.map((e) => e.name).toList() ?? [],
                    value: cubit.buildingTypeId == null || data == null
                        ? null
                        : data.buildingTypes
                            .firstWhere((e) => e.id == cubit.buildingTypeId)
                            .name,
                    onChanged: (name) {
                      if (data != null) {
                        final selected = data.buildingTypes
                            .firstWhere((e) => e.name == name);
                        cubit.setBuildingType(selected.id);
                      }

                    },

                  );
                }),
                Builder(builder: (_) {
                  return CustomDropdown(
                    margin: 15.h,
                    hint: "الحالة الفنية",
                    label: "الحالة الفنية",
                    items:
                        data?.technicalConditions.map((e) => e.name).toList() ??
                            [],
                    value: cubit.technicalConditionId == null || data == null
                        ? null
                        : data.technicalConditions
                            .firstWhere(
                                (e) => e.id == cubit.technicalConditionId)
                            .name,
                    onChanged: (name) {
                      if (data != null) {
                        final selected = data.technicalConditions
                            .firstWhere((e) => e.name == name);
                        cubit.setTechnicalCondition(selected.id);
                      }
                    },
                  );
                }),
                Builder(builder: (_) {
                  return CustomDropdown(
                    margin: 15.h,
                    hint: "نظام التدفئة",
                    label: "نظام التدفئة",
                    items:
                        data?.heatingSystems.map((e) => e.name).toList() ?? [],
                    value: cubit.heatingSystemId == null || data == null
                        ? null
                        : data.heatingSystems
                            .firstWhere((e) => e.id == cubit.heatingSystemId)
                            .name,
                    onChanged: (name) {
                      if (data != null) {
                        final selected = data.heatingSystems
                            .firstWhere((e) => e.name == name);
                        cubit.setHeatingSystem(selected.id);
                      }
                    },
                  );
                }),
                Builder(builder: (_) {
                  return CustomDropdown(
                    margin: 15.h,
                    hint: "مصدر المياه",
                    label: "مصدر المياه",
                    items: data?.waterSources.map((e) => e.name).toList() ?? [],
                    value: cubit.waterSourceId == null || data == null
                        ? null
                        : data.waterSources
                            .firstWhere((e) => e.id == cubit.waterSourceId)
                            .name,
                    onChanged: (name) {
                      if (data != null) {
                        final selected =
                            data.waterSources.firstWhere((e) => e.name == name);
                        cubit.setWaterSource(selected.id);
                      }
                    },
                  );
                }),
                Builder(builder: (_) {
                  return CustomDropdown(
                    margin: 15.h,
                    hint: "مصدر الطاقة",
                    label:  "مصدر الطاقة",
                    items: data?.powerSources.map((e) => e.name).toList() ?? [],
                    value: cubit.powerSourceId == null || data == null
                        ? null
                        : data.powerSources
                            .firstWhere((e) => e.id == cubit.powerSourceId)
                            .name,
                    onChanged: (name) {
                      if (data != null) {
                        final selected =
                            data.powerSources.firstWhere((e) => e.name == name);
                        cubit.setPowerSource(selected.id);
                      }
                    },
                  );
                }),
                SizedBox(height: 40.h),
              ],
            ),
          ),
          CustomButton(
            title: "التالي",
            withShadow: false,
            onPressed: cubit.submit,
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}
