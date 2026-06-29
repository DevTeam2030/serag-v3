import 'package:flutter_bloc/flutter_bloc.dart';
import 'login_repo.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginRepository repository;

  LoginCubit({required this.repository}) : super(LoginInitial());

  Future<void> login(String email, String password) async {
    // if (email.isEmpty || !email.contains("@")) {
    //   emit(const LoginFailure("الرجاء إدخال بريد إلكتروني صحيح"));
    //   return;
    // }
    // if (password.isEmpty || password.length < 6) {
    //   emit(const LoginFailure("كلمة المرور يجب أن تكون 6 أحرف على الأقل"));
    //   return;
    // }

    emit(LoginLoading());
    try {
      await repository.login(email, password);
      emit(LoginSuccess());
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }
}