import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/helper/cache_helper.dart';
import 'auth_repo.dart';
import 'change_pass_state.dart';


class ChangePassCubit extends Cubit<ChangePassState> {
  final AuthRepository repository;

  ChangePassCubit(this.repository) : super(ChangePassInitial());

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    emit(ChangePassLoading());
    try {
      final result = await repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      if (result['status'] == 200) {
        // حفظ الباسورد الجديد
        CacheHelper.saveData( 'user_password', newPassword);

        emit(ChangePassSuccess(result['message'] ?? "تم تغيير كلمة المرور"));
      } else {
        emit(ChangePassError(result['message'] ?? "حدث خطأ"));
      }
    } catch (e) {
      emit(ChangePassError(e.toString()));
    }
  }

}
