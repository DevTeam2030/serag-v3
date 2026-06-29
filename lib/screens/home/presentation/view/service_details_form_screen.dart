import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mine/screens/projects/data/projects_model.dart';
import 'package:mine/widgets/internet_loss_connection_widget.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../widgets/custom_appbar.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/custom_textfield.dart';
import '../../../../widgets/custom_dropdown.dart';
import '../../../auth/register/presentation/view_model/building_info_cubit.dart';
import '../../../auth/register/presentation/view_model/building_info_states.dart';
import '../../../projects/presentation/view_model/projects_cubit.dart';
import '../../../projects/presentation/view_model/projects_state.dart';

class ServiceDetailsFormPage extends StatefulWidget {
  final String serviceType;
  final int subCategoryId;

  const ServiceDetailsFormPage({
    super.key,
    required this.serviceType,
    required this.subCategoryId,
  });

  @override
  State<ServiceDetailsFormPage> createState() => _ServiceDetailsFormPageState();
}

class _ServiceDetailsFormPageState extends State<ServiceDetailsFormPage> {

  ProjectDataCubit? _projectCubit;
  int? _displayProjectCount;

  @override
  void initState() {
    super.initState();
    final cubit = ProjectDataCubit.of(context);

    // Clear all data to ensure a fresh form state
    cubit.clearAllData();

    // Fetch settings if not already loaded
    if (cubit.settingsData == null) {
      cubit.fetchSettings();
    }

    // Load projects and update project count
    final projectsCubit = context.read<ProjectsCubit>();
    projectsCubit.load().then((_) {
      if (mounted) {
        setState(() {
          _displayProjectCount = context.read<ProjectsCubit>().state is ProjectsLoaded
              ? (context.read<ProjectsCubit>().state as ProjectsLoaded).projects.length + 1
              : 1;
        });
      }
    });

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _projectCubit ??= context.read<ProjectDataCubit>();
  }

  @override
  void dispose() {

    // No need to clear data here since it's handled in initState and onWillPop
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectCubit = ProjectDataCubit.of(context);

    return WillPopScope(
      onWillPop: () async {
        projectCubit.clearAllData();
        return true;
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.white,
          appBar: AppBar(
            leading: const SizedBox(),
            flexibleSpace: CustomAppBarWithTitle(
              serviceName: widget.serviceType,
              titleSize: 30.sp,
            ),
          ),
          body: SafeArea(
            child: InternetConnectionWrapper(
              onReconnect: () {
                // Optionally refetch data on reconnect
                if (projectCubit.settingsData == null) {
                  projectCubit.fetchSettings();
                }
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: BlocBuilder<ProjectDataCubit, ProjectDataState>(
                  builder: (context, state) {
                    if (state is BuildingInfoLoading) {
                      return const Center(
                        child: SpinKitWave(
                          color: AppColors.green,
                          size: 30.0,
                        ),
                      );
                    }
                    if (state is BuildingInfoError) {
                      return Center(child: Text(state.message));
                    }

                    return Form(
                      key: projectCubit.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 8.w),
                            child: Container(
                              alignment: Alignment.center,
                              height: 25.h,
                              width: 93.w,
                              decoration: BoxDecoration(
                                color: AppColors.green,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: _displayProjectCount == null
                                  ? SpinKitThreeInOut(
                                color: AppColors.white,
                                size: 10.sp,
                              )
                                  : Text(
                                'فوج $_displayProjectCount',
                                style: AppTextStyles.boldPrimary12.copyWith(
                                  color: AppColors.white,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  SizedBox(height: 6.h),
                                  CustomTextField(
                                    hint: "مصدر الصوص",
                                    controller: projectCubit.chickSourceCtrl,
                                    validator: (v) => v!.trim().isEmpty ? "هذا الحقل مطلوب" : null,
                                    label: 'مصدر الصوص',
                                  ),

                                  CustomTextField(
                                    margin: widget.serviceType == 'فروج' ? 6.h : 16.h,
                                    hint: "عدد الصوص",
                                    label: 'عدد الصوص',
                                    controller: projectCubit.chicksNumberCtrl,
                                    inputType: TextInputType.number,
                                    validator: (v) => v!.trim().isEmpty ? "أدخل عدد الصوص" : null,
                                  ),

                                  CustomTextField(
                                    // margin: 16.h,
                                    hint: "تاريخ بداية الفوج",
                                    label: 'تاريخ بداية الفوج',
                                    controller: projectCubit.startDateCtrl,
                                    readOnly: true,
                                    validator: (v) => v!.trim().isEmpty ? "اختر التاريخ" : null,
                                    suffixIcon: GestureDetector(
                                      onTap: () async {
                                        final picked = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime(2100),
                                          builder: (BuildContext context, Widget? child) {
                                            return Theme(
                                              data: ThemeData.light().copyWith(
                                                primaryColor: AppColors.green,
                                                colorScheme: const ColorScheme.light(primary: AppColors.green),
                                                buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
                                              ),
                                              child: child!,
                                            );
                                          },
                                        );

                                        if (picked != null) {
                                          projectCubit.startDateCtrl.text = picked.toIso8601String().split("T").first;
                                          DateTime endDate = picked;
                                          if (widget.serviceType == 'فروج') {
                                            endDate = picked.add(const Duration(days: 40));
                                          } else if (widget.serviceType == 'أمهات' || widget.serviceType == 'جدات الفروج') {
                                            endDate = picked.add(const Duration(days: 60 * 7));
                                          }
                                          projectCubit.endDateCtrl.text = endDate.toIso8601String().split("T").first;
                                        }
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.only(left: 8.0),
                                        child: Icon(Icons.calendar_month, color: AppColors.lightGrey, size: 20),
                                      ),
                                    ),
                                  ),

                                  if (widget.serviceType != "بيض مائده")
                                    CustomTextField(
                                      // margin: 16.h,
                                      hint: "تاريخ الانتهاء المتوقع",
                                      label: 'تاريخ الانتهاء المتوقع',
                                      controller: projectCubit.endDateCtrl,
                                      readOnly: true,
                                      validator: (v) => v!.trim().isEmpty ? "اختر التاريخ" : null,
                                    ),
                                  if (widget.serviceType == 'فروج')
                                    CustomDropdown(
                                      label: 'قنوات التوزيع',
                                      margin: 6.h,
                                      hint: "قنوات التوزيع",
                                      items: projectCubit.settingsData?.distributionChannels
                                          .map((e) => e.name)
                                          .toList() ??
                                          [],
                                      value: projectCubit.selectedDistributionChannelId == null
                                          ? null
                                          : projectCubit.settingsData?.distributionChannels
                                          .firstWhereOrNull((e) => e.id == projectCubit.selectedDistributionChannelId)
                                          ?.name,
                                      onChanged: (val) {
                                        final selected = projectCubit.settingsData?.distributionChannels
                                            .firstWhereOrNull((e) => e.name == val);
                                        projectCubit.selectedDistributionChannelId = selected?.id;
                                        setState(() {});
                                      },
                                    ),


                                  Row(
                                    children: [
                                      Expanded(
                                        child: CustomTextField(
                                          margin: 16.h,
                                          hint: "مصدر العلف",
                                          label: 'مصدر العلف',
                                          controller: projectCubit.feedSourceCtrl,
                                          // validator: (v) => v!.trim().isEmpty ? "مطلوب" : null,
                                        ),
                                      ),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: CustomTextField(
                                          suffixIcon: Padding(
                                            padding: const EdgeInsets.only(left: 8.0),
                                            child: Text('طن ', style: AppTextStyles.regularBlack12.copyWith(color: AppColors.lightGrey)),
                                          ),
                                          margin: 16.h,
                                          hint: "كمية العلف",
                                          label: 'كمية العلف',
                                          controller: projectCubit.feedQuantityCtrl,
                                          inputType: TextInputType.number,
                                          // validator: (v) => v!.trim().isEmpty ? "مطلوب" : null,
                                        ),
                                      ),
                                    ],
                                  ),

                                  if (widget.serviceType == "فروج")
                                    CustomTextField(
                                      margin: 6.h,
                                      hint: "كميه اللحم المباع",
                                      label: 'كميه اللحم المباع',
                                      controller: projectCubit.meatQuantityCtrl,
                                      inputType: TextInputType.number,
                                      // validator: (v) => v!.trim().isEmpty ? "أدخل الكميه" : null,
                                    ),

                                  if (widget.serviceType == 'فروج')
                                    Row(
                                      children: [
                                        SizedBox(width: 8.w),
                                        Expanded(
                                          child: CustomTextField(
                                            margin: 16.h,
                                            hint: "نسبة التحويل",
                                            label: 'نسبة التحويل',
                                            controller: projectCubit.conversionRateCtrl,
                                            inputType: TextInputType.number,
                                            readOnly: true,
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Text('%', style: AppTextStyles.boldBlack30),
                                      ],
                                    ),
                                  CustomTextField(
                                    margin: 7.h,
                                    hint: "عدد الطيور النافقة",
                                    label: 'عدد الطيور النافقة',
                                    controller: projectCubit.deadBirdsCtrl,
                                    inputType: TextInputType.number,
                                  ),

                                  CustomDropdown(
                                    margin: 16.h,
                                    hint: "نوع الأمراض",
                                    label: 'نوع الأمراض',
                                    items: (projectCubit.settingsData?.diseaseTypes.map((e) => e.name).toList() ?? []).reversed.toList(),
                                    value: projectCubit.selectedDiseaseTypeId == null
                                        ? null
                                        : projectCubit.settingsData?.diseaseTypes
                                        .firstWhereOrNull((e) => e.id == projectCubit.selectedDiseaseTypeId)
                                        ?.name,
                                    onChanged: (val) {
                                      final selected = projectCubit.settingsData?.diseaseTypes.firstWhereOrNull((e) => e.name == val);
                                      projectCubit.selectedDiseaseTypeId = selected?.id;
                                      if (selected?.name != "أخري") {
                                        projectCubit.otherDiseaseCtrl.clear();
                                      }
                                      setState(() {});
                                    },
                                  ),
                                  if (projectCubit.selectedDiseaseTypeId != null &&
                                      projectCubit.settingsData?.diseaseTypes
                                          .firstWhereOrNull((e) => e.id == projectCubit.selectedDiseaseTypeId)
                                          ?.name ==
                                          "أخري" || projectCubit.settingsData?.diseaseTypes
                                      .firstWhereOrNull((e) => e.id == projectCubit.selectedDiseaseTypeId)
                                      ?.name ==
                                      "اخرى")

                                    CustomTextField(
                                      margin: 16.h,
                                      hint: "أدخل نوع المرض",
                                      label: 'نوع المرض',
                                      controller: projectCubit.otherDiseaseCtrl,
                                      validator: (v) => v!.trim().isEmpty ? "يرجى كتابة نوع المرض" : null,
                                    ),
                                  CustomDropdown(
                                    margin: 6.h,
                                    hint: "برنامج التطعيم",
                                    label: 'برنامج التطعيم',
                                    items: (projectCubit.settingsData?.vaccinationPrograms.map((e) => e.name).toList() ?? []).reversed.toList(),
                                    value: projectCubit.selectedVaccinationProgramId == null
                                        ? null
                                        : projectCubit.settingsData?.vaccinationPrograms
                                        .firstWhereOrNull((e) => e.id == projectCubit.selectedVaccinationProgramId)
                                        ?.name,
                                    onChanged: (val) {
                                      final selected = projectCubit.settingsData?.vaccinationPrograms.firstWhereOrNull((e) => e.name == val);
                                      projectCubit.selectedVaccinationProgramId = selected?.id;
                                      if (selected?.name != "أخري") {
                                        projectCubit.otherVaccinationCtrl.clear();
                                      }
                                      setState(() {});
                                    },
                                  ),
                                  if (projectCubit.selectedVaccinationProgramId != null &&
                                      projectCubit.settingsData?.vaccinationPrograms
                                          .firstWhereOrNull((e) => e.id == projectCubit.selectedVaccinationProgramId)
                                          ?.name ==
                                          "أخري"||projectCubit.settingsData?.vaccinationPrograms
                                      .firstWhereOrNull((e) => e.id == projectCubit.selectedVaccinationProgramId)
                                      ?.name ==
                                      "اخرى")
                                    CustomTextField(
                                      margin: 16.h,
                                      hint: "أدخل برنامج التطعيم",
                                      label: 'برنامج التطعيم',
                                      controller: projectCubit.otherVaccinationCtrl,
                                      validator: (v) => v!.trim().isEmpty ? "يرجى كتابة البرنامج" : null,
                                    ),
                                  SizedBox(height: 20.h),
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10.h),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: BlocConsumer<ProjectsCubit, ProjectsState>(
                                        listener: (context, state) {
                                          if (state is ProjectAddSuccess) {
                                            // Clear all form data
                                            projectCubit.clearAllData();
                                            projectCubit.otherVaccinationCtrl.clear();
                                            projectCubit.otherVaccinationCtrl.clear();

                                            // Reset the form
                                            projectCubit.formKey.currentState?.reset();

                                            // Update project count
                                            setState(() {
                                              _displayProjectCount = context.read<ProjectsCubit>().state is ProjectsLoaded
                                                  ? (context.read<ProjectsCubit>().state as ProjectsLoaded).projects.length + 1
                                                  : 1;
                                            });

                                            // Show success message
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(state.message),
                                                backgroundColor: AppColors.green,
                                              ),
                                            );

                                            Navigator.pop(context);
                                          }
                                          if (state is ProjectAddFailure) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(state.message),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        },
                                        builder: (context, state) {
                                          return CustomButton(
                                            isLoading: state is ProjectAddLoading,
                                            title: "حفظ البيانات",
                                            onPressed: context.read<ProjectsCubit>().canAddNew
                                                ? () {
                                              if (projectCubit.formKey.currentState!.validate() &&
                                                  projectCubit.startDateCtrl.text.isNotEmpty &&
                                                  projectCubit.endDateCtrl.text.isNotEmpty) {
                                                // ✅ Parse meat & feed safely (ممكن يبقوا null)
                                                final meat = projectCubit.meatQuantityCtrl.text.trim().isEmpty
                                                    ? null
                                                    : double.tryParse(projectCubit.meatQuantityCtrl.text.trim());

                                                final feed = projectCubit.feedQuantityCtrl.text.trim().isEmpty
                                                    ? null
                                                    : double.tryParse(projectCubit.feedQuantityCtrl.text.trim());

                                                final feedSource = projectCubit.feedSourceCtrl.text.trim().isEmpty
                                                    ? null
                                                    : projectCubit.feedSourceCtrl.text.trim();

                                                // ✅ Validation خاص بالفروج: لو دخل قيم لازم تكون صحيحة
                                                if (widget.serviceType == 'فروج' &&
                                                    meat != null &&
                                                    feed != null &&
                                                    (meat <= 0 || feed <= 0)) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content:
                                                      Text("يرجى إدخال كمية اللحم وكمية العلف بشكل صحيح"),
                                                      backgroundColor: Colors.red,
                                                    ),
                                                  );
                                                  return;
                                                }

                                                // Calculate conversion rate and build request
                                                final requestData = projectCubit.buildAddProjectRequest(
                                                  widget.subCategoryId,
                                                  projectCubit.otherDiseaseCtrl.text.trim().isEmpty
                                                      ? ''
                                                      : projectCubit.otherDiseaseCtrl.text.trim(),
                                                  projectCubit.otherDiseaseCtrl.text.trim().isEmpty
                                                      ? ''
                                                      : projectCubit.otherDiseaseCtrl.text.trim(),
                                                  'فوج $_displayProjectCount',
                                                );

                                                if (widget.serviceType != 'فروج') {
                                                  requestData['distribution_channel_id'] = null;
                                                }

                                                if (projectCubit.selectedDiseaseTypeId != null &&
                                                    projectCubit.settingsData?.diseaseTypes
                                                        .firstWhereOrNull(
                                                            (e) => e.id == projectCubit.selectedDiseaseTypeId)
                                                        ?.name ==
                                                        "أخري") {
                                                  requestData["disease_type"] =
                                                      projectCubit.otherDiseaseCtrl.text.trim();
                                                } else {
                                                  requestData["disease_type_id"] =
                                                      projectCubit.selectedDiseaseTypeId;
                                                  requestData["disease_type"] = null;
                                                }

                                                if (projectCubit.selectedVaccinationProgramId != null &&
                                                    projectCubit.settingsData?.vaccinationPrograms
                                                        .firstWhereOrNull((e) =>
                                                    e.id ==
                                                        projectCubit.selectedVaccinationProgramId)
                                                        ?.name ==
                                                        "أخري") {
                                                  requestData["vaccination_program"] =
                                                      projectCubit.otherVaccinationCtrl.text.trim();
                                                } else {
                                                  requestData["vaccination_program_id"] =
                                                      projectCubit.selectedVaccinationProgramId;
                                                  requestData["vaccination_program"] = null;
                                                }

                                                // Handle dead birds count
                                                requestData["dead_birds_count"] =
                                                projectCubit.deadBirdsCtrl.text.trim().isEmpty
                                                    ? null
                                                    : int.tryParse(projectCubit.deadBirdsCtrl.text.trim());

                                                // ✅ ضيف meat, feed, feedSource للـ request
                                                requestData["meat_quantity"] = meat;
                                                requestData["feed_quantity"] = feed;
                                                requestData["feed_source"] = feedSource;

                                                context.read<ProjectsCubit>().addProject(requestData);
                                                print('Request data of Adding Project: $requestData');
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text("يرجى ملء الحقول المطلوبة"),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            }
                                                : () {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      "لا يمكنك إضافة فوج جديد في الوقت الحالي لديك فوج مفتوح بالفعل"),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            },
                                          );



                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}