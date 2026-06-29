import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mine/constants/app_text_styles.dart';
import 'package:mine/screens/home/presentation/view/service_details_form_screen.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';

import '../../../../widgets/custom_appbar.dart';
class ServiceDetailsScreen extends StatelessWidget {
  ServiceDetailsScreen({super.key, required this.serviceName});
  String serviceName = '';
  final List<Map<String, dynamic>> servicesDetails = [
    {'name': 'فروج', 'image': 'assets/chiken.png','id':7},
    {'name': 'بيض مائده', 'image': 'assets/egg.png','id':8},
    {'name': 'أمهات', 'image': 'assets/mothersChicken.png','id':9},
    {'name': 'جدات الفروج', 'image': 'assets/grandChickens.png','id':10},
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: SizedBox(),
           flexibleSpace: CustomAppBarWithTitle(serviceName: serviceName),
        ),
        body: ListView.builder(
          padding: EdgeInsets.only(top: 20.h),
            itemCount: servicesDetails.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: (){
                  Navigator.push(context, PageRouteBuilder(
                    pageBuilder: (_, __, ___) =>  ServiceDetailsFormPage(serviceType: servicesDetails[index]['name'],
                      subCategoryId: servicesDetails[index]['id'],),
                    transitionDuration: Duration(seconds: 1),
                    transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
                  ));
                },
                child: FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  delay: Duration(milliseconds: index * 100),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                    height: 180.h,
                    width: 350.w,
                    margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: Color(0xFFF5EFE2),
                      borderRadius: BorderRadius.circular(30),

                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                            alignment: Alignment.centerRight,
                            child: Image.asset('assets/background.png')),
                        index == 0||index==2
                            ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Text(
                                  servicesDetails[index]['name'].toString().replaceAll(' ', '\n'),
                                  style: AppTextStyles.boldBlack30
                                      .copyWith(fontSize: 30.sp, height: 1.8),
                                  textHeightBehavior: TextHeightBehavior(
                                    applyHeightToFirstAscent: true,
                                  ),
                                ),
                                SizedBox(
                                  width: 30.w,
                                ),
                                Image.asset(
                                  servicesDetails[index]['image'],
                                  width: 132.w,
                                  height: 126.h,
                                ),
                              ])
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    servicesDetails[index]['image'],
                                    width: 132.w,
                                    height: 126.h,
                                  ),
                                  SizedBox(
                                    width: 40.w,
                                  ),
                                  Text(
                                    servicesDetails[index]['name'].toString().replaceAll(' ', '\n'),
                                    style: AppTextStyles.boldBlack30
                                        .copyWith(fontSize: 30.sp),
                                  ),
                                  SizedBox(
                                    width: 40.w,
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }
}

