import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mine/screens/auth/login/presentation/view/login_screen.dart';
import 'package:mine/screens/auth/register/presentation/view/register_screen.dart';
import 'package:toastification/toastification.dart';
import 'package:mine/constants/app_colors.dart';
import 'package:mine/constants/app_text_styles.dart';
import 'package:mine/widgets/custom_button.dart';
import 'package:mine/widgets/custom_textfield.dart';
import 'package:mine/screens/auth/register/presentation/view/widgets/register_header.dart';

import '../../../../widgets/custom_richtext.dart';
import '../../register/presentation/view_model/register_cubit.dart';
import '../view_model/forget_pass_cubit.dart';
import '../view_model/forget_pass_repo.dart';
import '../view_model/forget_pass_state.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ForgetPasswordCubit(repository: ForgetPasswordRepository()),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppColors.white,
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     RegisterHeader(
                        title: 'نسيت كلمة المرور؟ لا تقلق، نحن هنا للمساعدة!'),
                    SizedBox(height: 30.h),
                    CustomTextField(
                      label: 'البريد الإلكتروني',
                      controller: emailController,
                      hint: "البريد الإلكتروني",
                      validator: (val) =>
                      val!.isEmpty ? "ادخل بريد الكتروني" : null,
                    ),
                    SizedBox(height: 24.h),
                    BlocConsumer<ForgetPasswordCubit, ForgetPasswordState>(
                      listener: (context, state) {
                        if (state is ForgetPasswordFailure) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(state.message)),
                          );
                        }
                        if (state is ForgetPasswordSuccess) {
                          toastification.show(
                            context: context,
                            type: ToastificationType.success,
                            backgroundColor: AppColors.green,
                            title: Text(
                              state.message,
                              style: AppTextStyles.semiboldBlack12
                                  .copyWith(color: Colors.white),
                            ),
                            autoCloseDuration: const Duration(seconds: 2),
                          );
                          Navigator.pushAndRemoveUntil(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) =>  LoginScreen(),
                              transitionDuration: const Duration(seconds: 1),
                              transitionsBuilder: (_, a, __, c) =>
                                  FadeTransition(opacity: a, child: c),
                            ),
                                (route) => false,
                          );
                        }
                      },
                      builder: (context, state) {
                        return CustomButton(
                          withShadow: false,
                          title: state is ForgetPasswordLoading
                              ? "جارٍ إرسال رابط إعادة تعيين كلمة المرور..."
                              : "إرسال رابط إعادة تعيين كلمة المرور",
                          style: AppTextStyles.boldWhite16,
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              context
                                  .read<ForgetPasswordCubit>()
                                  .requestPasswordReset(
                                  emailController.text.trim());
                            }
                          },
                        );
                      },
                    ),
                    const Spacer(),
                    customRichText(
                      unFocusedText: "لا تملك حساب؟ ",
                      focusedText: "سجل حساب جديد",
                      onTap: () => Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => BlocProvider.value(
                            value: context.read<RegisterCubit>(),
                            child: const RegisterScreen(),
                          ),
                          transitionDuration: const Duration(seconds: 1),
                          transitionsBuilder: (_, a, __, c) =>
                              FadeTransition(opacity: a, child: c),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}