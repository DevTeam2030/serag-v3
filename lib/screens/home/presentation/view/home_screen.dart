import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mine/constants/app_colors.dart';
import 'package:mine/constants/app_text_styles.dart';
import 'package:mine/screens/home/presentation/view/widgets/end_project_widget.dart';
import 'package:mine/screens/home/presentation/view/widgets/home_header.dart';
import 'package:mine/screens/home/presentation/view/widgets/home_price_widget.dart';
import 'package:mine/screens/home/presentation/view/widgets/services_gridView.dart';

import '../../../../constants/app_constants.dart';
import '../../../../widgets/establishment_button.dart';
import '../../../ads/presentation/view/widgets/homa_ads_slider.dart';
import '../../../auth/register/presentation/view_model/building_info_cubit.dart';
import '../../../auth/register/presentation/view_model/building_info_states.dart';
import '../../../prices/presentation/view_model/prices_cubit.dart';

class LivestockHomePage extends StatefulWidget {
  const LivestockHomePage({super.key});

  @override
  State<LivestockHomePage> createState() => _LivestockHomePageState();
}

class _LivestockHomePageState extends State<LivestockHomePage> {
  @override
  void initState() {
    super.initState();

    context.read<ProjectDataCubit>().fetchSettings();
    context.read<PricesCubit>().loadPrices();

  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final crossAxisCount = width >= 900
        ? 4
        : width >= 600
            ? 3
            : 2;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HomeHeader(),

                const SizedBox(
                  height: 16,
                ),

                AppConstants().isNormalUser
                    ? const SizedBox.shrink()
                    : Align(
                        alignment: Alignment.center,
                        child: EstablishmentButton(),
                      ),

                const SizedBox(
                  height: 16,
                ),

                EndOfProjectDateWidget(),

                const SizedBox(
                  height: 16,
                ),

                /// Entire body scrolls
                Expanded(
                  child: SingleChildScrollView(
                    child: BlocBuilder<ProjectDataCubit, ProjectDataState>(
                      builder: (context, state) {
                        if (state is BuildingInfoLoading) {
                          return SizedBox(
                            height: MediaQuery.of(context).size.height * .5,
                            child: const Center(
                              child: SpinKitWave(
                                color: AppColors.green,
                              ),
                            ),
                          );
                        }

                        if (state is BuildingInfoLoaded) {
                          final categories = state.settingsData.categories;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const HomeAdsSlider(),
                              const SizedBox(height: 14),

                              const HomePricesWidget(),

                              const SizedBox(
                                height: 20,
                              ),
                              Text(
                                'اختر نوع التربية',
                                style: AppTextStyles.boldGrey17.copyWith(
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              if (categories.isEmpty)
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                      50,
                                    ),
                                    child: Text(
                                      'لا توجد فئات متاحة',
                                      style: AppTextStyles.boldGrey17,
                                    ),
                                  ),
                                )
                              else
                                ServicesGridViewWidget(
                                  categories: categories,
                                  crossAxisCount: crossAxisCount,
                                ),
                            ],
                          );
                        }

                        return SizedBox(
                          height: MediaQuery.of(context).size.height * .5,
                          child: Center(
                            child: Text(
                              'حدث خطأ في تحميل البيانات',
                              style: AppTextStyles.boldGrey17,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
