import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mine/constants/app_text_styles.dart';
import '../constants/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  bool withShadow = true;
  double? width ;
  double? height ;
  double? radius ;
  TextStyle? style;
  final Color? backgroundColor ;
  bool? withBorder = false;
  bool? withPadding = false;
bool isLoading = false;
  CustomButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.withShadow = true,
    this.width,
    this.height,
    this.style,
    this.backgroundColor,
    this.radius,
     this.withBorder
    , this.withPadding = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height:height?? 60.h,
        width:width?? 380.w,
        padding: withPadding==true? EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h): null,
        decoration: BoxDecoration(
          color:backgroundColor?? AppColors.green,
          borderRadius: BorderRadius.circular(radius??8),
          border:withBorder==true? Border.all(color: AppColors.green,width: 2):null,
          boxShadow:withShadow==true? [
            BoxShadow(
              color: AppColors.green.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, 4), // shadow position
            ),
          ]: [],
        ),
        alignment: Alignment.center,
        child: isLoading==true?SpinKitThreeInOut(color: Colors.white,size: 12.h,) :Text(
          title,
          style:style?? AppTextStyles.boldWhite20,
        ),
      ),
    );
  }
}