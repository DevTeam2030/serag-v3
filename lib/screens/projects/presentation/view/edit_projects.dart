// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:mine/constants/app_text_styles.dart';
// import 'package:mine/constants/app_colors.dart';
// import 'package:mine/widgets/custom_button.dart';
// import 'package:mine/widgets/custom_textfield.dart';
// import 'package:mine/widgets/back_button.dart';
// import '../../../../constants/app_text_styles.dart';
// import '../../../../widgets/custom_appbar.dart';
// import '../../../../widgets/custom_dropdown.dart';
// import '../../../auth/register/presentation/view_model/building_info_cubit.dart';
// import '../../../auth/register/presentation/view_model/building_info_states.dart';
// import '../../data/projects_model.dart';
// import '../view_model/projects_cubit.dart';
// import '../view_model/projects_state.dart';
// import 'package:collection/collection.dart';
//
// class EditProjectScreen extends StatefulWidget {
//   final ProjectDetailsModel project;
//   final String serviceType;
//   final String projectName;
//
//   const EditProjectScreen({
//     super.key,
//     required this.project,
//     required this.serviceType,
//     required this.projectName,
//   });
//
//   @override
//   State<EditProjectScreen> createState() => _EditProjectScreenState();
// }
//
// class _EditProjectScreenState extends State<EditProjectScreen> {
//   final _otherDiseaseCtrl = TextEditingController();
//   final _otherVaccinationCtrl = TextEditingController();
//   TextEditingController nameController = TextEditingController();
//
//   ProjectDataCubit? _projectCubit;
//
//   @override
//   void initState() {
//     super.initState();
//     final cubit = ProjectDataCubit.of(context);
//
//     if (cubit.settingsData == null) {
//       cubit.fetchSettings();
//     }
//
//     // Initialize fields with project data
//     final p = widget.project;
//     nameController.text = p.name;
//     cubit.chickSourceCtrl.text = p.chicksSource ?? '';
//     cubit.chicksNumberCtrl.text = p.chicksCount.toString();
//     cubit.startDateCtrl.text = p.startDate.toIso8601String().split("T").first;
//     cubit.endDateCtrl.text = p.endDate.toIso8601String().split("T").first;
//     cubit.feedSourceCtrl.text = p.feedSource ?? '';
//     cubit.feedQuantityCtrl.text = p.feedAmount ?? '';
//     cubit.meatQuantityCtrl.text = p.meatQuantity ?? '';
//     cubit.conversionRateCtrl.text = p.conversionRate ?? '';
//     cubit.deadBirdsCtrl.text = p.deadBirds.toString();
//
//     // Set IDs, treating 0 as null (no selection)
//     cubit.selectedDistributionChannelId = p.distributionChannelId == 0 ? null : p.distributionChannelId;
//     cubit.selectedDiseaseTypeId = p.diseaseTypeId == 0 ? null : p.diseaseTypeId;
//     cubit.selectedVaccinationProgramId = p.vaccinationProgramId == 0 ? null : p.vaccinationProgramId;
//
//     // Initialize "Other" fields if applicable
//     cubit.otherDiseaseCtrl.text = p.diseaseTypeName ?? '';
//     cubit.otherVaccinationCtrl.text = p.vaccinationProgramName ?? '';
//   }
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _projectCubit ??= context.read<ProjectDataCubit>();
//   }
//
//   @override
//   void dispose() {
//     _otherDiseaseCtrl.dispose();
//     _otherVaccinationCtrl.dispose();
//     nameController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final projectCubit = ProjectDataCubit.of(context);
//
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           leading: const SizedBox(),
//           flexibleSpace: CustomAppBarWithTitle(
//             serviceName: "تعديل المشروع",
//             titleSize: 30.sp,
//           ),
//         ),
//         body: SafeArea(
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//             child: BlocBuilder<ProjectDataCubit, ProjectDataState>(
//               builder: (context, state) {
//                 return Form(
//                   key: projectCubit.formKey,
//                   child: SingleChildScrollView(
//                     child: Column(
//                       children: [
//                         // Project Name
//                         CustomTextField(
//                           controller: nameController,
//                           hint: 'اسم المشروع',
//                           label: "اسم المشروع",
//                           validator: (v) => v!.trim().isEmpty ? "هذا الحقل مطلوب" : null,
//                         ),
//
//                         // Chick Source
//                         CustomTextField(
//                           hint: "مصدر الصوص",
//                           controller: projectCubit.chickSourceCtrl,
//                           validator: (v) => v!.trim().isEmpty ? "هذا الحقل مطلوب" : null,
//                           label: 'مصدر الصوص',
//                         ),
//
//                         // Distribution Channel (for فروج only)
//                         if (widget.serviceType == 'فروج')
//                           CustomDropdown(
//                             label: 'قنوات التوزيع',
//                             margin: 16.h,
//                             hint: "قنوات التوزيع",
//                             items: [...projectCubit.settingsData?.distributionChannels
//                                 .map((e) => e.name)
//                                 .toList() ?? []],
//                             value: projectCubit.selectedDistributionChannelId == null
//                                 ? 'غير محدد'
//                                 : projectCubit.settingsData?.distributionChannels
//                                 .firstWhereOrNull((e) => e.id == projectCubit.selectedDistributionChannelId)
//                                 ?.name,
//                             onChanged: (val) {
//                               if (val == 'غير محدد') {
//                                 projectCubit.selectedDistributionChannelId = null;
//                               } else {
//                                 final selected = projectCubit.settingsData?.distributionChannels
//                                     .firstWhereOrNull((e) => e.name == val);
//                                 projectCubit.selectedDistributionChannelId = selected?.id;
//                               }
//                               setState(() {});
//                             },
//                           ),
//
//                         // Number of Chicks
//                         CustomTextField(
//                           margin: 16.h,
//                           hint: "عدد الأصواص",
//                           label: 'عدد الأصواص',
//                           controller: projectCubit.chicksNumberCtrl,
//                           inputType: TextInputType.number,
//                           validator: (v) => v!.trim().isEmpty ? "أدخل عدد الأصواص" : null,
//                         ),
//
//                         // Start Date
//                         CustomTextField(
//                           margin: 16.h,
//                           hint: "تاريخ بداية الفوج",
//                           label: 'تاريخ بداية الفوج',
//                           controller: projectCubit.startDateCtrl,
//                           readOnly: true,
//                           validator: (v) => v!.trim().isEmpty ? "اختر التاريخ" : null,
//                         ),
//
//                         if (widget.serviceType != 'بيض مائدة')
//                         CustomTextField(
//                           margin: 16.h,
//                           hint: "تاريخ الانتهاء المتوقع",
//                           label: 'تاريخ الانتهاء المتوقع',
//                           controller: projectCubit.endDateCtrl,
//                           readOnly: true,
//                           validator: (v) => v!.trim().isEmpty ? "اختر التاريخ" : null,
//                         ),
//
//                         // Feed Source and Quantity
//                         Row(
//                           children: [
//                             Expanded(
//                               child: CustomTextField(
//                                 margin: 16.h,
//                                 hint: "مصدر العلف",
//                                 label: 'مصدر العلف',
//                                 controller: projectCubit.feedSourceCtrl,
//                                 validator: (v) => v!.trim().isEmpty ? "مطلوب" : null,
//                               ),
//                             ),
//                             SizedBox(width: 10.w),
//                             Expanded(
//                               child: CustomTextField(
//                                 margin: 16.h,
//                                 hint: "كمية العلف",
//                                 label: 'كمية العلف',
//                                 controller: projectCubit.feedQuantityCtrl,
//                                 inputType: TextInputType.number,
//                                 validator: (v) => v!.trim().isEmpty ? "مطلوب" : null,
//                               ),
//                             ),
//                           ],
//                         ),
//
//                         // Meat Quantity (for فروج only)
//                         if (widget.serviceType == 'فروج')
//                           CustomTextField(
//                             margin: 15.h,
//                             hint: "كميه اللحم المباع",
//                             label: 'كميه اللحم المباع',
//                             controller: projectCubit.meatQuantityCtrl,
//                             inputType: TextInputType.number,
//                             validator: (v) => v!.trim().isEmpty ? "أدخل الكميه" : null,
//                           ),
//
//                         // Conversion Rate (for فروج only)
//                         if (widget.serviceType == 'فروج')
//                           CustomTextField(
//                             margin: 16.h,
//                             hint: "نسبة التحويل",
//                             label: 'نسبة التحويل',
//                             controller: projectCubit.conversionRateCtrl,
//                             inputType: TextInputType.number,
//                             readOnly: true,
//                           ),
//
//                         // Dead Birds
//                         CustomTextField(
//                           margin: 16.h,
//                           hint: "عدد الطيور النافقة",
//                           label: 'عدد الطيور النافقة',
//                           controller: projectCubit.deadBirdsCtrl,
//                           inputType: TextInputType.number,
//                         ),
//
//                         // Disease Type
//                         CustomDropdown(
//                           margin: 16.h,
//                           hint: "نوع الأمراض",
//                           label: 'نوع الأمراض',
//                           items: [ ...(projectCubit.settingsData?.diseaseTypes
//                               .map((e) => e.name)
//                               .toList())?.reversed.toList() ?? []],
//                           value: projectCubit.selectedDiseaseTypeId == null
//                               ? 'غير محدد'
//                               : projectCubit.settingsData?.diseaseTypes
//                               .firstWhereOrNull((e) => e.id == projectCubit.selectedDiseaseTypeId)
//                               ?.name,
//                           onChanged: (val) {
//                             if (val == 'غير محدد') {
//                               projectCubit.selectedDiseaseTypeId = null;
//                               _otherDiseaseCtrl.clear();
//                             } else {
//                               final selected = projectCubit.settingsData?.diseaseTypes
//                                   .firstWhereOrNull((e) => e.name == val);
//                               projectCubit.selectedDiseaseTypeId = selected?.id;
//                               if (selected?.name != "أخري") {
//                                 _otherDiseaseCtrl.clear();
//                               }
//                             }
//                             setState(() {});
//                           },
//                         ),
//
//                         // Other Disease Text Field
//                         if (projectCubit.selectedDiseaseTypeId != null &&
//                             projectCubit.settingsData?.diseaseTypes
//                                 .firstWhereOrNull((e) => e.id == projectCubit.selectedDiseaseTypeId)
//                                 ?.name ==
//                                 "أخري")
//                           CustomTextField(
//                             margin: 5.h,
//                             hint: "أدخل نوع المرض",
//                             label: 'نوع المرض',
//                             controller: projectCubit.otherDiseaseCtrl,
//                             validator: (v) => v!.trim().isEmpty ? "يرجى كتابة نوع المرض" : null,
//                           ),
//
//                         // Vaccination Program
//                         CustomDropdown(
//                           margin: 15.h,
//                           hint: "برنامج التطعيم",
//                           label: 'برنامج التطعيم',
//                           items: [ ...(projectCubit.settingsData?.vaccinationPrograms
//                               .map((e) => e.name)
//                               .toList())?.reversed.toList() ?? []],
//                           value: projectCubit.selectedVaccinationProgramId == null
//                               ? 'غير محدد'
//                               : projectCubit.settingsData?.vaccinationPrograms
//                               .firstWhereOrNull((e) => e.id == projectCubit.selectedVaccinationProgramId)
//                               ?.name,
//                           onChanged: (val) {
//                             if (val == 'غير محدد') {
//                               projectCubit.selectedVaccinationProgramId = null;
//                               _otherVaccinationCtrl.clear();
//                             } else {
//                               final selected = projectCubit.settingsData?.vaccinationPrograms
//                                   .firstWhereOrNull((e) => e.name == val);
//                               projectCubit.selectedVaccinationProgramId = selected?.id;
//                               if (selected?.name != "أخري") {
//                                 _otherVaccinationCtrl.clear();
//                               }
//                             }
//                             setState(() {});
//                           },
//                         ),
//
//                         // Other Vaccination Text Field
//                         if (projectCubit.selectedVaccinationProgramId != null &&
//                             projectCubit.settingsData?.vaccinationPrograms
//                                 .firstWhereOrNull((e) => e.id == projectCubit.selectedVaccinationProgramId)
//                                 ?.name ==
//                                 "أخري")
//                           CustomTextField(
//                             margin: 5.h,
//                             hint: "أدخل برنامج التطعيم",
//                             label: 'برنامج التطعيم',
//                             controller: projectCubit.otherVaccinationCtrl,
//                             validator: (v) => v!.trim().isEmpty ? "يرجى كتابة البرنامج" : null,
//                           ),
//
//                         SizedBox(height: 20.h),
//
//                         // Save Button
//                         BlocConsumer<ProjectsCubit, ProjectsState>(
//                           listener: (context, state) {
//                             if (state is ProjectEditSuccess) {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(
//                                   content: Text(state.message),
//                                   backgroundColor: AppColors.green,
//                                 ),
//                               );
//                               Navigator.pop(context, true);
//                             } else if (state is ProjectEditFailure) {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(
//                                   content: Text(state.message),
//                                   backgroundColor: Colors.red,
//                                 ),
//                               );
//                             }
//                           },
//                           builder: (context, state) {
//                             return CustomButton(
//                               isLoading: state is ProjectEditLoading,
//                               title: "حفظ التعديلات",
//                               onPressed: () {
//                                 if (projectCubit.formKey.currentState!.validate()) {
//                                   final data = {
//                                     "id": widget.project.id,
//                                     "name": nameController.text.trim(),
//                                     "distribution_channel_id":
//                                     widget.serviceType == 'فروج'
//                                         ? (projectCubit.selectedDistributionChannelId == 0
//                                         ? null
//                                         : projectCubit.selectedDistributionChannelId)
//                                         : null,
//                                     "chick_source": projectCubit.chickSourceCtrl.text.trim(),
//                                     "number_of_chicks": projectCubit.chicksNumberCtrl.text.trim(),
//                                     "start_date": projectCubit.startDateCtrl.text.trim(),
//                                     "expected_end_date": projectCubit.endDateCtrl.text.trim(),
//                                     "feed_source": projectCubit.feedSourceCtrl.text.trim(),
//                                     "feed_quantity": projectCubit.feedQuantityCtrl.text.trim(),
//                                     "meat_quantity": projectCubit.meatQuantityCtrl.text.trim(),
//                                     "conversion_rate": projectCubit.conversionRateCtrl.text.trim(),
//                                     "dead_birds": projectCubit.deadBirdsCtrl.text.trim(),
//                                     "disease_type_id": projectCubit.selectedDiseaseTypeId == 0
//                                         ? null
//                                         : projectCubit.selectedDiseaseTypeId,
//                                     "vaccination_program_id": projectCubit.selectedVaccinationProgramId == 0
//                                         ? null
//                                         : projectCubit.selectedVaccinationProgramId,
//                                   };
//
//                                   // Handle "Other" Disease Type
//                                   if (projectCubit.selectedDiseaseTypeId != null &&
//                                        projectCubit.settingsData?.diseaseTypes
//                                           .firstWhereOrNull((e) => e.id == projectCubit.selectedDiseaseTypeId)
//                                           ?.name ==
//                                           "أخري") {
//                                     // إذا ماكانش في أي اختيار قبلها
//                                     data["disease_type_id"] ??= 1;
//                                     data["disease_type"] = _otherDiseaseCtrl.text.trim();
//                                   } else {
//                                     data["disease_type"] = null;
//                                   }
//
//                                   // Handle "Other" Vaccination Program
//                                   if (projectCubit.selectedVaccinationProgramId != null &&
//                                       projectCubit.settingsData?.vaccinationPrograms
//                                           .firstWhereOrNull((e) => e.id == projectCubit.selectedVaccinationProgramId)
//                                           ?.name ==
//                                           "أخري") {
//                                     // إذا ماكانش في أي اختيار قبلها
//                                     data["vaccination_program_id"] ??= 1;
//                                     data["vaccination_program"] = _otherVaccinationCtrl.text.trim();
//                                   } else {
//                                     data["vaccination_program"] = null;
//                                   }
//
//                                   context.read<ProjectsCubit>().editProject(data);
//                                   print("Editing project with data: $data");
//                                 } else {
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     SnackBar(
//                                       content: Text("يرجى ملء الحقول المطلوبة"),
//                                       backgroundColor: Colors.red,
//                                     ),
//                                   );
//                                 }
//                               },
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mine/constants/app_colors.dart';
import 'package:mine/widgets/custom_button.dart';
import 'package:mine/widgets/custom_textfield.dart';
import '../../../../widgets/custom_appbar.dart';
import '../../../../widgets/custom_dropdown.dart';
import '../../../auth/register/presentation/view_model/building_info_cubit.dart';
import '../../../auth/register/presentation/view_model/building_info_states.dart';
import '../../data/projects_model.dart';
import '../view_model/projects_cubit.dart';
import '../view_model/projects_state.dart';

import 'package:collection/collection.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mine/constants/app_colors.dart';
import 'package:mine/widgets/custom_button.dart';
import 'package:mine/widgets/custom_textfield.dart';
import 'package:mine/widgets/custom_appbar.dart';
import 'package:mine/widgets/custom_dropdown.dart';
import 'package:collection/collection.dart';
import '../../../auth/register/presentation/view_model/building_info_cubit.dart';
import '../../../auth/register/presentation/view_model/building_info_states.dart';
import '../../data/projects_model.dart';
import '../view_model/projects_cubit.dart';
import '../view_model/projects_state.dart';

class EditProjectScreen extends StatefulWidget {
  final ProjectDetailsModel project;
  final String serviceType;
  final String projectName;

  const EditProjectScreen({
    super.key,
    required this.project,
    required this.serviceType,
    required this.projectName,
  });

  @override
  State<EditProjectScreen> createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends State<EditProjectScreen> {
  TextEditingController nameController = TextEditingController();
  ProjectDataCubit? _projectCubit;

  @override
  @override
  void initState() {
    super.initState();
    final cubit = ProjectDataCubit.of(context);

    if (cubit.settingsData == null) {
      cubit.fetchSettings();
    }

    final p = widget.project;

    // Fill basic fields
    nameController.text = p.name;
    cubit.chickSourceCtrl.text = p.chicksSource ?? '';
    cubit.chicksNumberCtrl.text = p.chicksCount.toString();
    cubit.startDateCtrl.text = p.startDate.toIso8601String().split("T").first;
    cubit.endDateCtrl.text = p.endDate.toIso8601String().split("T").first;
    cubit.feedSourceCtrl.text = p.feedSource ?? '';
    cubit.feedQuantityCtrl.text = p.feedAmount ?? '';
    cubit.meatQuantityCtrl.text = (p.meatQuantity.isNotEmpty) ? p.meatQuantity : '';
    cubit.conversionRateCtrl.text = p.conversionRate ?? '';
    cubit.deadBirdsCtrl.text = p.deadBirds.toString();

    // Distribution Channel
    cubit.selectedDistributionChannelId =
    p.distributionChannelId == 0 ? null : p.distributionChannelId;

    // ✅ Disease Type Fix
    final disease = cubit.settingsData?.diseaseTypes
        .firstWhereOrNull((e) => e.id == p.diseaseTypeId);

    if (disease != null) {
      cubit.selectedDiseaseTypeId = disease.id;
      if (disease.name == "أخري") {
        cubit.otherDiseaseCtrl.text = p.diseaseTypeName ?? '';
      } else {
        cubit.otherDiseaseCtrl.clear();
      }
    } else if ((p.diseaseTypeName?.isNotEmpty ?? false)) {
      // not found → fallback to "أخري"
      final otherId = cubit.settingsData?.diseaseTypes
          .firstWhereOrNull((e) => e.name == "أخري")
          ?.id;
      cubit.selectedDiseaseTypeId = otherId;
      cubit.otherDiseaseCtrl.text = p.diseaseTypeName ?? '';
    } else {
      cubit.selectedDiseaseTypeId = null;
      cubit.otherDiseaseCtrl.clear();
    }

    // ✅ Vaccination Fix
    final vacc = cubit.settingsData?.vaccinationPrograms
        .firstWhereOrNull((e) => e.id == p.vaccinationProgramId);

    if (vacc != null) {
      cubit.selectedVaccinationProgramId = vacc.id;
      if (vacc.name == "أخري") {
        cubit.otherVaccinationCtrl.text = p.vaccinationProgramName ?? '';
      } else {
        cubit.otherVaccinationCtrl.clear();
      }
    } else if ((p.vaccinationProgramName?.isNotEmpty ?? false)) {
      final otherId = cubit.settingsData?.vaccinationPrograms
          .firstWhereOrNull((e) => e.name == "أخري")
          ?.id;
      cubit.selectedVaccinationProgramId = otherId;
      cubit.otherVaccinationCtrl.text = p.vaccinationProgramName ?? '';
    } else {
      cubit.selectedVaccinationProgramId = null;
      cubit.otherVaccinationCtrl.clear();
    }

    print("✅ Initialized diseaseTypeId: ${cubit.selectedDiseaseTypeId}, "
        "vaccinationProgramId: ${cubit.selectedVaccinationProgramId}, "
        "otherDisease: ${cubit.otherDiseaseCtrl.text}, "
        "otherVaccination: ${cubit.otherVaccinationCtrl.text}");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _projectCubit ??= context.read<ProjectDataCubit>();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectCubit = ProjectDataCubit.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: const SizedBox(),
          flexibleSpace: CustomAppBarWithTitle(
            serviceName: "تعديل الفوج",
            titleSize: 30.sp,
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: BlocBuilder<ProjectDataCubit, ProjectDataState>(
              builder: (context, state) {
                return Form(
                  key: projectCubit.formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Project Name
                        CustomTextField(
                          controller: nameController,
                          hint: 'اسم الفوج',
                          label: "اسم الفوج",
                          validator: (v) => v!.trim().isEmpty ? "هذا الحقل مطلوب" : null,
                        ),
                        // Chick Source
                        CustomTextField(
                          hint: "مصدر الصوص",
                          controller: projectCubit.chickSourceCtrl,
                          validator: (v) => v!.trim().isEmpty ? "هذا الحقل مطلوب" : null,
                          label: 'مصدر الصوص',
                        ),

                        // Number of Chicks
                        CustomTextField(
                          margin: 6.h,
                          hint: "عدد الصوص",
                          label: 'عدد الصوص',
                          controller: projectCubit.chicksNumberCtrl,
                          inputType: TextInputType.number,
                          validator: (v) => v!.trim().isEmpty ? "أدخل عدد الصوص" : null,
                        ),


                        // Start Date
                        CustomTextField(
                          margin: 16.h,
                          hint: "تاريخ بداية الفوج",
                          label: 'تاريخ بداية الفوج',
                          controller: projectCubit.startDateCtrl,
                          readOnly: true,
                          validator: (v) => v!.trim().isEmpty ? "اختر التاريخ" : null,
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_month,color: AppColors.lightGrey, size: 20),
                            onPressed: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: widget.project.startDate, // current project start date
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: AppColors.green,
                                        onPrimary: Colors.white,
                                      ),
                                      dialogBackgroundColor: Colors.white,
                                    ),
                                    child: child!,
                                  );
                                },
                              );

                              if (pickedDate != null) {
                                setState(() {
                                  projectCubit.startDateCtrl.text =
                                      pickedDate.toIso8601String().split("T").first;
                                });
                              }
                            },
                          ),
                        ),


                        // Expected End Date
                        if (widget.serviceType != 'بيض مائدة')
                          CustomTextField(
                            margin: 6.h,
                            hint: "تاريخ الانتهاء المتوقع",
                            label: 'تاريخ الانتهاء المتوقع',
                            controller: projectCubit.endDateCtrl,
                            readOnly: true,
                            validator: (v) => v!.trim().isEmpty ? "اختر التاريخ" : null,
                          ),

                        // Distribution Channel (for فروج only)
                        if (widget.serviceType == 'فروج')
                          CustomDropdown(
                            label: 'قنوات التوزيع',
                            margin: 16.h,
                            hint: "قنوات التوزيع",
                            items: [
                              ...projectCubit.settingsData?.distributionChannels
                                  .map((e) => e.name)
                                  .toList() ??
                                  []
                            ],
                            value: projectCubit.selectedDistributionChannelId == null
                                ? 'غير محدد'
                                : projectCubit.settingsData?.distributionChannels
                                .firstWhereOrNull(
                                    (e) => e.id == projectCubit.selectedDistributionChannelId)
                                ?.name,
                            onChanged: (val) {
                              if (val == 'غير محدد') {
                                projectCubit.selectedDistributionChannelId = null;
                              } else {
                                final selected = projectCubit.settingsData?.distributionChannels
                                    .firstWhereOrNull((e) => e.name == val);
                                projectCubit.selectedDistributionChannelId = selected?.id;
                              }
                              setState(() {});
                            },
                          ),



                        // Feed Source and Quantity
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

                        // Meat Quantity (for فروج only)
                        if (widget.serviceType == 'فروج')
                          CustomTextField(
                            margin: 15.h,
                            hint: "كمية اللحم المباع",
                            label: 'كمية اللحم المباع',
                            controller: projectCubit.meatQuantityCtrl,
                            inputType: TextInputType.number,
                            // validator: (v) => v!.trim().isEmpty ? "أدخل الكمية" : null,
                          ),

                        // Conversion Rate (for فروج only)
                        if (widget.serviceType == 'فروج')
                          CustomTextField(
                            margin: 6.h,
                            hint: "نسبة التحويل",
                            label: 'نسبة التحويل',
                            controller: projectCubit.conversionRateCtrl,
                            inputType: TextInputType.number,
                            readOnly: true,
                          ),

                        // Dead Birds
                        CustomTextField(
                          margin: 16.h,
                          hint: "عدد الطيور النافقة",
                          label: 'عدد الطيور النافقة',
                          controller: projectCubit.deadBirdsCtrl,
                          inputType: TextInputType.number,
                        ),

                        // Disease Type
                        CustomDropdown(
                          margin: 6.h,
                          hint: "نوع الأمراض",
                          label: 'نوع الأمراض',
                          items: [
                            ...(projectCubit.settingsData?.diseaseTypes
                                .map((e) => e.name)
                                .toList())
                                ?.reversed
                                .toList() ??
                                []
                          ],
                          value: projectCubit.selectedDiseaseTypeId == null
                              ? 'غير محدد'
                              : projectCubit.settingsData?.diseaseTypes
                              .firstWhereOrNull((e) => e.id == projectCubit.selectedDiseaseTypeId)
                              ?.name,
                          onChanged: (val) {
                            if (val == 'غير محدد') {
                              projectCubit.selectedDiseaseTypeId = null;
                              projectCubit.otherDiseaseCtrl.clear();
                            } else {
                              final selected = projectCubit.settingsData?.diseaseTypes
                                  .firstWhereOrNull((e) => e.name == val);
                              projectCubit.selectedDiseaseTypeId = selected?.id;
                              if (selected?.name != "أخري") {
                                projectCubit.otherDiseaseCtrl.clear();
                              }
                            }
                            setState(() {});
                          },
                        ),

                        // Other Disease Text Field
                        if (projectCubit.selectedDiseaseTypeId != null &&
                            projectCubit.settingsData?.diseaseTypes
                                .firstWhereOrNull((e) => e.id == projectCubit.selectedDiseaseTypeId)
                                ?.name ==
                                "أخري"||projectCubit.settingsData?.diseaseTypes
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

                        // Vaccination Program
                        CustomDropdown(
                          margin: 6.h,
                          hint: "برنامج التطعيم",
                          label: 'برنامج التطعيم',
                          items: [
                            ...(projectCubit.settingsData?.vaccinationPrograms
                                .map((e) => e.name)
                                .toList())
                                ?.reversed
                                .toList() ??
                                []
                          ],
                          value: projectCubit.selectedVaccinationProgramId == null
                              ? 'غير محدد'
                              : projectCubit.settingsData?.vaccinationPrograms
                              .firstWhereOrNull(
                                  (e) => e.id == projectCubit.selectedVaccinationProgramId)
                              ?.name,
                          onChanged: (val) {
                            if (val == 'غير محدد') {
                              projectCubit.selectedVaccinationProgramId = null;
                              projectCubit.otherVaccinationCtrl.clear();
                            } else {
                              final selected = projectCubit.settingsData?.vaccinationPrograms
                                  .firstWhereOrNull((e) => e.name == val);
                              projectCubit.selectedVaccinationProgramId = selected?.id;
                              if (selected?.name != "أخري") {
                                projectCubit.otherVaccinationCtrl.clear();
                              }
                            }
                            setState(() {});
                          },
                        ),

                        // Other Vaccination Text Field
                        if (projectCubit.selectedVaccinationProgramId != null &&
                            projectCubit.settingsData?.vaccinationPrograms
                                .firstWhereOrNull(
                                    (e) => e.id == projectCubit.selectedVaccinationProgramId)
                                ?.name ==
                                "أخري"||projectCubit.settingsData?.vaccinationPrograms
                            .firstWhereOrNull(
                                (e) => e.id == projectCubit.selectedVaccinationProgramId)
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

                        // Save Button
                        BlocConsumer<ProjectsCubit, ProjectsState>(
                          listener: (context, state) {
                            if (state is ProjectEditSuccess) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(state.message),
                                  backgroundColor: AppColors.green,
                                ),
                              );
                              Navigator.pop(context, true);
                            } else if (state is ProjectEditFailure) {
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
                              isLoading: state is ProjectEditLoading,
                              title: "حفظ التعديلات",
                              onPressed: () {
                                if (projectCubit.formKey.currentState!.validate()) {
                                  final meat = double.tryParse(projectCubit.meatQuantityCtrl.text.trim());
                                  final feed = double.tryParse(projectCubit.feedQuantityCtrl.text.trim());

                                  // حساب معدل التحويل لو الاتنين موجودين وصح
                                  String? conversionRate;
                                  if (widget.serviceType == 'فروج' && meat != null && feed != null && feed > 0) {
                                    conversionRate = (meat / feed).toStringAsFixed(2);
                                  }

                                  final data = {
                                    "id": widget.project.id,
                                    "name": nameController.text.trim(),
                                    "distribution_channel_id": widget.serviceType == 'فروج'
                                        ? (projectCubit.selectedDistributionChannelId == 0
                                        ? null
                                        : projectCubit.selectedDistributionChannelId)
                                        : null,
                                    "chick_source": projectCubit.chickSourceCtrl.text.trim(),
                                    "number_of_chicks": projectCubit.chicksNumberCtrl.text.trim(),
                                    "start_date": projectCubit.startDateCtrl.text.trim(),
                                    "expected_end_date": projectCubit.endDateCtrl.text.trim(),
                                    // ✅ null لو المستخدم ما دخلش
                                    "feed_source": projectCubit.feedSourceCtrl.text.trim().isEmpty
                                        ? null
                                        : projectCubit.feedSourceCtrl.text.trim(),
                                    "feed_quantity": projectCubit.feedQuantityCtrl.text.trim().isEmpty
                                        ? null
                                        : projectCubit.feedQuantityCtrl.text.trim(),
                                    "quantity_sold_meat": projectCubit.meatQuantityCtrl.text.trim(),
                                    "conversion_rate": conversionRate,
                                    "dead_birds": projectCubit.deadBirdsCtrl.text.trim().isEmpty
                                        ? null
                                        : projectCubit.deadBirdsCtrl.text.trim(),
                                    "disease_type_id": projectCubit.selectedDiseaseTypeId == 0
                                        ? null
                                        : projectCubit.selectedDiseaseTypeId,
                                    "vaccination_program_id": projectCubit.selectedVaccinationProgramId == 0
                                        ? null
                                        : projectCubit.selectedVaccinationProgramId,
                                  };

                                  // Handle "Other" Disease
                                  if (projectCubit.selectedDiseaseTypeId != null &&
                                      projectCubit.settingsData?.diseaseTypes
                                          .firstWhereOrNull((e) => e.id == projectCubit.selectedDiseaseTypeId)
                                          ?.name ==
                                          "أخري") {
                                    data["disease_type_id"] ??= 1;
                                    data["disease_type"] = projectCubit.otherDiseaseCtrl.text.trim();
                                  } else {
                                    data["disease_type"] = null;
                                  }

                                  // Handle "Other" Vaccination
                                  if (projectCubit.selectedVaccinationProgramId != null &&
                                      projectCubit.settingsData?.vaccinationPrograms
                                          .firstWhereOrNull((e) => e.id == projectCubit.selectedVaccinationProgramId)
                                          ?.name ==
                                          "أخري") {
                                    data["vaccination_program_id"] ??= 1;
                                    data["vaccination_program"] = projectCubit.otherVaccinationCtrl.text.trim();
                                  } else {
                                    data["vaccination_program"] = null;
                                  }

                                  context.read<ProjectsCubit>().editProject(data);
                                  print("Editing project with data: $data");
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("يرجى ملء الحقول المطلوبة"),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },

                              // onPressed: () {
                              //   if (projectCubit.formKey.currentState!.validate()) {
                              //     final data = {
                              //       "id": widget.project.id,
                              //       "name": nameController.text.trim(),
                              //       "distribution_channel_id": widget.serviceType == 'فروج'
                              //           ? (projectCubit.selectedDistributionChannelId == 0
                              //           ? null
                              //           : projectCubit.selectedDistributionChannelId)
                              //           : null,
                              //       "chick_source": projectCubit.chickSourceCtrl.text.trim(),
                              //       "number_of_chicks": projectCubit.chicksNumberCtrl.text.trim(),
                              //       "start_date": projectCubit.startDateCtrl.text.trim(),
                              //       "expected_end_date": projectCubit.endDateCtrl.text.trim(),
                              //       "feed_source": projectCubit.feedSourceCtrl.text.trim(),
                              //       "feed_quantity": projectCubit.feedQuantityCtrl.text.trim(),
                              //       "quantity_sold_meat": projectCubit.meatQuantityCtrl.text.trim(),
                              //       "conversion_rate": projectCubit.conversionRateCtrl.text.trim(),
                              //       "dead_birds": projectCubit.deadBirdsCtrl.text.trim(),
                              //       "disease_type_id": projectCubit.selectedDiseaseTypeId == 0
                              //           ? null
                              //           : projectCubit.selectedDiseaseTypeId,
                              //       "vaccination_program_id":
                              //       projectCubit.selectedVaccinationProgramId == 0
                              //           ? null
                              //           : projectCubit.selectedVaccinationProgramId,
                              //     };
                              //
                              //     // Handle "Other" Disease
                              //     if (projectCubit.selectedDiseaseTypeId != null &&
                              //         projectCubit.settingsData?.diseaseTypes
                              //             .firstWhereOrNull(
                              //                 (e) => e.id == projectCubit.selectedDiseaseTypeId)
                              //             ?.name ==
                              //             "أخري") {
                              //       data["disease_type_id"] ??= 1;
                              //       data["disease_type"] = projectCubit.otherDiseaseCtrl.text.trim();
                              //     } else {
                              //       data["disease_type"] = null;
                              //     }
                              //
                              //     // Handle "Other" Vaccination
                              //     if (projectCubit.selectedVaccinationProgramId != null &&
                              //         projectCubit.settingsData?.vaccinationPrograms
                              //             .firstWhereOrNull((e) =>
                              //         e.id == projectCubit.selectedVaccinationProgramId)
                              //             ?.name ==
                              //             "أخري") {
                              //       data["vaccination_program_id"] ??= 1;
                              //       data["vaccination_program"] =
                              //           projectCubit.otherVaccinationCtrl.text.trim();
                              //     } else {
                              //       data["vaccination_program"] = null;
                              //     }
                              //
                              //     context.read<ProjectsCubit>().editProject(data);
                              //     print("Editing project with data: $data");
                              //   } else {
                              //     ScaffoldMessenger.of(context).showSnackBar(
                              //       SnackBar(
                              //         content: Text("يرجى ملء الحقول المطلوبة"),
                              //         backgroundColor: Colors.red,
                              //       ),
                              //     );
                              //   }
                              // },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
