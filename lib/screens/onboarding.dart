import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mine/screens/auth/login/presentation/view/login_screen.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../widgets/custom_button.dart';
import '../widgets/onboarding_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> onboardingData = [
    {
      'image': 'assets/onboarding.png',
      'title': 'مرحباً بكم في تطبيق سراج',
      'desc': 'حيث تلتقي تربية الدواجن بالعناية والجودة \nتُربى طبيعيًا، وتكون أفضل طبيعيًا',
    },
    {
      'image': 'assets/onboarding2.png',
      'title': ' دواجن تُرعي طبيعيًا',
      'desc': 'نحن نؤمن بالزراعة النظيفة والصحية.\n تُربى طيورنا في بيئات خضراء ومفتوحة..',
    },
    {
      'image': 'assets/onboarding3.png',
      'title': ' اكتشف الآن',
      'desc': 'انضم إلينا لتكتشف تجربة جديدة في \nتربية الدواجن',
    },
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => LoginScreen(),
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  void _nextPage() {
    if (_currentIndex < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: AppColors.white,
        body: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.83,
              child: PageView.builder(
                controller: _pageController,
                itemCount: onboardingData.length,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Expanded(
                        child: ClipPath(
                          clipper: CustomCurveClipper(),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(onboardingData[index]['image']!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        onboardingData[index]['title']!,
                        style: AppTextStyles.boldBlack30.copyWith(fontSize: 30.sp),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 30.h),
                      Text(
                        onboardingData[index]['desc']!,
                        style: AppTextStyles.boldGrey17.copyWith(fontSize: 17.sp, height: 2),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          onboardingData.length,
                              (dotIndex) => Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: OnboardingIndicator(
                              isActive: _currentIndex == dotIndex,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 25.h),
              child: CustomButton(
                title: _currentIndex == onboardingData.length - 1
                    ? 'ابدأ الآن'
                    : 'التالي',
                onPressed: _nextPage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double w = size.width;
    double h = size.height;
    Path path = Path();
    path.lineTo(0, h);
    path.quadraticBezierTo(w * 0.5, h - 100.h, w, h);
    path.lineTo(w, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
