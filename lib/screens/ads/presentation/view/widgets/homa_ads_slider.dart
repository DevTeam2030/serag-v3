import 'package:cached_network_image/cached_network_image.dart';

import 'package:carousel_slider/carousel_slider.dart';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../widgets/custom_image.dart';
import '../../view_model/home_ads_cubit.dart';
import '../../view_model/home_ads_state.dart';
import '../add_details_screen.dart';


class HomeAdsSlider extends StatefulWidget {

  const HomeAdsSlider({
    super.key,
  });

  @override
  State<HomeAdsSlider> createState() =>
      _HomeAdsSliderState();

}

class _HomeAdsSliderState
    extends State<HomeAdsSlider> {

  int currentIndex = 0;

  @override
  void initState() {

    super.initState();

    context
        .read<HomeAdsCubit>()
        .loadAds();

  }

  @override
  Widget build(BuildContext context) {

    return BlocBuilder<
        HomeAdsCubit,
        HomeAdsState>(
      builder: (context, state) {

        if (state is HomeAdsLoading) {

          return const SizedBox();

        }

        if (state is HomeAdsFailure) {

          return const SizedBox();

        }

        if (state is HomeAdsLoaded) {

          if (state.ads.isEmpty) {

            return const SizedBox();

          }

          return Column(

            children: [

              CarouselSlider.builder(

                itemCount:
                state.ads.length,

                options:
                CarouselOptions(

                  height: 170,

                  viewportFraction: 1,

                  autoPlay: true,

                  enlargeCenterPage: false,

                  onPageChanged:
                      (index, reason) {

                    setState(() {

                      currentIndex =
                          index;

                    });

                  },

                ),

                itemBuilder:

                    (context,
                    index,
                    realIndex) {

                  final ad =
                  state.ads[index];

                  final image = ad
                      .images
                      .isNotEmpty
                      ? ad.images.first
                      : '';

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdDetailsScreen(
                            id: ad.id,
                          ),
                        ),
                      );
                    },

                    child: Padding(

                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 6,
                      ),

                      child: Stack(

                        children: [

                          ClipRRect(

                            borderRadius:
                            BorderRadius.circular(
                              18,
                            ),

                            child:
                            CachedNetworkImage(

                              imageUrl:
                              image,

                              fit:
                              BoxFit.cover,

                              width:
                              double.infinity,
                              errorWidget: (_, s, d){
                                return placeHolderWidget();
                              },

                            ),

                          ),

                          Positioned.fill(

                            child: Center(

                              child:
                              Container(

                                margin:
                                const EdgeInsets.symmetric(
                                  horizontal:
                                  25,
                                ),

                                padding:
                                const EdgeInsets.all(
                                  16,
                                ),

                                decoration:
                                BoxDecoration(

                                  color:
                                  Colors.green.withOpacity(
                                    .45,
                                  ),

                                  borderRadius:
                                  BorderRadius.circular(
                                    12,
                                  ),

                                ),

                                child:
                                Column(

                                  mainAxisSize:
                                  MainAxisSize.min,

                                  children: [

                                    // Text(
                                    //
                                    //   ad.title,
                                    //
                                    //   textAlign:
                                    //   TextAlign.center,
                                    //
                                    //   style:
                                    //   const TextStyle(
                                    //
                                    //     color:
                                    //     Colors.white,
                                    //
                                    //     fontSize:
                                    //     18,
                                    //
                                    //     fontWeight:
                                    //     FontWeight.bold,
                                    //
                                    //   ),
                                    //
                                    // ),
                                    //
                                    // const SizedBox(
                                    //   height:
                                    //   8,
                                    // ),

                                    Text(

                                      ad.description,

                                      maxLines:
                                      2,

                                      overflow:
                                      TextOverflow.ellipsis,

                                      textAlign:
                                      TextAlign.center,

                                      style:
                                      const TextStyle(

                                        color:
                                        Colors.white,

                                        fontSize:
                                        15,

                                      ),

                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(
                height: 10,
              ),

              Row(

                mainAxisAlignment:
                MainAxisAlignment.center,

                children: List.generate(

                  state.ads.length,

                      (index) {

                    final isActive =
                        currentIndex ==
                            index;

                    return AnimatedContainer(

                      duration:
                      const Duration(
                        milliseconds:
                        300,
                      ),

                      margin:
                      const EdgeInsets.symmetric(
                        horizontal:
                        4,
                      ),

                      width:
                      isActive
                          ? 20
                          : 10,

                      height:
                      8,

                      decoration:
                      BoxDecoration(

                        color:
                        isActive
                            ? Colors.black
                            : Colors.green,

                        borderRadius:
                        BorderRadius.circular(
                          20,
                        ),

                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }

        return const SizedBox();
      },
    );
  }
}