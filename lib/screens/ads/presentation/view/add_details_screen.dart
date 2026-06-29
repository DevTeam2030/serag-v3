import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:mine/constants/app_colors.dart';
import 'package:mine/constants/app_text_styles.dart';

import 'package:mine/screens/auth/register/presentation/view/widgets/register_header.dart';

import 'package:mine/widgets/custom_image.dart';

import '../view_model/ad_details_cubiit.dart';
import '../view_model/ad_details_state.dart';

class AdDetailsScreen extends StatefulWidget {
  final int id;

  const AdDetailsScreen({
    super.key,
    required this.id,
  });

  @override
  State<AdDetailsScreen> createState() =>
      _AdDetailsScreenState();
}

class _AdDetailsScreenState
    extends State<AdDetailsScreen> {

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();

    context.read<AdDetailsCubit>().loadDetails(
      widget.id,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: BlocBuilder<
          AdDetailsCubit,
          AdDetailsState>(
        builder: (
            context,
            state,
            ) {

          if (state
          is AdDetailsLoading) {

            return const Center(
              child: SpinKitWave(color: AppColors.green),
            );
          }

          if (state
          is AdDetailsFailure) {

            return Center(
              child: Text(
                state.message,
              ),
            );
          }

          if (state
          is AdDetailsLoaded) {

            final ad = state.ad;

            return SingleChildScrollView(

              padding:
              EdgeInsets.all(
                16.w,
              ),

              child: Column(

                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  SizedBox(
                    height: 20.h,
                  ),

                  CustomHeader(
                    title: ad.title,
                    showBack: true,
                  ),

                  SizedBox(
                    height: 20.h,
                  ),

                  CarouselSlider(

                    items: ad.images
                        .map(

                          (e) => ClipRRect(

                        borderRadius:
                        BorderRadius.circular(
                          12,
                        ),

                        child: cachedImage(

                          e,

                          fit:
                          BoxFit.cover,

                          width:
                          double.infinity,

                        ),
                      ),

                    )
                        .toList(),

                    options:
                    CarouselOptions(

                      height: 220.h,

                      viewportFraction: 1,

                      enableInfiniteScroll:
                      false,

                      onPageChanged:
                          (index, reason) {

                        setState(() {

                          currentIndex =
                              index;

                        });

                      },
                    ),
                  ),

                  SizedBox(
                    height: 12.h,
                  ),

                  Row(

                    mainAxisAlignment:
                    MainAxisAlignment.center,

                    children: List.generate(

                      ad.images.length,

                          (index) => AnimatedContainer(

                        duration:
                        const Duration(
                          milliseconds:
                          250,
                        ),

                        margin:
                        const EdgeInsets
                            .symmetric(
                          horizontal:
                          4,
                        ),

                        width:
                        currentIndex ==
                            index
                            ? 18
                            : 8,

                        height: 8,

                        decoration:
                        BoxDecoration(

                          color:
                          currentIndex ==
                              index
                              ? AppColors
                              .green
                              : Colors
                              .grey,

                          borderRadius:
                          BorderRadius.circular(
                            20,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 24.h,
                  ),

                  Text(

                    ad.description,

                    textAlign:
                    TextAlign.end,

                    style:
                    AppTextStyles
                        .paragraph,
                  ),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}