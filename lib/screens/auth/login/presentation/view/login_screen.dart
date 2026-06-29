import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mine/bottom_nav.dart';
import 'package:mine/constants/app_text_styles.dart';
import 'package:mine/screens/auth/forget_pass/view/forget_pass_screen.dart';
import 'package:mine/screens/auth/otp_screen/presentation/view/otp_screen.dart';
import 'package:mine/screens/auth/register/presentation/view/register_screen.dart';
import 'package:mine/screens/auth/register/presentation/view/register_type.dart';
import 'package:mine/screens/auth/register/presentation/view/widgets/register_header.dart';
import 'package:mine/screens/prices/presentation/view/prices_screen.dart';
import 'package:mine/widgets/custom_richtext.dart';
import 'package:toastification/toastification.dart';
import '../../../../../constants/app_colors.dart';
import '../../../../../widgets/custom_button.dart';
import '../../../../../widgets/custom_textfield.dart';
import '../../../register/presentation/view_model/register_cubit.dart';
import '../view_model/login_cubit.dart';
import '../view_model/login_state.dart';

class LoginScreen extends StatelessWidget {
   LoginScreen({super.key});



   final formKey = GlobalKey<FormState>();
   final TextEditingController emailController = TextEditingController();
   final TextEditingController userNameController = TextEditingController();

   final TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.white,
        body: Form(
          key: formKey,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: SingleChildScrollView(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height*.9,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 30.h),
                      Text('مرحبا بك في تطبيق \n سراج',
                          style: AppTextStyles.boldBlack12
                              .copyWith(fontSize: 31.sp),
                          textAlign: TextAlign.start),
                      // RegisterHeader(title: 'أهلاً بعودتك! يسعدنا بدخولك مجدداً!'),
                      SizedBox(height: 30.h),
                
                      /// Email field
                      // CustomTextField(
                      //   label: 'البريد الإلكتروني',
                      //   controller: emailController,
                      //   hint: "البريد الإلكتروني",
                      //   inputType: TextInputType.emailAddress,
                      //   validator: (val) =>
                      //   val!.isEmpty ? "ادخل بريد الكتروني" : null,
                      // ),
                      CustomTextField(
                        label: 'اسم المستخدم',
                        controller: userNameController,
                        hint: "اسم المستخدم",
                        inputType: TextInputType.name,
                        validator: (val) =>
                        val!.isEmpty ? "ادخل اسم المستخدم" : null,
                      ),
                      SizedBox(height: 16.h),
                
                      /// Password field
                      CustomTextField(
                        label: 'كلمة المرور',
                        controller: passwordController,
                        hint: "كلمة المرور",
                        obscure: true,
                        inputType: TextInputType.visiblePassword,
                          readOnly: false,
                        onTap: () {},
                        margin: 0,
                        suffixIcon: SizedBox(),
                
                        validator: (val) =>
                        val!.isEmpty ? "ادخل كلمه المرور" : null,
                      ),
                      SizedBox(height: 16.h),
                
                      /// Forget password
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) => BlocProvider.value(
                                value: context.read<RegisterCubit>(),
                                child: const ForgetPasswordScreen(),
                              ),
                              transitionsBuilder: (_, a, __, c) =>
                                  FadeTransition(opacity: a, child: c),
                            ),
                          );
                        },
                        child: Text(
                          'هل نسيت كلمة المرور؟',
                          style: AppTextStyles.boldWhite12
                              .copyWith(color: AppColors.green),
                        ),
                      ),
                      SizedBox(height: 24.h),
                
                      /// Login button
                      BlocConsumer<LoginCubit, LoginState>(
                        listener: (context, state) {
                          if (state is LoginFailure) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(state.message)),
                            );
                
                            if (state.message.contains("لم تقم بالتحقق من حسابك")) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => OtpScreen(
                                    email: emailController.text.trim(),
                                  ),
                                ),
                              );
                            }
                          }
                
                          if (state is LoginSuccess) {
                            toastification.show(
                              context: context,
                              type: ToastificationType.success,
                              backgroundColor: AppColors.green,
                              title: Text(
                                "تم تسجيل الدخول بنجاح!",
                                style: AppTextStyles.semiboldBlack12
                                    .copyWith(color: Colors.white),
                              ),
                              autoCloseDuration: const Duration(seconds: 2),
                            );
                
                            Navigator.pushAndRemoveUntil(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) => const BottomNav(),
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
                            title: state is LoginLoading
                                ? "جارٍ تسجيل الدخول..."
                                : "تسجيل دخول",
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                context.read<LoginCubit>().login(
                                  userNameController.text.trim(),
                                  passwordController.text,
                                );
                              }
                            },
                          );
                        },
                      ),
                
                      SizedBox(height: 20.h),


                      Center(child: GestureDetector(
                          // onTap: () {
                          //
                          //   Navigator.pushAndRemoveUntil(
                          //
                          //     context,
                          //
                          //     MaterialPageRoute(
                          //
                          //       builder: (_)=>BottomNav(
                          //         isGuest: true,
                          //       ),
                          //
                          //     ),
                          //
                          //         (route)=>false,
                          //
                          //   );
                          //
                          // },
                          onTap: () {

                            Navigator.push(

                              context,

                              MaterialPageRoute(

                                builder: (_)=>PricesScreen(
                                ),

                              ),


                            );

                          },

                          child: Text("الدخول كـ زائر", style: AppTextStyles.boldBlack12.copyWith(fontSize: 16.sp), textAlign: TextAlign.center))),
                      SizedBox(height: 20.h),
                      /// Register link
                      Center(
                        child: customRichText(
                          unFocusedText: "لا تملك حساب ؟ ",
                          focusedText: "سجل حساب جديد",
                          onTap: () => Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) => BlocProvider.value(
                                value: context.read<RegisterCubit>(),
                                child: const EstablishmentTypeScreen(),
                              ),
                              transitionsBuilder: (_, a, __, c) =>
                                  FadeTransition(opacity: a, child: c),
                            ),
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
      ),
    );
  }
}

//
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:mine/bottom_nav.dart';
// import 'package:toastification/toastification.dart';
//
// import '../../../../../constants/app_colors.dart';
// import '../../../../../constants/app_text_styles.dart';
// import '../../../../../widgets/custom_textfield.dart';
// import '../../../forget_pass/view/forget_pass_screen.dart';
// import '../../../register/presentation/view_model/register_cubit.dart';
// import '../view_model/login_cubit.dart';
// import '../view_model/login_state.dart';
//
// class LoginScreen extends StatelessWidget {
//   LoginScreen({super.key});
//
//   final formKey = GlobalKey<FormState>();
//   @override
//   Widget build(BuildContext context) {
//     final emailController = TextEditingController();
//     final passwordController = TextEditingController();
//
//     return Directionality(
//         textDirection: TextDirection.rtl,
//         child: Scaffold(
//           backgroundColor: Colors.white,
//           body: BlocConsumer<LoginCubit, LoginState>(
//             listener: (context, state) {
//               if (state is LoginSuccess) {
//                 toastification.show(
//                   context: context,
//                   type: ToastificationType.success,
//                   backgroundColor: Colors.green,
//                   title: Text(
//                     'أهلاً ',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                   autoCloseDuration: const Duration(seconds: 3),
//                 );
//                 // showToast(context: context, message:'أهلاً ${state..name}', state:ToastStates.success,);
//
//                 Navigator.push(
//                   context,
//                   PageRouteBuilder(
//                       pageBuilder: (_, __, ___) => const BottomNav()),
//                 );
//               } else if (state is LoginFailure) {
//                 // showToast(context: context, message:state.message.replaceAll('Exception:', ''), state:ToastStates.error,);
//                 toastification.show(
//                   context: context,
//                   type: ToastificationType.error,
//                   backgroundColor: Colors.red,
//                   title: Text(
//                     state.message.replaceAll('Exception:', ''),
//                     style: TextStyle(color: Colors.white),
//                   ),
//                   autoCloseDuration: const Duration(seconds: 3),
//                 );
//               }
//             },
//             builder: (context, state) {
//               return Form(
//                 key: formKey,
//                 child: SafeArea(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 24.0),
//                     child: SingleChildScrollView(
//                       child: SizedBox(
//                         height: MediaQuery.of(context).size.height * .95,
//                         child: Column(
//
//                           children: [
//                             const SizedBox(height: 32),
//                             Image.asset('assets/logo.png', height: 120.h),
//                             Text(
//                               "مرحبا بك في تطبيق \n Serag",
//                               style: AppTextStyles.boldBlack12.copyWith(
//                                 fontSize: 31.sp,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                             SizedBox(height: 8.h),
//                             Text(
//                               "الرجاء إدخال اسم المستخدم وكلمة المرور التي استلمتها من الإدارة",
//                               style: AppTextStyles.semiboldBlack12,
//                               textAlign: TextAlign.start,
//                             ),
//                             const SizedBox(height: 32),
//                             CustomTextField(
//                               controller: emailController,
//                               hint: "البريد الإلكتروني",
//                               validator: (val) => val!.isEmpty
//                                   ? "أدخل البريد الإلكتروني"
//                                   : null,
//                             ),
//                             const SizedBox(height: 16),
//                             CustomTextField(
//                               controller: passwordController,
//                               hint: "كلمة المرور",
//                               validator: (val) =>
//                                   val!.isEmpty ? "أدخل كلمه المرور" : null,
//                             ),
//                             const SizedBox(height: 16),
//
//                             Align(
//                               alignment: AlignmentDirectional.centerStart,
//                               child: GestureDetector(
//                                 onTap: () {
//                                   Navigator.push(
//                                     context,
//                                     PageRouteBuilder(
//                                       pageBuilder: (_, __, ___) =>
//                                           BlocProvider.value(
//                                         value: context.read<RegisterCubit>(),
//                                         child: const ForgetPasswordScreen(),
//                                       ),
//                                       transitionsBuilder: (_, a, __, c) =>
//                                           FadeTransition(opacity: a, child: c),
//                                     ),
//                                   );
//                                 },
//                                 child: Text(
//                                   'هل نسيت كلمة المرور؟',
//                                   style: AppTextStyles.boldWhite12
//                                       .copyWith(color: AppColors.green),
//                                 ),
//                               ),
//                             ),
//
//                             const Spacer(),
//                             SizedBox(
//                               width: double.infinity,
//                               child: ElevatedButton(
//                                 onPressed: () {
//                                   if (formKey.currentState!.validate()) {
//                                     BlocProvider.of<LoginCubit>(context).login(
//                                       emailController.text,
//                                       passwordController.text,
//                                     );
//                                   }
//                                 },
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: AppColors.green,
//                                   padding: const EdgeInsets.symmetric(
//                                     vertical: 16,
//                                     horizontal: 24,
//                                   ),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                 ),
//                                 child: state is LoginLoading
//                                     ? const SpinKitWanderingCubes(
//                                         color: Colors.white,
//                                         size: 20,
//                                       )
//                                     : Text(
//                                         "تسجيل دخول",
//                                         style:
//                                             AppTextStyles.boldWhite16.copyWith(
//                                           fontSize: 18.sp,
//                                         ),
//                                       ),
//                               ),
//                             ),
//                             const SizedBox(height: 24), // مسافة صغيرة من أسفل
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ));
//   }
// }
