import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mine/screens/auth/login/presentation/view/login_screen.dart';
import 'package:mine/screens/auth/register/presentation/view/widgets/register_header.dart';
import 'package:mine/screens/auth/register/presentation/view_model/register_cubit.dart';
import 'package:toastification/toastification.dart';
import '../../../../../constants/app_colors.dart';
import '../../../../../constants/app_text_styles.dart';
import '../../../../../widgets/custom_button.dart';
import '../../../../../widgets/custom_richtext.dart';
import '../../../register/presentation/view_model/register_state.dart';
import '../view_model/otp_cubit.dart';
import '../view_model/otp_repositery.dart';
import '../view_model/otp_states.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({
    super.key,
    this.email,
    this.signUpData, // All signup data passed here
  });

  final String? email;
  final Map<String, dynamic>? signUpData;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OtpCubit(
        repository: OtpRepository(),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocListener<RegisterCubit, RegisterState>(
          listener: (context, state) {
            if (state is RegisterSuccess) {
              // Show success message
              toastification.show(
                context: context,
                title: Text(
                  "تم التسجيل بنجاح",
                  style: AppTextStyles.boldWhite12,
                ),
                autoCloseDuration: const Duration(seconds: 2),
                backgroundColor: AppColors.green,
              );

              // Navigate to login screen
              Navigator.pushAndRemoveUntil(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => LoginScreen(),
                  transitionDuration: const Duration(seconds: 1),
                  transitionsBuilder: (_, a, __, c) =>
                      FadeTransition(opacity: a, child: c),
                ),
                    (route) => false, // Remove all previous routes
              );
            } else if (state is RegisterError) {
              // Show error message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('فشل التسجيل: ${state.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: Scaffold(
            backgroundColor: AppColors.white,
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomHeader(
                      title: 'كود التحقق',
                      hasAnotherBack: true,
                    ),
                    SizedBox(height: 32.h),
                    Text(
                      "ادخل رمز التحقق الذي استلمته من الإداره",
                      style: AppTextStyles.regularGrey15.copyWith(fontSize: 16.sp),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 15.h),

                    /// Single OTP TextField - Accepts any input (letters, numbers, symbols)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: TextField(
                        cursorColor: Colors.black,
                        controller: _otpController,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 12,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: '',
                          hintStyle: TextStyle(
                            fontSize: 28.sp,
                            letterSpacing: 12,
                            color: Colors.grey[300],
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.green,
                              width: 2.w,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.green,
                              width: 2.5.w,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 15.h,
                            horizontal: 16.w,
                          ),
                        ),
                        keyboardType: TextInputType.text, // Accept any input
                        autofocus: true,
                        onChanged: (value) {
                          setState(() {}); // Rebuild to update button state
                        },
                      ),
                    ),
                    SizedBox(height: 32.h),

                    BlocConsumer<OtpCubit, OtpState>(
                      listener: (context, state) {
                        if (state is OtpFailure) {
                          print(state.message);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                state.message.replaceAll('Exception:', ''),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else if (state is OtpSuccess) {
                          // ✅ OTP verified successfully - now trigger signup with area ID
                          if (widget.signUpData != null) {
                            final data = widget.signUpData!;
                            context.read<RegisterCubit>().signUp(
                              context: context,
                              establishmentTypeId: data['establishmentTypeId'],
                              buildingTypeId: data['buildingTypeId'],
                              technicalConditionId: data['technicalConditionId'],
                              heatingSystemId: data['heatingSystemId'],
                              waterSourceId: data['waterSourceId'],
                              powerSourceId: data['powerSourceId'],
                              supervisingDoctor: data['supervisingDoctor'],
                              licenseNumber: data['licenseNumber'],
                              licenseDate: data['licenseDate'],
                              buildingArea: data['buildingArea'], // ✅ Building area
                              numberFloors: data['numberFloors'],
                              latitude: data['latitude'],
                              longitude: data['longitude'],
                              establishmentDate: data['establishmentDate'],
                              cityId: data['cityId'],
                              userArea: data['userArea'], // ✅ Area name
                              areaId: data['areaId'], // ✅ Area ID
                            );
                          }
                        }
                      },
                      builder: (context, state) {
                        final isOtpLoading = state is OtpLoading;
                        final isRegisterLoading =
                        context.watch<RegisterCubit>().state is RegisterLoading;
                        final isLoading = isOtpLoading || isRegisterLoading;

                        return CustomButton(
                          width: 330.w,
                          title: isOtpLoading
                              ? "جار التحقق..."
                              : isRegisterLoading
                              ? "جار التسجيل..."
                              : "تحقق",
                          onPressed: () {
                            final nameToUse = widget.email ??
                                context
                                    .read<RegisterCubit>()
                                    .usernameController
                                    .text
                                    .trim();

                            context.read<OtpCubit>().activateAccount(
                              username: nameToUse,
                              code: _otpController.text,
                              context: context,
                            );
                          },
                          withShadow: false,
                        );
                      },
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
    _otpController.dispose();
    super.dispose();
  }
}