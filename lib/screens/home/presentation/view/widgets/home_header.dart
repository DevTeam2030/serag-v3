import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:mine/constants/app_constants.dart';
import 'package:mine/core/common/size_utilies.dart';
import 'package:mine/core/helper/cache_helper.dart';

import '../../../../../constants/app_colors.dart';
import '../../../../../constants/app_text_styles.dart';
import '../../../../../widgets/custom_button.dart';
import '../../../../../widgets/establishment_button.dart';
import '../../../../projects/data/projects_model.dart';
import '../../../../projects/presentation/view/project_details_screen.dart';
import '../../../../projects/presentation/view_model/projects_cubit.dart';
import '../../../../projects/presentation/view_model/projects_state.dart';
import '../../../../settings/presentation/view/notification_screen.dart';
import '../../../../settings/presentation/view_model/notification_cubit.dart';
import '../../../../settings/presentation/view_model/notification_state.dart';
import 'package:badges/badges.dart' as badges;

import '../../view_model/establishment_cubit.dart';
import '../../view_model/establishment_state.dart';


class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EstablishmentCubit, EstablishmentState>(
      builder: (context, establishmentState) {
        // Get establishment type from cache
        final establishmentTypeId = CacheHelper.getData('establishment_type_id')?.toString() ?? '1';
        final isPoultryFarm = establishmentTypeId == '1'; // المدجنة
        final username = CacheHelper.getData('username') ?? '';

        final projects = context.watch<ProjectsCubit>().projects;
        final openProject = projects.where((p) => p.status == ProjectStatus.open).toList();

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: width * 0.6, // Adjust the width as needed
                  child: Text(
                    'مرحبا $username',
                    style: AppTextStyles.boldGrey17.copyWith(
                      color: Colors.black,
                      fontSize: 16,
                    ),
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

            // Only show icons for المدجنة (establishment_type_id: 1)
            if (isPoultryFarm)
              Column(
                children: [
                  Row(
                    children: [
                      PurificationButton(),
                      SizedBox(width: 4.w),
                      GestureDetector(
                          onTap: () {
                            final messageController = TextEditingController();
                            showDialog(
                              context: context,
                              builder: (context) {
                                return ReportDialog(
                                  messageController: messageController,
                                  id: "0",
                                );
                              },
                            );
                          },
                          child: Image.asset('assets/report.png',height: 45.h,width: 45.w,)
                      ),
                      SizedBox(width: 4.w),
                      buildNotificationIcon(context),
                    ],
                  ),
                  SizedBox(height: 10.h,),
                ],
              ),
          ],
        );
      },
    );
  }
}


Widget buildNotificationIcon(BuildContext context) {
  return BlocBuilder<NotificationCubit, NotificationState>(
    builder: (context, state) {
      int newNotificationCount = 0;
      if (state is NotificationLoaded) {
        newNotificationCount =
            state.notifications.where((n) => n['status'] != 'seen').length;
      }

      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const NotificationScreen(),
              transitionDuration: const Duration(milliseconds: 600),
              reverseTransitionDuration: const Duration(milliseconds: 600),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          );
        },
        child: badges.Badge(
          showBadge: newNotificationCount > 0,
          badgeContent: Text(
            newNotificationCount.toString(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          badgeStyle: badges.BadgeStyle(
            badgeColor: Colors.red,
            padding: EdgeInsets.all(6.w),
          ),
          position: badges.BadgePosition.topEnd(top: -5.h, end: -5.w),
          child: Image.asset(
            'assets/notification.png',
            width: 45.w,
            height: 45.h,
          ),
        ),
      );
    },
  );
}

class PurificationButton extends StatefulWidget {
  const PurificationButton({super.key});

  @override
  State<PurificationButton> createState() => _PurificationButtonState();
}

class _PurificationButtonState extends State<PurificationButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _borderWidth;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _borderWidth = Tween<double>(begin: 1.5, end: 4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projects = context.watch<ProjectsCubit>().projects;
    final closedProjects =
    projects.where((p) => p.status == ProjectStatus.closed).toList();

    if (closedProjects.isEmpty) {
      return const SizedBox.shrink();
    }

    final lastClosedProject = closedProjects.first;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ProjectDetailsScreen(projectId: lastClosedProject.id),
          ),
        );
      },
      child: AnimatedBuilder(
        animation: _borderWidth,
        builder: (context, child) {
          return Container(
            height: 45.h,
            width: 45.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.red,
                width: _borderWidth.value,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/Purification.png',
                  width: 15.w,
                  height: 15.h,
                  color: Colors.red,
                ),
                SizedBox(height: 2.h),
                Text(
                  'التطهير',
                  style: AppTextStyles.boldWhite12.copyWith(
                    color: Colors.red,
                    fontSize: 5.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 2.h),
              ],
            ),
          );
        },
      ),
    );
  }
}

