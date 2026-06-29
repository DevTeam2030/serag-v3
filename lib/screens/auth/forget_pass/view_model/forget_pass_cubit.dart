import 'package:bloc/bloc.dart';

import 'forget_pass_repo.dart';
import 'forget_pass_state.dart';

class ForgetPasswordCubit extends Cubit<ForgetPasswordState> {
  final ForgetPasswordRepository _repository;

  ForgetPasswordCubit({ForgetPasswordRepository? repository})
      : _repository = repository ?? ForgetPasswordRepository(),
        super(ForgetPasswordInitial());

  Future<void> requestPasswordReset(String email) async {
    emit(ForgetPasswordLoading());
    try {
      final result = await _repository.requestPasswordReset(email);
      emit(ForgetPasswordSuccess(result['message']));
    } catch (e) {
      emit(ForgetPasswordFailure(e.toString()));
    }
  }
}