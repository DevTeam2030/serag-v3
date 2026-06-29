import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/helper/cache_helper.dart';
import 'auth_repo.dart';
import 'delete_account_state.dart';

class DeleteAccountCubit extends Cubit<DeleteAccountState> {
  final AuthRepository repository;

  DeleteAccountCubit(this.repository) : super(DeleteAccountInitial());

  Future<void> deleteAccount() async {
    emit(DeleteAccountLoading());
    try {
      final result = await repository.deleteAccount();

      if (result['status'] == 200) {
        // نحذف الـ token والبيانات
        CacheHelper.clearData();
        emit(DeleteAccountSuccess(result['message'] ?? "تم حذف الحساب بنجاح"));
      } else {
        emit(DeleteAccountError(result['message'] ?? "فشل حذف الحساب"));
      }
    } catch (e) {
      emit(DeleteAccountError(e.toString()));
    }
  }
  Future<void> logout() async {
    emit(DeleteAccountLoading());
    try {
      final result = await repository.logout();

      if (result['message'] == 'Successfully logged out') {
        CacheHelper.clearData();
        CacheHelper.removeToken();
        CacheHelper.saveData('hasSeenOnboarding', true);
        emit(logoutSuccess(result['message'] ?? "تم تسجيل الخروج بنجاح"));
      } else {
        emit(logoutError(result['message'] ?? "فشل تسجيل الخروج"));
      }
    } catch (e) {
      emit(logoutError(e.toString()));
    }
  }
}
