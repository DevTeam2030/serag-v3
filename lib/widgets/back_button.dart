import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BkBtn extends StatelessWidget {
  const BkBtn({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
        onPressed: () => Navigator.canPop(context)? Navigator.pop(context):null,
      ),
    );
  }
}
