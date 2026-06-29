import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mine/widgets/back_button.dart';
import 'package:mine/widgets/internet_loss_connection_widget.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../widgets/custom_button.dart';
import '../../data/project_service.dart';
import '../../data/projects_model.dart';
import '../view_model/projects_cubit.dart';
import '../view_model/projects_repo.dart';
import '../view_model/projects_state.dart';
import '../widgets/close_project_dialog.dart';

class ProjectDetailsScreen extends StatelessWidget {
  final String projectId;
  const ProjectDetailsScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    // ✅ no BlocProvider here anymore
    final cubit = context.read<ProjectsCubit>();
    cubit.fetchProjectDetails(projectId);

    return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: InternetConnectionWrapper(
            onReconnect: () {
              context.read<ProjectsCubit>().fetchProjectDetails(projectId);
            },
            child: SafeArea(
              child: BlocListener<ProjectsCubit, ProjectsState>(
                listenWhen: (prev, curr) =>
                    curr is ProjectCloseSuccess || curr is ProjectCloseFailure,
                listener: (context, state) {
                  if (state is ProjectCloseSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message,
                            style: AppTextStyles.boldWhite12),
                        backgroundColor: AppColors.green,
                      ),
                    );
                    // Navigator.pop(context, true);
                  } else if (state is ProjectCloseFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message,
                            style: AppTextStyles.boldWhite12),
                        backgroundColor: AppColors.red,
                      ),
                    );
                  }
                },
                child: BlocBuilder<ProjectsCubit, ProjectsState>(
                  buildWhen: (prev, curr) =>
                      curr is ProjectLoadingDetails ||
                      curr is ProjectDetailsLoaded ||
                      curr is ProjectDetailsFailure,
                  builder: (context, state) {
                    if (state is ProjectLoadingDetails) {
                      return const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.darkYellow),
                      );
                    }
                    if (state is ProjectDetailsFailure) {
                      return Center(child: Text(state.message));
                    }
                    if (state is ProjectDetailsLoaded) {
                      print('project: ${state.project.name} , project end Date is ${state.project.endDate}');
                      return _ProjectDetailsBody(project: state.project);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ),
        ));
  }
}

class _ProjectDetailsBody extends StatelessWidget {
  final ProjectDetailsModel project;
  const _ProjectDetailsBody({required this.project});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<ProjectsCubit>();

    print("project: ${project.subCategory}");
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 30.w,
              ),
              Text(project.name,
                  style: AppTextStyles.boldBlack30.copyWith(fontSize: 20.sp)),
              BkBtn(),
            ],
          ),
          SizedBox(height: 15.h),

          /// Species Segments
          Row(
            children: [
              Expanded(
                child: _Segment(
                  label: project.species,
                  activeColor: AppColors.green,
                  isActive: true,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _Segment(
                  label: project.subCategory,
                  activeColor: AppColors.darkYellow,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          /// Start & End Date
          Row(
            children: [
              Expanded(
                child: _DateBox(
                  isRight: true,
                  isEndDate: false,
                  title: 'تاريخ بداية الفوج',
                  date: project.startDate,
                ),
              ),
              Expanded(
                child: _DateBox(
                  isEndDate: true,
                  isRight: false,
                  title: 'تاريخ الانتهاء',
                  date: project.endDate ,
                  isWithEndDate: project.subCategory=="بيض مائدة",
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          if (project.status == ProjectStatus.closed) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.h),
              margin: EdgeInsets.only(bottom: 12.h),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                "المنشأة بحاجة الي تطهير",
                style: AppTextStyles.boldWhite16,
                textAlign: TextAlign.center,
              ),
            ),
          ],
          Divider(thickness: 1.w, color: const Color(0xFFE3E3E3)),
          SizedBox(height: 10.h),

          /// Financial / Details
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _ThreePillRow(
                    first: _Pill(
                      title: 'مصدر الصوص',
                      value: project.chicksSource,
                      isRight: true,
                    ),
                    second: _Pill(
                      title: 'عدد الصوص',
                      value: '${project.chicksCount}',
                    ),
                    third: _Pill(
                      title: 'قنوات التوزيع',
                      value: project.distributionChannel,
                      isLeft: true,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  _ThreePillRow(
                    first: _Pill(
                      title: 'مصدر العلف',
                      value: project.feedSource,
                      isRight: true,
                    ),
                    second: _Pill(
                      title: 'كمية العلف',
                      value: project.feedAmount,
                    ),
                    third: _Pill(
                      title: 'نسبة التحويل',
                      value: project.conversionRate,
                      isLeft: true,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  _ThreePillRow(
                    first: _Pill(
                      title: 'عدد الطيور النافقة',
                      value: '${project.deadBirds}',
                      isRight: true,
                    ),
                    second: _Pill(
                      title: 'نوع الأمراض',
                      value: project.diseaseType,
                    ),
                    third: _Pill(
                      title: 'برنامج التطعيم',
                      value: project.vaccinationProgram,
                      isLeft: true,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  if (project.subCategoryId == 7)
                    _Pill(
                      title: 'كميه اللحم المباع',
                      value: project.meatQuantity,
                      isRounded: true,
                    ),
                  SizedBox(height: 24.h),

                  /// Close Project Button
                  if (project.status == ProjectStatus.open)
                    SizedBox(
                      width: double.infinity,
                      child: BlocConsumer<ProjectsCubit, ProjectsState>(
                        listener: (context, state) {
                          if (state is ProjectCloseSuccess) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.message,
                                    style: AppTextStyles.boldWhite12),
                                backgroundColor: AppColors.green,
                              ),
                            );
                            Navigator.pop(
                                context, true); // go back and refresh list
                          } else if (state is ProjectCloseFailure) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.message,
                                    style: AppTextStyles.boldWhite12),
                                backgroundColor: AppColors.red,
                              ),
                            );
                          }
                        },
                        builder: (context, state) {
                          final isLoading = state is ProjectCloseLoading;
                          return CustomButton(
                            height: 82.h,
                            title: isLoading ? "جاري الغلق..." : "غلق الفوج",
                            backgroundColor: AppColors.darkYellow,
                            withShadow: false,
                            isLoading: isLoading,
                            onPressed: () {

                              showDialog(

                                context: context,

                                builder: (_) {

                                  return CloseProjectDialog(

                                    projectId:
                                    project.id.toString(),

                                  );

                                },
                              );

                            },
                          );
                        },
                      ),
                    ),

                  SizedBox(height: 15.h),

                  /// Report Outbreak Button
                  BlocListener<ProjectsCubit, ProjectsState>(
                    listenWhen: (prev, curr) =>
                        curr is ProjectReportSuccess ||
                        curr is ProjectReportFailure,
                    listener: (context, state) {
                      if (state is ProjectReportSuccess) {
                        debugPrint('report success');
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   SnackBar(
                        //     content: Text(state.message, style: AppTextStyles.boldWhite12),
                        //     backgroundColor: AppColors.green,
                        //   ),
                        // );
                      } else if (state is ProjectReportFailure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message,
                                style: AppTextStyles.boldWhite12),
                            backgroundColor: AppColors.red,
                          ),
                        );
                      }
                    },
                    child: SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        height: 82.h,
                        title: 'الإشتباه في وباء',
                        backgroundColor: AppColors.red,
                        withShadow: false,
                        onPressed: () {
                          final messageController = TextEditingController();
                          showDialog(
                            context: context,
                            builder: (context) {
                              return ReportDialog(
                                  messageController: messageController,
                                  id: project.id.toString());
                            },
                          );
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReportDialog extends StatelessWidget {
  const ReportDialog({
    super.key,
    required this.messageController,
    required this.id,
  });

  final TextEditingController messageController;
  final String id;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 24.h),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: const Text(
        "الإشتباه في وباء",
        textAlign: TextAlign.center,
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.77, // 👈 أوسع
        child: TextField(
          textAlign: TextAlign.right,
          controller: messageController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: "... اكتب رسالتك هنا",
            hintStyle:
                AppTextStyles.regularBlack12.copyWith(color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Colors.grey,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Colors.grey,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Colors.grey,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Colors.grey,
              ),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        CustomButton(
          height: 45.h,
          width: 120.w,
          title: "ارسل",
          style: AppTextStyles.boldWhite16,
          backgroundColor: AppColors.green,
          withShadow: false,
          onPressed: () {
            if (messageController.text.isNotEmpty) {
              context.read<ProjectsCubit>().reportOutbreak(
                    id.toString(),
                    messageController.text,
                  );
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('الرجاء كتابة رسالة',
                      style: AppTextStyles.boldWhite12),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ],
    );
  }
}

/// UI Components: Segment, DateBox, ThreePillRow, Pill
class _Segment extends StatelessWidget {
  final String label;
  final Color activeColor;
  bool isActive = false;
  _Segment(
      {required this.label, required this.activeColor, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isActive ? AppColors.green : AppColors.darkYellow,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.boldWhite16,
      ),
    );
  }
}

class _DateBox extends StatelessWidget {
  final String title;
  final DateTime date;
  bool isWithEndDate = true;
  bool isEndDate;
  final bool isRight;
   _DateBox(
      {required this.title, required this.date, this.isRight = false,this.isWithEndDate = true, this.isEndDate = false});

  @override
  Widget build(BuildContext context) {
    String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: isRight
            ? BorderRadius.only(
                bottomRight: Radius.circular(12.r),
                topRight: Radius.circular(12.r))
            : BorderRadius.only(
                bottomLeft: Radius.circular(12.r),
                topLeft: Radius.circular(12.r)),
        border: Border.all(color: Colors.grey.withOpacity(.15)),
      ),
      child: Column(
        children: [
          Text(title,
              style: AppTextStyles.semiboldBlack12
                  .copyWith(fontWeight: FontWeight.w600)),
          SizedBox(height: 4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_month, size: 18.sp, color: Colors.black54),
              SizedBox(width: 5.w),
              Text(
                isEndDate==true?
                  isWithEndDate==false?
                  _fmt(date):"لا يوجد تاريخ انتهاء" : _fmt(date),
                  style:
                      AppTextStyles.regularBlack12.copyWith(fontSize: 10.sp)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThreePillRow extends StatelessWidget {
  final Widget first;
  final Widget second;
  final Widget third;
  const _ThreePillRow(
      {required this.first, required this.second, required this.third});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: first),
        Expanded(child: second),
        Expanded(child: third),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String title;
  final String value;
  final bool isRight;
  final bool isLeft;
  final bool isRounded;
  const _Pill({
    required this.title,
    required this.value,
    this.isRight = false,
    this.isLeft = false,
    this.isRounded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: 70.h,
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        border: Border.all(color: Colors.grey.withOpacity(.15)),
        borderRadius: isRounded
            ? BorderRadius.circular(12.r)
            : isRight
                ? BorderRadius.only(
                    bottomRight: Radius.circular(12.r),
                    topRight: Radius.circular(12.r))
                : isLeft
                    ? BorderRadius.only(
                        bottomLeft: Radius.circular(12.r),
                        topLeft: Radius.circular(12.r))
                    : BorderRadius.zero,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style: AppTextStyles.semiboldBlack12
                  .copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center),
          SizedBox(height: 4.h),
          Text(value == '' ? 'غير محدد' : value,
              style: AppTextStyles.regularBlack12
                  .copyWith(fontSize: 10.sp, color: Colors.black),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
