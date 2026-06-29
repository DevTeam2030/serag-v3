import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mine/core/helper/cache_helper.dart';
import 'package:mine/main.dart';
import 'package:mine/screens/auth/login/presentation/view/login_screen.dart';
import 'package:mine/screens/auth/login/presentation/view_model/login_cubit.dart';
import 'package:mine/screens/auth/login/presentation/view_model/login_repo.dart';

class SessionManager {
  static const String lastLoginDateKey = 'last_login_date';

  static int? parseInactivityDays(String? inactivityDays) {
    if (inactivityDays == null || inactivityDays.trim().isEmpty) {
      return null;
    }
    return int.tryParse(inactivityDays.trim());
  }

  static Future<void> saveLastLoginDate() async {
    await CacheHelper.saveData(
      lastLoginDateKey,
      DateTime.now().toIso8601String(),
    );
  }

  static Future<bool> isSessionExpired(int? inactivityDays) async {
    if (inactivityDays == null) {
      return false;
    }

    final lastLoginDateRaw = CacheHelper.getData(lastLoginDateKey);

    if (lastLoginDateRaw == null) {
      await saveLastLoginDate();
      return false;
    }

    try {
      final lastLoginDate = DateTime.parse(lastLoginDateRaw.toString());
      final difference = DateTime.now().difference(lastLoginDate).inDays;
      return difference >= inactivityDays;
    } catch (_) {
      await saveLastLoginDate();
      return false;
    }
  }

  static Future<void> logout(BuildContext? context) async {
    await CacheHelper.clearData();
    await CacheHelper.removeToken();
    await CacheHelper.saveData('hasSeenOnboarding', true);

    final navigationContext = context ?? navigatorKey.currentContext;
    if (navigationContext == null || !navigationContext.mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      navigationContext,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => LoginCubit(repository: LoginRepository()),
          child: LoginScreen(),
        ),
      ),
      (route) => false,
    );
  }
}
