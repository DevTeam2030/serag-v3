import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mine/screens/auth/register/presentation/view/widgets/register_header.dart';
import 'package:mine/widgets/custom_dropdown.dart';
import '../../../../../constants/app_text_styles.dart';
import '../../../../../core/helper/cache_helper.dart';
import '../../../../../widgets/custom_button.dart';
import '../../../../../widgets/custom_richtext.dart';
import '../../../../../widgets/custom_textfield.dart';
import '../../../login/presentation/view/login_screen.dart';
import '../../data/settings_model.dart';
import '../view_model/building_info_cubit.dart';
import '../view_model/building_info_states.dart';
import '../view_model/register_cubit.dart';
import '../view_model/register_state.dart';
import 'add_location_screen.dart';
import 'buildingInfo_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int? _previousEstablishmentTypeId;
  late RegisterCubit _registerCubit;
  late ProjectDataCubit _projectCubit;

  @override
  void initState() {
    super.initState();
    // Store references to cubits
    _registerCubit = RegisterCubit.of(context);
    _projectCubit = ProjectDataCubit.of(context);

    // Store initial establishment type
    _previousEstablishmentTypeId = _projectCubit.selectedEstablishmentTypeId;
  }

  @override
  void dispose() {
    // Clear controllers and reset state
    _registerCubit.clearControllers();
    _projectCubit.clearAllData(); // Clear city/area selections
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        body: SafeArea(
          child: BlocConsumer<RegisterCubit, RegisterState>(
            listener: (context, state) {
              if (state is RegisterValidation) {
                final projectCubit = ProjectDataCubit.of(context);
                final establishmentTypeId =
                    projectCubit.selectedEstablishmentTypeId;

                // Only المدجنة (id: 1) goes to building info
                if (establishmentTypeId == 1) {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => BlocProvider.value(
                        value: projectCubit,
                        child: const BuildingInformationScreen(),
                      ),
                      transitionDuration: const Duration(seconds: 1),
                      transitionsBuilder: (_, a, __, c) =>
                          FadeTransition(opacity: a, child: c),
                    ),
                  );
                } else {
                  // For other types (2-5), go directly to location screen
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => MultiBlocProvider(
                        providers: [
                          BlocProvider.value(value: projectCubit),
                          BlocProvider.value(value: RegisterCubit.of(context)),
                        ],
                        child: const AddLocationScreen(),
                      ),
                      transitionDuration: const Duration(seconds: 1),
                      transitionsBuilder: (_, a, __, c) =>
                          FadeTransition(opacity: a, child: c),
                    ),
                  );
                }
              }
              if (state is RegisterValidationError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            builder: (context, state) {
              final cubit = RegisterCubit.of(context);
              final projectCubit = ProjectDataCubit.of(context);
              final establishmentTypeId =
                  projectCubit.selectedEstablishmentTypeId;

              // Check if establishment type changed and clear controllers
              if (_previousEstablishmentTypeId != establishmentTypeId) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  cubit.clearControllers();
                  projectCubit.clearAllData(); // Clear city/area
                  setState(() {
                    _previousEstablishmentTypeId = establishmentTypeId;
                  });
                });
              }

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                child: Form(
                  key: cubit.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RegisterHeader(title: "مرحباً! سجّل الآن للبدء"),
                      SizedBox(height: height * 0.02),
                      Text(
                        "من فضلك قم بملء نموذج التسجيل بعناية للحصول على أفضل خدمة",
                        style: AppTextStyles.regularGrey15
                            .copyWith(fontSize: 16.sp),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(bottom: 20),
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              SizedBox(height: 16.h),
                              ..._buildFieldsBasedOnType(
                                context,
                                cubit,
                                projectCubit,
                                establishmentTypeId,
                              ),
                              SizedBox(height: 24.h),
                              CustomButton(
                                isLoading: state is CheckUserExistLoading,
                                title: 'التالي',
                                onPressed: () => cubit.submitWithValidation(context),
                                withShadow: false,
                              ),
                              SizedBox(height: height * 0.015),
                              customRichText(
                                unFocusedText: 'تمتلك حساب بالفعل؟ ',
                                focusedText: 'يمكنك تسجيل الدخول من هنا ',
                                onTap: () => Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (_, __, ___) => LoginScreen(),
                                    transitionDuration:
                                    const Duration(seconds: 1),
                                    transitionsBuilder: (_, a, __, c) =>
                                        FadeTransition(opacity: a, child: c),
                                  ),
                                ),
                              ),
                              SizedBox(height: height * 0.02),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFieldsBasedOnType(
      BuildContext context,
      RegisterCubit cubit,
      ProjectDataCubit projectCubit,
      int? establishmentTypeId,
      ) {
    final cities = projectCubit.settingsData?.cities ?? [];

    switch (establishmentTypeId) {
      case 1: // المدجنة
        return _buildPoultryFarmFields(cubit, projectCubit, cities);
      case 2: // المفقس
        return _buildHatcheryFields(cubit, projectCubit, cities);
      case 3: // مسلخ
        return _buildSlaughterhouseFields(cubit, projectCubit, cities);
      case 4: // معمل علف
        return _buildFeedFactoryFields(cubit, projectCubit, cities);
      case 5: // معمل كرتون البيض
        return _buildEggCartonFactoryFields(cubit, projectCubit, cities);
      default:
        return _buildPoultryFarmFields(cubit, projectCubit, cities);
    }
  }

  // المدجنة
  List<Widget> _buildPoultryFarmFields(
      RegisterCubit cubit,
      ProjectDataCubit projectCubit,
      List<GeneralItem> cities,
      ) {
    return [
      CustomTextField(
        label: 'اسم المستخدم',
        hint: "اسم المستخدم",
        controller: cubit.usernameController,
        validator: (val) => val!.isEmpty ? "أدخل اسم المستخدم" : null,
      ),
      CustomTextField(
        label: 'اسم المالك',
        margin: 6.h,
        hint: "اسم المالك",
        controller: cubit.ownerNameController,
        validator: (val) => val!.isEmpty ? "أدخل اسم المالك" : null,
      ),
      CustomTextField(
        label: 'اسم المستأجر (اختياري)',
        margin: 6.h,
        hint: "اسم المستأجر",
        controller: cubit.consultantNameController,
      ),
      _buildCityAndAreaFields(projectCubit, cities),
      CustomTextField(
        label: 'البريد الإلكتروني (اختياري)',
        margin: 16.h,
        hint: "البريد الإلكتروني",
        controller: cubit.emailController,
        inputType: TextInputType.emailAddress,
      ),
      CustomTextField(
        label: 'رقم الهاتف (اختياري)',
        margin: 0.h,
        hint: "رقم الهاتف",
        controller: cubit.phoneController,
        inputType: TextInputType.phone,
        // validator: (val) => val!.length < 8 ? "أدخل رقم هاتف صحيح" : null,
      ),
      CustomTextField(
        label: 'كلمة المرور',
        margin: 6.h,
        hint: "كلمة المرور",
        controller: cubit.passwordController,
        obscure: true,
        validator: (val) =>
        val!.length < 6 ? "كلمة المرور يجب أن تكون أطول من 6 أحرف" : null,
      ),
    ];
  }

  // المفقس
  List<Widget> _buildHatcheryFields(
      RegisterCubit cubit,
      ProjectDataCubit projectCubit,
      List<GeneralItem> cities,
      ) {
    return [
      CustomTextField(
        label: 'اسم المفقس',
        hint: "اسم المفقس",
        controller: cubit.establishmentNameController,
        validator: (val) => val!.isEmpty ? "أدخل اسم المفقس" : null,
      ),
      CustomTextField(
        label: 'اسم المستخدم',
        margin: 6.h,
        hint: "اسم المستخدم",
        controller: cubit.usernameController,
        validator: (val) => val!.isEmpty ? "أدخل اسم المستخدم" : null,
      ),
      CustomTextField(
        label: 'كلمة المرور',
        margin: 6.h,
        hint: "كلمة المرور",
        controller: cubit.passwordController,
        obscure: true,
        validator: (val) => val!.length < 6 ? "كلمة المرور قصيرة جداً" : null,
      ),
      CustomTextField(
        label: 'رقم الهاتف (اختياري)',
        margin: 6.h,
        hint: "رقم الهاتف",
        controller: cubit.phoneController,
        inputType: TextInputType.phone,
        // validator: (val) => val!.length < 8 ? "أدخل رقم هاتف صحيح" : null,
      ),
      CustomTextField(
        label: 'البريد الإلكتروني (اختياري)',
        margin: 6.h,
        hint: "البريد الإلكتروني",
        controller: cubit.emailController,
        inputType: TextInputType.emailAddress,
      ),
      _buildCityAndAreaFields(projectCubit, cities),
      CustomDropdown(
        label: "حالة العمل (اختياري)",
        hint: "يعمل أو لا يعمل",
        margin: 16.h,
        items: const ["يعمل", "لا يعمل"],
        value: cubit.operationalStatus,
        onChanged: (val) => cubit.setOperationalStatus(val),
      ),
      CustomTextField(
        label: 'عدد المكانات (اختياري)',
        margin: 16.h,
        hint: "عدد المكانات",
        controller: cubit.machinesCountController,
        inputType: TextInputType.number,
      ),
      CustomDropdown(
        label: "نوع المكنات (اختياري)",
        hint: "اختر نوع المكنات",
        margin: 0.h,
        items: const ["وطني", "باسرفورم", "فيكتوريا", "باترسايم"],
        value: cubit.machineType,
        onChanged: (val) => cubit.setMachineType(val),
      ),
      CustomTextField(
        label: 'معلومات أخرى (اختياري)',
        margin: 16.h,
        hint: "معلومات إضافية",
        controller: cubit.otherInfoController,
      ),
    ];
  }

  // مسلخ
  List<Widget> _buildSlaughterhouseFields(
      RegisterCubit cubit,
      ProjectDataCubit projectCubit,
      List<GeneralItem> cities,
      ) {
    return [
      CustomTextField(
        label: 'اسم المسلخ',
        hint: "اسم المسلخ",
        controller: cubit.establishmentNameController,
        validator: (val) => val!.isEmpty ? "أدخل اسم المسلخ" : null,
      ),
      CustomTextField(
        label: 'اسم المستخدم',
        margin: 6.h,
        hint: "اسم المستخدم",
        controller: cubit.usernameController,
        validator: (val) => val!.isEmpty ? "أدخل اسم المستخدم" : null,
      ),
      CustomTextField(
        label: 'كلمة المرور',
        margin: 6.h,
        hint: "كلمة المرور",
        controller: cubit.passwordController,
        obscure: true,
        validator: (val) => val!.length < 6 ? "كلمة المرور قصيرة جداً" : null,
      ),
      CustomTextField(
        label: 'رقم الهاتف (اختياري)',
        margin: 6.h,
        hint: "رقم الهاتف",
        controller: cubit.phoneController,
        inputType: TextInputType.phone,
        // validator: (val) => val!.length < 8 ? "أدخل رقم هاتف صحيح" : null,
      ),
      CustomTextField(
        label: 'البريد الإلكتروني (اختياري)',
        margin: 6.h,
        hint: "البريد الإلكتروني",
        controller: cubit.emailController,
        inputType: TextInputType.emailAddress,
      ),
      _buildCityAndAreaFields(projectCubit, cities),
      CustomTextField(
        label: 'عدد الأقفاص (اختياري)',
        margin: 16.h,
        hint: "عدد الأقفاص",
        controller: cubit.cagesCountController,
        inputType: TextInputType.number,
      ),
      CustomTextField(
        label: 'معلومات أخرى (اختياري)',
        margin: 6.h,
        hint: "معلومات إضافية",
        controller: cubit.otherInfoController,
      ),
    ];
  }

  // معمل علف
  List<Widget> _buildFeedFactoryFields(
      RegisterCubit cubit,
      ProjectDataCubit projectCubit,
      List<GeneralItem> cities,
      ) {
    return [
      CustomTextField(
        label: 'اسم المعمل',
        hint: "اسم المعمل",
        controller: cubit.establishmentNameController,
        validator: (val) => val!.isEmpty ? "أدخل اسم المعمل" : null,
      ),
      CustomTextField(
        label: 'اسم المستخدم',
        margin: 6.h,
        hint: "اسم المستخدم",
        controller: cubit.usernameController,
        validator: (val) => val!.isEmpty ? "أدخل اسم المستخدم" : null,
      ),
      CustomTextField(
        label: 'كلمة المرور',
        margin: 6.h,
        hint: "كلمة المرور",
        controller: cubit.passwordController,
        obscure: true,
        validator: (val) => val!.length < 6 ? "كلمة المرور قصيرة جداً" : null,
      ),
      CustomTextField(
        label: 'رقم الهاتف (اختياري)',
        margin: 6.h,
        hint: "رقم الهاتف",
        controller: cubit.phoneController,
        inputType: TextInputType.phone,
        // validator: (val) => val!.length < 8 ? "أدخل رقم هاتف صحيح" : null,
      ),
      CustomTextField(
        label: 'البريد الإلكتروني (اختياري)',
        margin: 6.h,
        hint: "البريد الإلكتروني",
        controller: cubit.emailController,
        inputType: TextInputType.emailAddress,
      ),
      _buildCityAndAreaFields(projectCubit, cities),
      CustomTextField(
        label: 'متوسط إنتاج علف البيض (اختياري)',
        margin: 16.h,
        hint: "متوسط الإنتاج",
        controller: cubit.eggFeedProductionController,
        inputType: TextInputType.number,
      ),
      CustomTextField(
        label: 'متوسط إنتاج علف الفروج (اختياري)',
        margin: 6.h,
        hint: "متوسط الإنتاج",
        controller: cubit.broilerFeedProductionController,
        inputType: TextInputType.number,
      ),
      CustomTextField(
        label: 'معلومات أخرى (اختياري)',
        margin: 6.h,
        hint: "معلومات إضافية",
        controller: cubit.otherInfoController,
      ),
    ];
  }

  // معمل كرتون البيض
  List<Widget> _buildEggCartonFactoryFields(
      RegisterCubit cubit,
      ProjectDataCubit projectCubit,
      List<GeneralItem> cities,
      ) {
    return [
      CustomTextField(
        label: 'اسم المعمل',
        hint: "اسم المعمل",
        controller: cubit.establishmentNameController,
        validator: (val) => val!.isEmpty ? "أدخل اسم المعمل" : null,
      ),
      CustomTextField(
        label: 'اسم المستخدم',
        margin: 6.h,
        hint: "اسم المستخدم",
        controller: cubit.usernameController,
        validator: (val) => val!.isEmpty ? "أدخل اسم المستخدم" : null,
      ),
      CustomTextField(
        label: 'كلمة المرور',
        margin: 6.h,
        hint: "كلمة المرور",
        controller: cubit.passwordController,
        obscure: true,
        validator: (val) => val!.length < 6 ? "كلمة المرور قصيرة جداً" : null,
      ),
      CustomTextField(
        label: 'رقم الهاتف (اختياري)',
        margin: 6.h,
        hint: "رقم الهاتف",
        controller: cubit.phoneController,
        inputType: TextInputType.phone,
        // validator: (val) => val!.length < 8 ? "أدخل رقم هاتف صحيح" : null,
      ),
      CustomTextField(
        label: 'البريد الإلكتروني (اختياري)',
        margin: 6.h,
        hint: "البريد الإلكتروني",
        controller: cubit.emailController,
        inputType: TextInputType.emailAddress,
      ),
      _buildCityAndAreaFields(projectCubit, cities),
      CustomTextField(
        label: 'متوسط عدد الربطات اليومي (اختياري)',
        margin: 16.h,
        hint: "عدد الربطات",
        controller: cubit.dailyBundlesController,
        inputType: TextInputType.number,
      ),
      CustomTextField(
        label: 'معلومات أخرى (اختياري)',
        margin: 6.h,
        hint: "معلومات إضافية",
        controller: cubit.otherInfoController,
      ),
    ];
  }

  Widget _buildCityAndAreaFields(
      ProjectDataCubit projectCubit, List<GeneralItem> cities) {
    return BlocBuilder<ProjectDataCubit, ProjectDataState>(
      builder: (context, state) {
        final areas = projectCubit.getAreasForSelectedCity();

        return Column(
          children: [
            // City Dropdown
            CustomDropdown(
              label: "المحافظة",
              hint: "اختر المحافظة",
              margin: 10.h,
              value: projectCubit.selectedCityId != null
                  ? cities
                  .firstWhere(
                    (city) => city.id == projectCubit.selectedCityId,
                orElse: () => GeneralItem(id: -1, name: ""),
              )
                  .name
                  : null,
              items: cities.map((c) => c.name).toList(),
              onChanged: (val) {
                final city = cities.firstWhere((c) => c.name == val);
                projectCubit.setCity(city.id);
              },
              validator: (val) =>
              val == null || val.isEmpty ? "اختر المحافظة" : null,
            ),

            // Area Dropdown (shows only if city is selected)
            if (projectCubit.selectedCityId != null)
              CustomDropdown(
                label: "المنطقة",
                hint: areas.isEmpty ? "لا توجد مناطق متاحة" : "اختر المنطقة",
                margin: 15.h,
                value: projectCubit.selectedAreaName,
                items: areas.map((a) => a.name).toList(),
                onChanged: (val) {
                  if (areas.isNotEmpty && val != null) {
                    final selectedArea = areas.firstWhere((a) => a.name == val);
                    projectCubit.setArea(val, selectedArea.id);

                    // Save both to cache
                    CacheHelper.saveData('area', val);
                    CacheHelper.saveData('area_id', selectedArea.id);
                    print("Area saved: $val (ID: ${selectedArea.id})");
                  }
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
}