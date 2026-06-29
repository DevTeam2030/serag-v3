import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mine/screens/auth/register/presentation/view/widgets/register_header.dart';
import 'package:mine/screens/home/presentation/view/service_details_screen.dart';
import 'package:mine/screens/projects/data/edit_project_service.dart';
import 'package:mine/screens/projects/presentation/view/edit_projects.dart';
import 'package:mine/screens/projects/presentation/view_model/edit_project_repo.dart';
import 'package:mine/widgets/back_button.dart';
import 'package:mine/widgets/custom_image.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/custom_richtext.dart';
import '../../../../widgets/custom_textfield.dart';
import '../../../../widgets/internet_loss_connection_widget.dart';
import '../../../auth/register/presentation/view/buildingInfo_screen.dart';
import '../../data/project_service.dart';
import '../../data/projects_model.dart';
import '../view_model/edit_project_cubit.dart';
import '../view_model/projects_cubit.dart';
import '../view_model/projects_repo.dart';
import '../view_model/projects_state.dart';
import 'project_details_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProjectsScreen extends StatefulWidget {
   ProjectsScreen({super.key, this.showBack = false});
bool showBack = false;
  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<ProjectsCubit>();
     cubit.load();
  }
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: InternetConnectionWrapper(
          onReconnect: () {
            context.read<ProjectsCubit>().load();
          },
          child: SafeArea(
            child: BlocBuilder<ProjectsCubit, ProjectsState>(
                builder: (context, state) {
                  if (state is ProjectsLoading) {
                    return const Center(
                      child: SpinKitWave(color: AppColors.darkYellow),
                    );
                  }

                  if (state is ProjectsFailure) {
                    if (state.message == "no_internet" || state.message == "timeout") {
                      return InternetLossWidget(onRetry: () {
                        context.read<ProjectsCubit>().load();
                      });
                    } else {
                      return Center(child: Text(state.message));
                    }
                    // return
                    //   state.message.contains('Connection')?
                    //       InternetLossWidget(onRetry: (){
                    //          context.read<ProjectsCubit>().load();
                    //       },)
                    //       :
                    //   Center(child: Text(state.message));
                  }

                  if (state is ProjectsListState) {
                    return _ProjectsBody(
                      canAddNew: state.canAddNew,
                      projects: state.projects,
                      showBack: widget.showBack,
                    );
                  }

                  final cubit = context.read<ProjectsCubit>();
                  if (cubit.projects.isNotEmpty) {
                    return _ProjectsBody(
                      canAddNew: cubit.canAddNew,
                      projects: cubit.projects,
                      showBack: widget.showBack,
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),

          ),
        ),
      ),
    );
  }
}

class _ProjectsBody extends StatelessWidget {
  final bool canAddNew;
  final List<ProjectModel> projects;
  bool showBack = false;
   _ProjectsBody({required this.canAddNew, required this.projects,this.showBack = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
               CustomHeader(title: 'أفواجي',
                showBack: showBack),
              SizedBox(height: 25.h),
              CustomButton(
                height: 30.h,
                width: 143.w,
                title: 'إضافة فوج جديد',
                style: AppTextStyles.boldWhite12,
                backgroundColor: canAddNew
                    ? AppColors.green
                    : AppColors.lightGrey,
                withShadow: false,
                radius: 5.h,
                onPressed: canAddNew
                    ? () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, _, __) =>
                       ServiceDetailsScreen(serviceName: 'دجاج'),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                }
                    : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'لا يمكنك اضافة فوج جديد , لديك فوج مفتوح بالفعل'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: projects.isEmpty?Center(child: Text(' لا يوجد أفواج حاليه ',
            style:AppTextStyles.boldBlack18 ,)) :ListView.separated(
            itemCount: projects.length,
            separatorBuilder: (_, __) => SizedBox(height: 0.h),
            itemBuilder: (context, i) {
              final p = projects[i];
              return _ProjectCard(
                project: p,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<ProjectsCubit>(),
                        child: ProjectDetailsScreen(projectId: p.id),
                      ),
                    ),
                  ).then((updated) {
                    if (updated == true) {
                      context.read<ProjectsCubit>().load();
                    }
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// class _ProjectsBody extends StatelessWidget {
//   final bool canAddNew;
//   final List<ProjectModel> projects;
//
//   const _ProjectsBody({required this.canAddNew, required this.projects});
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               const CustomHeader(title: 'مشاريعي'),
//               SizedBox(height: 25.h),
//               CustomButton(
//                 height: 30.h,
//                 width: 143.w,
//                 title: 'إضافة مشروع جديد',
//                 style: AppTextStyles.boldWhite12,
//                 backgroundColor: canAddNew
//                     ? AppColors.green
//                     : AppColors.lightGrey,
//                 withShadow: false,
//                 radius: 5.h,
//                 onPressed: canAddNew
//                     ? () {
//                   Navigator.push(
//                     context,
//                     PageRouteBuilder(
//                       pageBuilder: (context, _, __) =>
//                       const ServiceDetailsScreen(serviceName: 'دجاج'),
//                       transitionDuration: Duration.zero,
//                       reverseTransitionDuration: Duration.zero,
//                     ),
//                   );
//                 }
//                     : () {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text(
//                           'لا يمكنك اضافة مشروع جديد , لديك مشروع مفتوح بالفعل'),
//                       backgroundColor: Colors.red,
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//         Expanded(
//           child: ListView.separated(
//             itemCount: projects.length,
//             separatorBuilder: (_, __) => SizedBox(height: 10.h),
//             itemBuilder: (context, i) {
//               final p = projects[i];
//               return _ProjectCard(
//                 project: p,
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => BlocProvider.value(
//                         value: context.read<ProjectsCubit>(),
//                         child: ProjectDetailsScreen(projectId: p.id),
//                       ),
//                     ),
//                   ).then((updated) {
//                     if (updated == true) {
//                       context.read<ProjectsCubit>().load();
//                     }
//                   });
//                 },
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }

class _ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback onTap;

  _ProjectCard({
    required this.project,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isOpen = project.status == ProjectStatus.open;

    return InkWell(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFE3E3E3))),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center, // الصورة في النص
              children: [
                Container(
                  width: 100.w,
                  height: 100.h,
                  decoration: BoxDecoration(
                    color: AppColors.darkYellow.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.green.withOpacity(.5), width: 1),
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: Colors.black12,
                    //     blurRadius: 6,
                    //     offset: Offset(0, 3),
                    //   ),
                    // ],
                    image: const DecorationImage(
                      image: AssetImage('assets/background.png'),
                      fit: BoxFit.cover,
                    ),

                  ),
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: cachedImage(
                        usePlaceholderIfUrlEmpty: true,
                        project.image == ""
                            ? project.subCategory == "بيض مائدة"
                            ? "assets/egg.png"
                            : project.subCategory == "دجاج"
                            ? "assets/chicken_project.png"
                            : project.subCategory == "جدات الفروج"
                            ? "assets/grandChickens.png"
                            : project.subCategory == "أمهات"
                            ? "assets/mothersChicken.png"
                            : "assets/chiken.png"
                            : project.image,
                        width: 70.w,
                        height: 70.h,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),

                // التفاصيل
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            project.name,
                            style: AppTextStyles.boldBlack30.copyWith(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          if (isOpen)
                            InkWell(
                              onTap: () async {
                                final cubit = context.read<ProjectsCubit>();

                                // Show loading dialog
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => const Center(
                                    child: SpinKitWave(color: AppColors.green),
                                  ),
                                );

                                await cubit
                                    .fetchProjectDetails(project.id.toString());

                                Navigator.pop(context); // close the loading dialog

                                final state = cubit.state;
                                if (state is ProjectDetailsLoaded) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => BlocProvider.value(
                                        value: cubit,
                                        child: EditProjectScreen(
                                          project: state.project,
                                          serviceType: state.project.subCategory,
                                          projectName: project.name,
                                        ),
                                      ),
                                    ),
                                  ).then((updated) {
                                    context.read<ProjectsCubit>().load();
                                  });
                                } else if (state is ProjectsFailure) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                        Text("فشل تحميل تفاصيل الفوج")),
                                  );
                                }
                              },
                              child: Image.asset(
                                'assets/edit.png',
                                width: 16.w,
                                height: 16.h,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'نوع التربيه: ${project.species} - ${project.subCategory}',
                        style: AppTextStyles.semiboldBlack12,
                      ),
                      SizedBox(height: 4.h),
                      RichText(
                        text: TextSpan(
                          style: AppTextStyles.regularGrey15,
                          children: [
                            TextSpan(
                              text: 'تاريخ البدايه : ',
                              style: AppTextStyles.semiboldBlack12,
                            ),
                            TextSpan(
                              text: _fmt(project.startDate),
                              style: AppTextStyles.boldBlack12,
                            ),
                          ],
                        ),
                      ),
                      if (project.subCategory != "بيض مائدة")
                        RichText(
                          text: TextSpan(
                            style: AppTextStyles.regularGrey15,
                            children: [
                              TextSpan(
                                text: 'تاريخ الانتهاء المتوقع : ',
                                style: AppTextStyles.semiboldBlack12,
                              ),
                              TextSpan(
                                text: _fmt(project.endDate),
                                style: AppTextStyles.boldBlack12,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // حالة المشروع في بداية العمود (start vertically)

              ],
            ),
          ),
          IgnorePointer(
            child: Align(
              alignment: Alignment.topLeft,
              child: _StatusChip(
                text: isOpen ? 'مفتوح' : 'منتهي',
                color: isOpen ? AppColors.lightGreen : AppColors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';
}



class _StatusChip extends StatelessWidget {
  final String text;
  final Color color;
  const _StatusChip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: 25.h,
      width: 77.w,
      margin: EdgeInsets.only(top: 10.h, left: 10.w, right: 10.w),
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Text(text, style: AppTextStyles.boldWhite12),
    );
  }
}
