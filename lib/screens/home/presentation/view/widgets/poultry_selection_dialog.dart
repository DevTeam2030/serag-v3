// widgets/poultry_selection_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../constants/app_text_styles.dart';
import '../../../../../widgets/custom_button.dart';
import '../service_details_screen.dart';

class PoultrySelectionDialog extends StatefulWidget {
  final String categoryName;

  const PoultrySelectionDialog({
    Key? key,
    required this.categoryName,
  }) : super(key: key);

  @override
  State<PoultrySelectionDialog> createState() => _PoultrySelectionDialogState();
}

class _PoultrySelectionDialogState extends State<PoultrySelectionDialog> {
  int? selectedPoultryType;

  final List<Map<String, dynamic>> poultryTypes = [
    {'id': 1, 'name': 'مدجنة 1', 'image': 'assets/white_chicken.png'},
    {'id': 2, 'name': 'مدجنة 2', 'image': 'assets/white_chicken.png'},
    {'id': 3, 'name': 'مدجنة 3', 'image': 'assets/white_chicken.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'اختر نوع المدجنة',
              style: AppTextStyles.boldBlack30.copyWith(fontSize: 22.sp),
            ),
            SizedBox(height: 24.h),

            // Poultry type selection
            ...poultryTypes.map((type) {
              final isSelected = selectedPoultryType == type['id'];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedPoultryType = type['id'];
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: isSelected ? Color(0xFFDDCBA0) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Color(0xFF2E6E4C) : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        type['image'],
                        width: 40.w,
                        height: 40.h,
                      ),
                      SizedBox(width: 16.w),
                      Text(
                        type['name'],
                        style: AppTextStyles.boldGrey17.copyWith(
                          color: Colors.black,
                          fontSize: 18.sp,
                        ),
                      ),
                      Spacer(),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: Color(0xFF2E6E4C),
                          size: 24.w,
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),

            SizedBox(height: 24.h),

            CustomButton(
              title: 'تأكيد',
              withShadow: false,
              onPressed:(){
                selectedPoultryType == null
                    ? null:
                Navigator.pop(context);
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => ServiceDetailsScreen(
                      serviceName: widget.categoryName,
                    ),
                    transitionDuration: Duration(seconds: 1),
                    transitionsBuilder: (_, a, __, c) =>
                        FadeTransition(opacity: a, child: c),
                  ),
                );

              }
            ),
          ],
        ),
      ),
    );
  }
}