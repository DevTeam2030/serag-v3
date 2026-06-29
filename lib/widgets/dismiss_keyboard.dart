import 'package:flutter/cupertino.dart';

class DismissKeyboard extends StatelessWidget {
  final Widget child;
  const DismissKeyboard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {



        WidgetsBinding.instance.addPostFrameCallback((_) {
          FocusManager.instance.primaryFocus?.unfocus();
        });

        // FocusManager.instance.primaryFocus?.unfocus(); // يقفل الكيبورد + يشيل الفوكس
      },
      behavior: HitTestBehavior.translucent,
      child: child,
    );
  }
}
