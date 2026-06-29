import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mine/screens/projects/data/projects_model.dart';

import '../../../../../constants/app_colors.dart';
import '../../../../../constants/app_text_styles.dart';
import '../../../../projects/presentation/view/project_details_screen.dart';
import '../../../../projects/presentation/view_model/projects_cubit.dart';
import '../../../../projects/presentation/view_model/projects_state.dart';

class EndOfProjectDateWidget extends StatelessWidget {
  const EndOfProjectDateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectsCubit, ProjectsState>(
      builder: (context, state) {
        List<ProjectModel> projects = [];

        if (state is ProjectsLoaded) {
          projects = state.projects;
        } else if (state is ProjectDetailsLoaded) {
          projects = state.projects;
        } else if (state is ProjectLoadingDetails) {
          projects = state.projects;
        } else if (state is ProjectActionInProgress) {
          projects = state.projects;
        } else if (state is ProjectsFailure) {
          return Center(
            child: Text(
              'فشل تحميل الأفواج',
              style: AppTextStyles.boldGrey17.copyWith(color: Colors.red),
            ),
          );
        } else if (state is ProjectsLoading) {
          return const Center(
            child: SpinKitWave(
              color: AppColors.green,
              size: 30.0,
            ),
          );
        }

        if (projects.isEmpty) {
          return Center(
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppColors.darkYellow, AppColors.green],
              ).createShader(bounds),
              blendMode: BlendMode.srcIn,
              child: Container(
                alignment: Alignment.center,
                width: double.infinity,
                height: 60.h,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.green, width: 2),
                ),
                child: Text(
                  'لا يوجد فوج مفتوح حالياً',
                  style: AppTextStyles.regularGrey15,
                ),
              ),
            ),
          );
        }

        // filter open projects
        final openProjects =
        projects.where((p) => p.status == ProjectStatus.open).toList();

        if (openProjects.isEmpty) {
          return Center(
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppColors.darkYellow, AppColors.green],
              ).createShader(bounds),
              blendMode: BlendMode.srcIn,
              child: Container(
                alignment: Alignment.center,
                width: double.infinity,
                height: 60.h,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.green, width: 2),
                ),
                child: Text(
                  'لا يوجد فوج مفتوح حالياً',
                  style: AppTextStyles.regularGrey15,
                ),
              ),
            ),
          );
        }

        // assuming only one open project at a time
        final project = openProjects.first;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProjectDetailsScreen(projectId: project.id),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.green, width: 2),
            ),
            child: Row(
              children: [
                Image.asset('assets/chiken.png', width: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        project.name,
                        style: AppTextStyles.boldGrey17.copyWith(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'تاريخ الإنتهاء',
                            style: AppTextStyles.boldGrey17.copyWith(
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.calendar_month,
                              size: 25.h, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            project.endDate
                                .toIso8601String()
                                .split("T")
                                .first,
                            style: AppTextStyles.boldGrey17.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
