import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mine/constants/app_colors.dart';
import 'package:mine/constants/app_constants.dart';
import 'package:mine/screens/auth/register/presentation/view/widgets/register_header.dart';
import 'package:mine/widgets/custom_image.dart';
import 'package:mine/widgets/internet_loss_connection_widget.dart';

import '../../../../constants/app_text_styles.dart';
import '../../../../core/helper/cache_helper.dart';
import '../view_model/notification_cubit.dart';
import '../view_model/notification_repo.dart';
import '../view_model/notification_services.dart';
import '../view_model/notification_state.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {

    print(CacheHelper.getData('establishment_type_id'));
    return BlocProvider(
      create: (_) => NotificationCubit(NotificationRepository(NotificationService()))..loadNotifications(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: InternetConnectionWrapper(
            onReconnect: () {
              context.read<NotificationCubit>().loadNotifications();
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  SizedBox(height: 30.h),
                  AppConstants().isPoultryFarm ?
                  CustomHeader(title: 'الإشعارات',showBack: true,):
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Align(
                          alignment: Alignment.center,
                          child: Image.asset('assets/logo.png',width: 100.w,height: 100.h,)),
                      Text(
                        'مرحبا ${CacheHelper.getData('username') ?? ''}',
                        style: AppTextStyles.boldGrey17.copyWith(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'اهلا بك في تطبيق سراج',
                        style: AppTextStyles.boldGrey17.copyWith(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),

              Expanded(
                child: BlocConsumer<NotificationCubit, NotificationState>(
                  listener: (context, state) {
                    if (state is NotificationSeenSuccess) {
                      context.read<NotificationCubit>().loadNotifications();
                    } else if (state is NotificationSeenError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message)),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is NotificationLoading) {
                      return const Center(child: SpinKitWave(
                        color: AppColors.green,
                        size: 30.0,
                      ));
                    } else if (state is NotificationLoaded) {
                      if (state.notifications.isEmpty) {
                        return const Center(child: Text("لا توجد إشعارات"));
                      }

                      return ListView.separated(
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, index) {
                          final item = state.notifications[index];
                          final isNew = item['status'] == "new";
                          final rawDate = item['date'] ?? '';
                          String formattedDate = rawDate;
                          if (rawDate.contains(' ')) {
                            final parts = rawDate.split(' ');
                            if (parts.length >= 2) {
                              formattedDate = "${parts[0]} - ${parts[1]}";
                            }
                          }
                          return GestureDetector(
                            onTap: () {
                              // if (isNew) {
                              //   // context.read<NotificationCubit>().markAsSeen(item['id']);
                              // }
                              showDialog(context: context, builder: (context) {
                                return Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: AlertDialog(
                                    elevation: 5,
                                    surfaceTintColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.r),
                                    ),
                                    shadowColor: Colors.black.withOpacity(0.2),
                                    alignment: AlignmentDirectional.center,
                                    backgroundColor: Colors.white,

                                    title: Row(
                                      children: [
                                        ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: cachedImage(item['image'],height: 60.h,width: 60.w)),
                                        SizedBox(width: 10.w,),
                                        Text(item['not_title'] ?? '',style: AppTextStyles.boldBlack12.copyWith(fontSize: 16.sp),),
                                      ],
                                    ),
                                    content: Text(item['message'] ?? '',style: AppTextStyles.regularBlack12.copyWith(fontSize: 14.sp),),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child:  Text('إغلاق',
                                          style: AppTextStyles.boldPrimary12,),
                                      ),
                                    ],
                                  ),
                                );
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              margin: EdgeInsets.symmetric(vertical: 10.h),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.r),
                                boxShadow: const [
                                  BoxShadow(color: Color(0x1A000000)),
                                ],
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),

                                    child: cachedImage(item['image'],height: 96.h,width: 96.w),
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['not_title'] ?? '',
                                          style: AppTextStyles.boldBlack12.copyWith(fontSize: 14.sp),
                                        ),
                                        SizedBox(height: 5.h),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 12.0),
                                          child: Text(
                                            item['message'] ?? '',
                                            style: AppTextStyles.regularBlack12.copyWith(fontSize: 10.sp),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(height: 5.h),
                                        Text(
                                          formattedDate ?? '',
                                          style: AppTextStyles.regularBlack12.copyWith(
                                            color: const Color(0xFF8391A1),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  isNew
                                      ? Icon(Icons.notifications_active, color: AppColors.green, size: 20.w)
                                      :Icon(
                                          Icons.checklist,
                                          color: Colors.green,
                                          size: 20.w,
                                        ),
                                ],
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) => Divider(),
                        itemCount: state.notifications.length,
                      );
                    } else if (state is NotificationError) {
                      return Center(child: Text("خطأ: ${state.message}"));
                    } else if (state is NotificationSeenLoading) {
                      return const Center(child: SpinKitWave(
                        color: AppColors.green,
                        size: 30.0,
                      )); // اختيارياً
                    }
                    return const SizedBox();
                  },
                ),
              )

              ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
