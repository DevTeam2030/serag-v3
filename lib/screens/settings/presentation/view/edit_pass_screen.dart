import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mine/constants/app_colors.dart';
import 'package:mine/constants/app_text_styles.dart';
import 'package:mine/core/helper/cache_helper.dart';
import 'package:toastification/toastification.dart';
// import 'package:toastification/toastification.dart';

import '../../../../widgets/custom_button.dart';
import '../../../../widgets/custom_textfield.dart';
import '../../../auth/register/presentation/view/widgets/register_header.dart';
import '../view_model/auth_repo.dart';
import '../view_model/auth_services.dart';
import '../view_model/change_pass_cubit.dart';
import '../view_model/change_pass_state.dart';

class EditPassScreen extends StatelessWidget {
  EditPassScreen({super.key});

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();


  final currentPassCtrl = TextEditingController(text: CacheHelper.getData('user_password'));
  final newPassCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChangePassCubit(AuthRepository(AuthService())),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Form(
          key: formKey,
          child: Scaffold(
            backgroundColor: Colors.white,
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  SizedBox(height: 30.h),
                  CustomHeader(title: 'تغيير كلمه المرور'),
                  SizedBox(height: 20.h),
                  CustomTextField(
                    hint: "كلمة المرور القديمة ",
                    controller: currentPassCtrl,
                    label: 'كلمة المرور القديمة ',
                    validator: (val) => val!.isEmpty ? "ادخل كلمة المرور القديمة " : null,
                  ),
                  CustomTextField(
                    margin: 15.h,
                    hint: "كلمة المرور الجديدة",
                    controller: newPassCtrl,
                    label: 'كلمة المرور الجديدة',
                    validator: (val) => val!.isEmpty ? "ادخل كلمة المرور الجديدة" : null,
                  ),
                  CustomTextField(
                    margin: 15.h,
                    hint: "تأكيد كلمة المرور الجديدة",
                    controller: confirmPassCtrl,
                    label: 'تأكيد كلمة المرور الجديدة',
                    validator: (val) => val!.isEmpty ? "ادخل كلمة المرور الجديدة" : null,
                  ),
                  Spacer(),
                  BlocConsumer<ChangePassCubit, ChangePassState>(
                    listener: (context, state) {
                      if (state is ChangePassSuccess) {
                        toastification.show(
                          context: context,
                          backgroundColor: AppColors.green,
                          type: ToastificationType.success,
                          title: Text(state.message, style: AppTextStyles.boldWhite16),
                          primaryColor: Colors.green,
                          autoCloseDuration: const Duration(seconds: 2),
                        );
                      } else if (state is ChangePassError) {
                        toastification.show(
                          context: context,
                          backgroundColor: Colors.red,
                          type: ToastificationType.error,
                          title: Text(state.error, style: AppTextStyles.boldWhite16),
                          primaryColor: Colors.red,
                          autoCloseDuration: const Duration(seconds: 2),
                        );
                      }
                    },
                    builder: (context, state) {

                      return CustomButton(
                        isLoading: state is ChangePassLoading,
                        title: 'حفظ التغييرات',
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            context.read<ChangePassCubit>().changePassword(
                              currentPassword: currentPassCtrl.text,
                              newPassword: newPassCtrl.text,
                              confirmPassword: confirmPassCtrl.text,
                            );
                          }
                        },
                      );
                    },
                  ),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
