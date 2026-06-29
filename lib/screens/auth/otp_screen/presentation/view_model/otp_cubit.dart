import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'otp_repositery.dart';
import 'otp_states.dart';

class OtpCubit extends Cubit<OtpState> {
  final OtpRepository repository;

  // Remove otpLength requirement - accept any length
  OtpCubit({required this.repository}) : super(OtpInitial());

  Future<void> verifyOtp(String otp) async {
    // Remove length check - accept any non-empty string
    if (otp.isEmpty) {
      emit(OtpFailure("رمز التحقق غير مكتمل"));
      return;
    }

    emit(OtpLoading());
    try {
      final success = await repository.verifyOtp(otp);
      if (success) {
        emit(OtpSuccess());
      } else {
        emit(OtpFailure("رمز التحقق غير صحيح"));
      }
    } catch (e) {
      emit(OtpFailure(e.toString()));
    }
  }

  Future<void> activateAccount({
    required String username,
    required String code,
    required BuildContext context,
  }) async {
    // Remove length check - accept any non-empty string
    if (code.isEmpty) {
      emit(OtpFailure("الرجاء إدخال رمز التحقق"));
      return;
    }

    emit(OtpLoading());
    try {
      await repository.activateAccount(
        email: username,
        verificationCode: code,
        context: context,
      );
      emit(OtpSuccess());
    } catch (e) {
      print('❌ OtpCubit Error: $e');
      emit(OtpFailure(e.toString().replaceAll('Exception:', '').trim()));
    }
  }
}