import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mine/screens/auth/login/presentation/view/login_screen.dart';

import '../../../../../../constants/app_text_styles.dart';
import '../../../../../../widgets/back_button.dart';

class RegisterHeader extends StatelessWidget {
  final String title;
  const RegisterHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10.h), // ✅ instead of MediaQuery
        if (Navigator.canPop(context))
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 40), // To balance back button space
              BkBtn(),
            ],
          ),
        SizedBox(height: 12.h),
        SizedBox(
          width: 0.8.sw, // ✅ use ScreenUtil width instead of MediaQuery
          child: Text(
            title,
            style: AppTextStyles.boldBlack30.copyWith(fontSize: 25.sp),
          ),
        ),
      ],
    );
  }
}

class CustomHeader extends StatelessWidget {
  final String title;
  final bool showBack;
  final bool hasAnotherBack;
  const CustomHeader({
    super.key,
    required this.title,
    this.showBack = false,
    this.hasAnotherBack = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Spacer(),
          Text(
            title,
            style: AppTextStyles.boldBlack30.copyWith(fontSize: 25.sp),
          ),
          const Spacer(),
          hasAnotherBack
          ==false?
          showBack ==true? BkBtn() : const SizedBox()
          :
          Container(
            height: 40.w,
            width: 40.w,
            decoration: BoxDecoration(
              border:
              Border.all(color: Colors.grey.withOpacity(.2)),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: IconButton(
              icon:  Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.black, size: 20.h),
              onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) =>  LoginScreen()),
                    (Route<dynamic> route) => false,
              ),
            ),
          )
        ],
      ),
    );
  }
}
