import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mine/screens/home/presentation/view_model/service_details_form_repositery.dart';
import '../../../../constants/app_colors.dart';
import 'service_details_form_state.dart';
import 'package:intl/intl.dart'; // for date formatting

enum ServiceType { farouj, omhat, beid, jdad }

class ServiceDetailsFormCubit extends Cubit<ServiceDetailsFormState> {
  final ServiceDetailsFormRepository repository;

  ServiceDetailsFormCubit({required this.repository})
      : super(ServiceDetailsFormInitial());

  final formKey = GlobalKey<FormState>();

  /// Each type of service has its own set of controllers
  final Map<ServiceType, Map<String, TextEditingController>> _controllers = {
    ServiceType.farouj: _buildControllers(),
    ServiceType.beid: _buildControllers(),
    ServiceType.omhat: _buildControllers(),
    ServiceType.jdad: _buildControllers(),
  };

  /// Dropdown selections per service type
  final Map<ServiceType, Map<String, String?>> _dropdownValues = {
    ServiceType.farouj: _buildDropdownValues(),
    ServiceType.beid: _buildDropdownValues(),
    ServiceType.omhat: _buildDropdownValues(),
    ServiceType.jdad: _buildDropdownValues(),
  };

  /// Demo dropdown items
  final List<String> distributionChannelItems = ['ريش', 'مدبح', 'سوق محلي', 'تصدير'];
  final List<String> diseaseTypeItems = ['نوع أ', 'نوع ب', 'نوع ج'];
  final List<String> vaccinationProgramItems = ['برنامج 1', 'برنامج 2', 'برنامج 3'];

  static Map<String, TextEditingController> _buildControllers() => {
    "source": TextEditingController(),
    "quantity": TextEditingController(),
    "startDate": TextEditingController(),
    "endDate": TextEditingController(),
    "feedSource": TextEditingController(),
    "feedAmount": TextEditingController(),
    "mortalityCount": TextEditingController(),
    "conversionRate": TextEditingController(),
    "deadBirdsCount": TextEditingController(),
    "chicksCount": TextEditingController(),
  };

  static Map<String, String?> _buildDropdownValues() => {
    "distributionChannel": null,
    "diseaseType": null,
    "vaccinationProgram": null,
  };

  /// Get controllers for current service type
  Map<String, TextEditingController> controllers(ServiceType type) =>
      _controllers[type]!;

  /// Get dropdown value for current service type
  String? dropdownValue(ServiceType type, String key) =>
      _dropdownValues[type]![key];

  /// Set dropdown value for current service type
  void setDropdownValue(ServiceType type, String key, String? value) {
    _dropdownValues[type]![key] = value;
    emit(ServiceDetailsFormInitial());
  }

  /// Pick a date and set it to controller
  Future<void> pickDate(BuildContext context, ServiceType type, String fieldKey) async {
    final picked = await showDatePicker(

      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.green, // ✅ header & selected date color
              onPrimary: Colors.white,  // ✅ text color on primary
              onSurface: Colors.black,  // ✅ default text color
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controllers(type)[fieldKey]!.text =
      "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      emit(ServiceDetailsFormInitial());
    }
  }

  bool _validateForm(ServiceType type) {
    if (!formKey.currentState!.validate()) return false;
    if (_dropdownValues[type]!.values.any((v) => v == null)) return false;
    return true;
  }

  Future<void> submitForm(ServiceType type) async {
    if (!_validateForm(type)) {
      emit(ServiceDetailsFormFailure("الرجاء ملء كل الحقول المطلوبة"));
      return;
    }

    emit(ServiceDetailsFormSubmitting());
    try {
      final payload = {
        ...controllers(type).map((k, v) => MapEntry(k, v.text.trim())),
        ..._dropdownValues[type]!,
        "birdCategory": type.name, // save type name
      };

      await repository.submitDetails(payload);
      emit(ServiceDetailsFormSuccess());
    } catch (e) {
      emit(ServiceDetailsFormFailure(e.toString()));
    }
  }

  @override
  Future<void> close() {
    for (var ctrlMap in _controllers.values) {
      for (var c in ctrlMap.values) {
        c.dispose();
      }
    }
    return super.close();
  }
}
