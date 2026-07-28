import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mine/constants/app_colors.dart';
import 'package:mine/widgets/custom_image.dart';

import '../../../auth/register/presentation/view/widgets/register_header.dart';
import '../view_model/ads_cubit.dart';
import '../view_model/ads_state.dart';
import 'add_details_screen.dart';

class AdsScreen extends StatefulWidget {
  const AdsScreen({
    super.key,
  });

  @override
  State<AdsScreen> createState() => _AdsScreenState();
}

class _AdsScreenState extends State<AdsScreen> {
  @override
  void initState() {
    super.initState();

    context.read<AdsCubit>().loadAds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(


      body: Column(
        children: [
          SizedBox(height: 30.h,),
          CustomHeader(title: 'الإعلانات',showBack: false),
          SizedBox(height: 20,),
          Expanded(
            child: BlocBuilder<AdsCubit, AdsState>(
              builder: (context, state) {
                if (state is AdsLoading) {
                  return const Center(
                    child: SpinKitWave(color: AppColors.green),
                  );
                }
            
                if (state is AdsLoaded) {
                  if (state.ads.isEmpty) {
                    return const _EmptyAdsWidget();
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(
                      16,
                    ),
                    itemCount: state.ads.length,
                    itemBuilder: (context, index) {
                      final ad = state.ads[index];
            
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
                        child: Card(
                          margin: const EdgeInsets.only(
                            bottom: 16,
                          ),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(
                                    12,
                                  ),
                                ),
                                child: cachedImage(
                                  ad.images.first,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(
                                  16,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ad.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      ad.description,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const Divider(height: 30,),
                                    Row(
                                      children: [
                                        Text(
                                          'اقرأ المزيد',
                                          style: TextStyle(
                                            color: Colors.green,
                                          ),
                                        ),
                                        SizedBox(width: 5,),
                                        Icon(Icons.arrow_forward_ios,size: 15,color: AppColors.green,),
            
                                      ],
                                    )
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
            
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}



class _EmptyAdsWidget extends StatelessWidget {
  const _EmptyAdsWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.campaign_outlined,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 20),
            Text(
              'لا توجد إعلانات حتى الآن',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'سيتم عرض الإعلانات الجديدة بمجرد إضافتها.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
