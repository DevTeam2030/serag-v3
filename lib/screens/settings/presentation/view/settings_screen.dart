import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mine/constants/app_colors.dart';
import 'package:mine/constants/app_text_styles.dart';
import 'package:mine/core/helper/cache_helper.dart';
import 'package:mine/screens/auth/login/presentation/view/login_screen.dart';
import 'package:mine/screens/auth/register/presentation/view/widgets/register_header.dart';
import 'package:mine/screens/projects/presentation/view/project_screen.dart';
import 'package:mine/screens/settings/presentation/view/edit_pass_screen.dart';
import 'package:mine/screens/settings/presentation/view/terms_conditions.dart';
import 'package:mine/widgets/back_button.dart';
import 'package:mine/widgets/custom_appbar.dart';
import 'package:toastification/toastification.dart';

import '../../../../constants/app_constants.dart';
import '../../../../widgets/custom_button.dart';
import '../view_model/auth_repo.dart';
import '../view_model/auth_services.dart';
import '../view_model/delete_account_cubit.dart';
import '../view_model/delete_account_state.dart';
import 'edit_profile_screen.dart';
import 'notification_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        // appBar: AppBar(
        //   backgroundColor: Colors.white,
        //   actions: [
        //     Padding(
        //       padding: EdgeInsets.symmetric(horizontal: 16.w),
        //       child: BkBtn(),
        //     )
        //   ],
        //   centerTitle: true,
        //   title: Text(
        //     'القائمه',
        //     style: AppTextStyles.boldBlack30,
        //   ),
        // ),
        body: Column(
          children: [
            SizedBox(height: 30.h),
            CustomHeader(title: 'القائمة'),
            SizedBox(height: 10.h),
            _buildMenuItem('assets/menu (1) 16.png', "تعديل البيانات", 500,
                onTap: () {
              Navigator.push(
                  context,
                  PageRouteBuilder(
                      pageBuilder: (_, __, ___) => EditProfileScreen()));
            }),
            _buildMenuItem('assets/menu_notification.png', "الإشعارات", 600,
                onTap: () {
              Navigator.push(
                  context,
                  PageRouteBuilder(
                      pageBuilder: (_, __, ___) => NotificationScreen()));
            }),
            AppConstants().isPoultryFarm ?
            _buildMenuItem('assets/list.svg', "الأفواج", 700, onTap: () {
              Navigator.push(
                  context,
                  PageRouteBuilder(
                      pageBuilder: (_, __, ___) => ProjectsScreen(showBack: true,)));
            }):SizedBox(),
            _buildMenuItem(
                'assets/text-indent-left.svg', "الشروط والأحكام", 800,
                onTap: () {
              Navigator.push(
                  context,
                  PageRouteBuilder(
                      pageBuilder: (_, __, ___) => TermsConditions()));
            }),
            _buildMenuItem('assets/pass.svg', "تغيير كلمة المرور", 900,
                onTap: () {
              Navigator.push(
                  context,
                  PageRouteBuilder(
                      pageBuilder: (_, __, ___) => EditPassScreen()));
            }),
            _buildMenuItem('assets/bucket.svg', "حذف الحساب", 1000, onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return BlocProvider(
                    create: (_) => DeleteAccountCubit(AuthRepository(AuthService())),
                    child: Dialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        height: 256.h,
                        width: 346.w,
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/logout.png',
                              width: 83.w,
                              height: 83.h,
                            ),
                            SizedBox(height: 25.h),
                            Text(
                              'هل تريد حذف الحساب ؟',
                              style: AppTextStyles.semiboldBlack12.copyWith(fontSize: 16.sp),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 25.h),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomButton(
                                    backgroundColor: Colors.transparent,
                                    withBorder: true,
                                    withShadow: false,
                                    height: 40.h,
                                    style: AppTextStyles.boldWhite16.copyWith(
                                      color: AppColors.green,
                                    ),
                                    title: 'الغاء',
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: BlocConsumer<DeleteAccountCubit, DeleteAccountState>(
                                    listener: (context, state) {
                                      if (state is DeleteAccountSuccess) {
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (_, __, ___) =>  LoginScreen(),
                                          ),
                                              (route) => false,
                                        );
                                      } else if (state is DeleteAccountError) {
                                        toastification.show(
                                          context: context,
                                          type: ToastificationType.error,
                                          title: Text(state.error),
                                          primaryColor: Colors.red,
                                          backgroundColor: Colors.red,
                                          autoCloseDuration: const Duration(seconds: 2),
                                        );
                                      }
                                    },
                                    builder: (context, state) {
                                      return CustomButton(
                                        withShadow: false,
                                        isLoading: state is DeleteAccountLoading,
                                        height: 40.h,
                                        style: AppTextStyles.boldWhite16,
                                        title: 'حذف',
                                        onPressed: () {
                                          context.read<DeleteAccountCubit>().deleteAccount();
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          CacheHelper.getToken()==""?
          _buildMenuItem('assets/lock-fill.svg', "تسجيل خروج", 1100, isLogout: true,onTap: (){
            Navigator.push(context, PageRouteBuilder(pageBuilder: (_, __, ___) =>  LoginScreen()));
          }):
            _buildMenuItem('assets/lock-fill.svg', "تسجيل خروج", 1100, isLogout: true, onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return BlocProvider(
                    create: (_) => DeleteAccountCubit(AuthRepository(AuthService())),
                    child: Dialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        height: 256.h,
                        width: 346.w,
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/logout.png',
                              width: 83.w,
                              height: 83.h,
                            ),
                            SizedBox(height: 25.h),
                            Text(
                              'هل تريد تسجيل الخروج ؟',
                              style: AppTextStyles.semiboldBlack12.copyWith(fontSize: 16.sp),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 25.h),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomButton(
                                    backgroundColor: Colors.transparent,
                                    withBorder: true,
                                    withShadow: false,
                                    height: 40.h,
                                    style: AppTextStyles.boldWhite16.copyWith(
                                      color: AppColors.green,
                                    ),
                                    title: 'الغاء',
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: BlocConsumer<DeleteAccountCubit, DeleteAccountState>(
                                    listener: (context, state) {
                                      if (state is logoutSuccess) {
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (_, __, ___) =>  LoginScreen(),
                                          ),
                                              (route) => false,
                                        );
                                        toastification.show(
                                          context: context,
                                          type: ToastificationType.error,
                                          title: Text("تم تسجيل الخروج بنجاح",
                                            style: AppTextStyles.boldWhite16,
                                          ),
                                          primaryColor: AppColors.green,
                                          backgroundColor: AppColors.green,
                                          autoCloseDuration: const Duration(seconds: 2),
                                        );
                                      } else if (state is logoutError) {
                                        toastification.show(
                                          context: context,
                                          type: ToastificationType.error,
                                          title: Text(state.error),
                                          primaryColor: Colors.red,
                                          backgroundColor: Colors.red,
                                          autoCloseDuration: const Duration(seconds: 2),
                                        );
                                      }
                                    },
                                    builder: (context, state) {
                                      return CustomButton(
                                        withShadow: false,
                                        isLoading: state is logoutLoading,
                                        height: 40.h,
                                        style: AppTextStyles.boldWhite16,
                                        title: 'خروج',
                                        onPressed: () {
                                          context.read<DeleteAccountCubit>().logout();
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),

            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    String icon,
    String title,
    int duration, {
    VoidCallback? onTap,
    bool isLogout = false,
  }) {
    return FadeInLeft(
      duration: Duration(milliseconds: duration ?? 300),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFE8ECF4)),
            ),
          ),
          child: Row(
            children: [
              icon.contains('.svg')
                  ? SvgPicture.asset(
                      icon,
                      height: 22.h,
                      width: 22.w,
                    )
                  : Image.asset(
                      icon,
                      height: 22.h,
                      width: 22.w,
                    ),
              SizedBox(width: 15.w),
              Text(
                title,
                style: AppTextStyles.regularGrey15.copyWith(fontWeight: FontWeight.w500,color: Colors.black)

              ),
            ],
          ),
        ),
      ),
    );
  }
}
