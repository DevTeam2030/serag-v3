import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mine/bottom_nav.dart';
import 'package:mine/core/helper/cache_helper.dart';
import 'package:mine/core/services/session_manager.dart';
import 'package:mine/screens/auth/register/presentation/view_model/building_info_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mine/constants/app_colors.dart';
import 'package:mine/constants/app_text_styles.dart';
import 'package:mine/screens/onboarding.dart';
import 'package:mine/screens/auth/login/presentation/view/login_screen.dart';

import '../auth/login/presentation/view_model/login_cubit.dart';
import '../auth/login/presentation/view_model/login_repo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _imageController;
  late AnimationController _text1Controller;
  late AnimationController _text2Controller;

  @override
  void initState() {
    super.initState();

    _imageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _text1Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _text2Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Start animations with delay
    _imageController.forward();
    Timer(const Duration(seconds: 1), () {
      _text1Controller.forward();
    });
    Timer(const Duration(seconds: 2), () {
      _text2Controller.forward();
    });

    // Navigate after splash
    Timer(const Duration(seconds: 4), _navigateNext);
  }

  Future<void> _navigateNext() async {
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    final bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
    final String? token = CacheHelper.getToken();

    Widget nextScreen;

    if (!hasSeenOnboarding) {
      nextScreen = const OnboardingScreen();
    } else if (token != null && token.isNotEmpty) {
      final projectDataCubit = context.read<ProjectDataCubit>();
      await projectDataCubit.fetchSettings();
      if (!mounted) return;

      final inactivityDays = SessionManager.parseInactivityDays(
        projectDataCubit.settingsData?.inactivityDays,
      );
      final expired = await SessionManager.isSessionExpired(inactivityDays);

      if (expired) {
        if (mounted) {
          await SessionManager.logout(context);
        }
        return;
      }

      nextScreen = BottomNav();
    } else {
      nextScreen = BlocProvider(
        create: (_) => LoginCubit(repository: LoginRepository()),
        child: LoginScreen(),
      );
    }

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => nextScreen,
        transitionDuration: const Duration(seconds: 1),
        transitionsBuilder: (_, a, __, c) =>
            FadeTransition(opacity: a, child: c),
      ),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _imageController.dispose();
    _text1Controller.dispose();
    _text2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _imageController,
              child: Image.asset(
                'assets/logo.png',
                width: 330.w,
              ),
            ),
            const SizedBox(height: 10),
            FadeTransition(
              opacity: _text1Controller,
              child: Text(
                " المؤسسة العامة للدواجن",
                style: AppTextStyles.boldPrimary12.copyWith(fontSize: 15.sp),
              ),
            ),
            const SizedBox(height: 10),
            FadeTransition(
              opacity: _text2Controller,
              child: Text(
                "تطبيق سراج",
                style: AppTextStyles.boldWhite16.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkYellow,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
