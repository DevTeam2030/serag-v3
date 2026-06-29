import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mine/core/helper/cache_helper.dart';
import 'package:mine/screens/ads/data/ads_service.dart';
import 'package:mine/screens/ads/data/home_ads_service.dart';
import 'package:mine/screens/ads/presentation/view_model/ad_details_cubiit.dart';
import 'package:mine/screens/ads/presentation/view_model/ads_cubit.dart';
import 'package:mine/screens/ads/presentation/view_model/ads_repository.dart';
import 'package:mine/screens/ads/presentation/view_model/home_ads_cubit.dart';
import 'package:mine/screens/ads/presentation/view_model/home_ads_repository.dart';
import 'package:mine/screens/auth/login/presentation/view/login_screen.dart';
import 'package:mine/screens/auth/login/presentation/view_model/login_cubit.dart';
import 'package:mine/screens/auth/login/presentation/view_model/login_repo.dart';
import 'package:mine/screens/auth/register/presentation/view/add_location_screen.dart';
import 'package:mine/screens/auth/register/presentation/view_model/building_info_cubit.dart';
import 'package:mine/screens/auth/register/presentation/view_model/register_cubit.dart';
import 'package:mine/screens/home/presentation/view_model/establishment_cubit.dart';
import 'package:mine/screens/home/presentation/view_model/establishment_repo.dart';
import 'package:mine/screens/home/presentation/view_model/establishment_service.dart';
import 'package:mine/screens/home/presentation/view_model/section_request_cubit.dart';
import 'package:mine/screens/home/presentation/view_model/section_request_repo.dart';
import 'package:mine/screens/home/presentation/view_model/section_request_service.dart';
import 'package:mine/screens/onboarding.dart';
import 'package:mine/screens/prices/data/prices_service.dart';
import 'package:mine/screens/prices/presentation/view_model/prices_cubit.dart';
import 'package:mine/screens/prices/presentation/view_model/prices_repository.dart';
import 'package:mine/screens/projects/data/edit_project_service.dart';
import 'package:mine/screens/projects/data/project_service.dart';
import 'package:mine/screens/projects/presentation/view_model/edit_project_cubit.dart';
import 'package:mine/screens/projects/presentation/view_model/edit_project_repo.dart';
import 'package:mine/screens/projects/presentation/view_model/projects_cubit.dart';
import 'package:mine/screens/projects/presentation/view_model/projects_repo.dart';
import 'package:mine/screens/settings/presentation/view_model/notification_cubit.dart';
import 'package:mine/screens/settings/presentation/view_model/notification_repo.dart';
import 'package:mine/screens/settings/presentation/view_model/notification_services.dart';
import 'package:mine/screens/settings/presentation/view_model/notification_state.dart';
import 'package:mine/screens/settings/presentation/view_model/update_profile_cubit.dart';
import 'package:mine/screens/splash/splash_screen.dart';
import 'package:mine/widgets/dismiss_keyboard.dart';
import 'package:mine/widgets/internet_loss_connection_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';
import 'package:workmanager/workmanager.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await CacheHelper.init();
      final repo = NotificationRepository(NotificationService());
      final result = await repo.fetchNotifications();

      if (result['status'] == 200) {
        final List<dynamic> notifications = result['data'];
        final int lastId = CacheHelper.getData('last_notification_id') ?? 0;

        final newNotifications = notifications
            .where((n) => (n['id'] ?? 0) > lastId && n['status'] == 'new')
            .toList();

        if (newNotifications.isNotEmpty) {
          final localNotifications = FlutterLocalNotificationsPlugin();
          const androidSettings =
              AndroidInitializationSettings('@mipmap/ic_launcher');
          const iosInit = DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );
          const initSettings = InitializationSettings(
              iOS: iosInit,
              android: androidSettings

          );
          await localNotifications.initialize(initSettings);

          List<dynamic> pendingNotifications =
              CacheHelper.getData('pending_notifications') ?? [];
          for (var notif in newNotifications) {
            final androidDetails = AndroidNotificationDetails(
              'serag_channel_id',
              'Serag Notifications',
              channelDescription: 'Notifications for Serag app',
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
              color: const Color(0xFF4CAF50),
              enableLights: true,
              ledColor: const Color(0xFF4CAF50),
              ledOnMs: 1000,
              ledOffMs: 500,
              icon: '@mipmap/ic_launcher',
            );
            final platformDetails =
                NotificationDetails(android: androidDetails);
            await localNotifications.show(
              notif['id'] ?? 0,
              notif['message'] ?? "إشعار جديد",
              notif['body'] ?? "",
              platformDetails,
            );

            pendingNotifications.add(notif);
            await CacheHelper.saveData(
                'last_notification_id', notif['id'] ?? 0);
          }
          await CacheHelper.saveData(
              'pending_notifications', pendingNotifications);
        }
      }
    } catch (e) {
      // Log error
    }
    return Future.value(true);
  });
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1️⃣ Initialize local cache safely
  try {
    await CacheHelper.init();
  } catch (e) {
    toastification.show(
        context: navigatorKey.currentContext!,
        title: Text("خطأ في تهيئة التخزين المحلي"),
        type: ToastificationType.error);
    debugPrint("CacheHelper init failed: $e");
  }

  // 2️⃣ Initialize notifications
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosInit = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const initSettings = InitializationSettings(
    android: androidInit,
    iOS: iosInit,
  );
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // 3️⃣ Initialize WorkManager *after* everything else
  try {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  } catch (e) {
    toastification.show(
        context: navigatorKey.currentContext!,
        title: Text("خطأ في تهيئة إدارة المهام الخلفية"),
        type: ToastificationType.error);
    debugPrint("CacheHelper init failed: $e");
    debugPrint("WorkManager init failed: $e");
  }

  // 4️⃣ Continue with app setup
  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MyApp(hasSeenOnboarding: hasSeenOnboarding));
}

class MyApp extends StatelessWidget {
  final bool hasSeenOnboarding;
  MyApp({super.key, required this.hasSeenOnboarding});

  final ProjectsRepository repository = ProjectsRepository(
    service: ProjectsServiceApi(),
  );
  final editProjectRepository = EditProjectRepository(
    service: EditProjectService(),
  );

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProjectsCubit>(
          create: (_) => ProjectsCubit(repository: repository)..load(),
        ),
        BlocProvider<EditProjectCubit>(
          create: (_) => EditProjectCubit(editProjectRepository),
        ),
        BlocProvider<LoginCubit>(
          create: (_) => LoginCubit(repository: LoginRepository()),
        ),
        BlocProvider<RegisterCubit>(
          create: (_) => RegisterCubit(),
        ),
        BlocProvider<ProjectDataCubit>(
          create: (_) => ProjectDataCubit()..fetchSettings(),
        ),
        BlocProvider<NotificationCubit>(
          create: (_) =>
              NotificationCubit(NotificationRepository(NotificationService())),
        ),
        BlocProvider<SectionRequestCubit>(
          create: (_) =>
              SectionRequestCubit(),
        ),
        BlocProvider<UpdateProfileCubit>(
          create: (_) =>
              UpdateProfileCubit(),
        ),
        BlocProvider<EstablishmentCubit>(
          create: (_) =>
              EstablishmentCubit(EstablishmentRepository(EstablishmentService())),
        ),
        BlocProvider<PricesCubit>(
          create: (_) =>
              PricesCubit(repository: PricesRepository(service: PricesServiceApi())),
        ),
        BlocProvider<HomeAdsCubit>(
          create: (_) =>
              HomeAdsCubit(repository: HomeAdsRepository(service: HomeAdsServiceApi())),
        ),
        BlocProvider<AdsCubit>(
          create: (_) =>
              AdsCubit(repository: AdsRepository(service: AdsServiceApi())),
        ),
        BlocProvider<AdDetailsCubit>(
          create: (_) =>
              AdDetailsCubit(repository: AdsRepository(service: AdsServiceApi())),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) => MaterialApp(
          navigatorKey: navigatorKey,
          // builder: (context, widget) {
          //   return BlocBuilder<NotificationCubit, NotificationState>(
          //     builder: (context, state) {
          //       return ToastificationWrapper(
          //         child: widget ?? const SizedBox.shrink(),
          //       );
          //     },
          //   );
          // },
          debugShowCheckedModeBanner: false,
          title: 'Serag',
          theme: ThemeData(fontFamily: "Cairo"),
          // supportedLocales: const [Locale('ar'), Locale('en')],
          home: const SplashScreen(), // ✅ Put home here instead
        ),
      ),
    );
  }
}
