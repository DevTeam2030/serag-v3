import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mine/widgets/back_button.dart';

import '../constants/app_text_styles.dart';

class CustomAppBarWithTitle extends StatelessWidget {
  const CustomAppBarWithTitle({
    super.key,
    required this.serviceName,
    this.titleSize
  });

  final String serviceName;
   final double? titleSize;
  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
automaticallyImplyLeading: false,
      surfaceTintColor: Colors.white,
      backgroundColor: Colors.white,
      centerTitle: true,
      title: Text(
        serviceName,
        style: AppTextStyles.boldBlack30.copyWith(fontSize:titleSize?? 30.sp),
      ),
      actions:
     [
  Padding(
      padding: EdgeInsets.only(left: 16.w, right: 16.w),
      child: BkBtn())
]



    );
  }
}
