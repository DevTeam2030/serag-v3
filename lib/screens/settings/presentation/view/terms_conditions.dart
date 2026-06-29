import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mine/constants/app_text_styles.dart';
import 'package:mine/screens/auth/register/presentation/view/widgets/register_header.dart';
import 'package:mine/widgets/internet_loss_connection_widget.dart';

import '../../../../constants/app_colors.dart';
import '../../../auth/register/presentation/view_model/building_info_cubit.dart';
import '../../../auth/register/presentation/view_model/building_info_states.dart';

class TermsConditions extends StatefulWidget {
  const TermsConditions({super.key});

  @override
  State<TermsConditions> createState() => _TermsConditionsState();
}

class _TermsConditionsState extends State<TermsConditions> {
  @override
  void initState() {
    super.initState();
    // Fetch settings if not already loaded
    final cubit = context.read<ProjectDataCubit>();
    if (cubit.settingsData == null) {
      cubit.fetchSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProjectDataCubit()..fetchSettings(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: InternetConnectionWrapper(
            onReconnect: () {
              context.read<ProjectDataCubit>().fetchSettings();
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 30.h),
                  CustomHeader(title: 'الشروط والأحكام',showBack: true,),
                  SizedBox(height: 30.h),
                  Expanded(
                    child: BlocBuilder<ProjectDataCubit, ProjectDataState>(
                      builder: (context, state) {
                        if (state is BuildingInfoLoading) {
                          return Center(
                            child: SpinKitWave(
                              color: AppColors.green,
                              size: 30.0,
                            ),
                          );
                        }
                        if (state is BuildingInfoError) {
                          return Center(
                            child: Text(
                              state.message,
                              style: AppTextStyles.regularBlack12.copyWith(
                                fontSize: 16.sp,
                                color: Colors.red,
                              ),
                            ),
                          );
                        }
                        if (state is BuildingInfoLoaded) {
                          final terms = state.settingsData.terms.isNotEmpty
                              ? state.settingsData.terms
                                  .replaceAll('<p>', '\n')
                                  .replaceAll('/p>', '')
                                  .replaceAll('&nbsp;', '')
                                  .replaceAll('>', '').replaceAll('<', '')
                              : 'لا توجد شروط وأحكام متاحة';
                          return SingleChildScrollView(
                            child: DefaultTextStyle(
                              style: AppTextStyles.semiboldBlack12
                                  .copyWith(fontSize: 16.sp),
                              child: AnimatedTextKit(
                                repeatForever: false,
                                totalRepeatCount: 1,
                                animatedTexts: [
                                  TypewriterAnimatedText(terms),
                                ],
                                onTap: () {
                                  print("Tap Event");
                                },
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
