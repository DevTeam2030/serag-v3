import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mine/constants/app_colors.dart';

class AppTextStyles {
  static TextStyle _cairo({
    required double size,
    FontWeight weight = FontWeight.w400,
    Color color = Colors.black,
    double? height,
  }) {
    return TextStyle(
      fontFamily: 'Cairo',
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
    );
  }

  static TextStyle get heading => _cairo(
    size: 20.sp,
    weight: FontWeight.bold,
    color: Colors.black,
  );

  static TextStyle get paragraph => _cairo(
    size: 14.sp,
    color: Colors.black87,
    height: 1.5,
    weight: FontWeight.w400,
  );

  static TextStyle get skipText => _cairo(
    size: 14.sp,
    color: Colors.grey,
    weight: FontWeight.w500,
  );

  static TextStyle get boldGrey17 => _cairo(
    size: 17.sp,
    color: const Color(0xFF868889),
    weight: FontWeight.w700,
  );

  static TextStyle get regularGrey15 => _cairo(
    size: 15.sp,
    color: const Color(0xFF838BA1),
    weight: FontWeight.w400,
  );

  static TextStyle get regularBlack12 => _cairo(
    size: 12.sp,
    color: Colors.black,
    weight: FontWeight.w400,
  );

  static TextStyle get boldBlack30 => _cairo(
    size: 30.sp,
    color: Colors.black,
    weight: FontWeight.w700,
  );

  static TextStyle get semiboldBlack12 => _cairo(
    size: 12.sp,
    color: Colors.black,
    weight: FontWeight.w500,
  );

  static TextStyle get boldBlack18 => _cairo(
    size: 18.sp,
    color: Colors.black,
    weight: FontWeight.w700,
  );

  static TextStyle get boldWhite20 => _cairo(
    size: 20.sp,
    color: Colors.white,
    weight: FontWeight.w700,
  );

  static TextStyle get boldWhite16 => _cairo(
    size: 16.sp,
    color: Colors.white,
    weight: FontWeight.w700,
  );

  static TextStyle get boldPrimary12 => _cairo(
    size: 12.sp,
    color: AppColors.green,
    weight: FontWeight.w700,
  );

  static TextStyle get boldWhite12 => _cairo(
    size: 12.sp,
    color: AppColors.white,
    weight: FontWeight.w700,
  );

  static TextStyle get boldBlack12 => _cairo(
    size: 12.sp,
    color: AppColors.black,
    weight: FontWeight.w700,
  );
}
