import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants/app_text_styles.dart';

class customRichText extends StatelessWidget {
  customRichText({
    super.key,
    required this.unFocusedText,
    required this.focusedText,
    required this.onTap,
  });
  String unFocusedText;
  String focusedText;
  void Function()?  onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Center(
        child: RichText(
          text: TextSpan(
            text: '',
            style: AppTextStyles.regularGrey15,
            children: <TextSpan>[
              TextSpan(
                text: unFocusedText,
                style: AppTextStyles.regularBlack12,
              ),
              TextSpan(text: focusedText, style: AppTextStyles.boldPrimary12),
            ],
          ),
        ),
      ),
    );
  }
}
