// view_model/section_request_cubit.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mine/screens/home/presentation/view_model/section_request_repo.dart';
import 'section_request_state.dart';

class SectionRequestCubit extends Cubit<SectionRequestState> {
  final SectionRequestRepository _repository = SectionRequestRepository();

  SectionRequestCubit() : super(SectionRequestInitial());

  static SectionRequestCubit of(BuildContext context) =>
      BlocProvider.of(context);

  final nameController = TextEditingController();
  String? selectedWorkingStatus; // "يعمل" or "لا يعمل"
  LatLng? selectedLocation;

  void setWorkingStatus(String? status) {
    selectedWorkingStatus = status;
    emit(SectionRequestInitial());
  }

  void setLocation(LatLng location) {
    selectedLocation = location;
    emit(SectionRequestInitial());
  }

  Future<void> submitRequest(int categoryId) async {
    if (nameController.text.isEmpty) {
      emit(SectionRequestError("الرجاء إدخال الاسم"));
      return;
    }

    if (selectedWorkingStatus == null) {
      emit(SectionRequestError("الرجاء اختيار حالة العمل"));
      return;
    }

    if (selectedLocation == null) {
      emit(SectionRequestError("الرجاء تحديد الموقع الجغرافي"));
      return;
    }

    emit(SectionRequestLoading());

    try {
      final response = await _repository.submitRequest(
        name: nameController.text,
        isWorking: selectedWorkingStatus == "يعمل",
        longitude: selectedLocation!.longitude.toString(),
        latitude: selectedLocation!.latitude.toString(),
        categoryId: categoryId,
      );

      emit(SectionRequestSuccess(response.message));

      // Clear fields after success
      nameController.clear();
      selectedWorkingStatus = null;
      selectedLocation = null;
    } catch (e) {
      emit(SectionRequestError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    nameController.dispose();
    return super.close();
  }
}