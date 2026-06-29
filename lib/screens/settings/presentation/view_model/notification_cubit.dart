import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mine/constants/app_text_styles.dart';
import 'package:workmanager/workmanager.dart';
import 'package:mine/core/helper/cache_helper.dart';
import 'package:mine/screens/settings/presentation/view_model/notification_services.dart';
import '../../../../constants/api_constants.dart';
import '../../../../main.dart';
import 'notification_repo.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository repository;
  final Dio _dio = Dio();
  final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();
  List<dynamic> _notifications = [];
  Timer? _pollingTimer;

  NotificationCubit(this.repository) : super(NotificationInitial()) {
    _initNotifications();
    _startPolling();
    _initBackgroundFetch();
    _dio.options = BaseOptions(
      validateStatus: (status) => status! >= 200 && status < 400,
      followRedirects: true,
      maxRedirects: 5,
    );
    _checkForNewAndPersistedNotifications();
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
    InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          final notif = _notifications.firstWhere(
                (n) => n['id'].toString() == response.payload,
            orElse: () => {},
          );
          if (notif.isNotEmpty) {
            _showNotificationDialog(
              navigatorKey.currentContext!,
              notif['not_title'] ?? "إشعار",
              notif['message'] ?? "",
            );
          }
        }
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> _initBackgroundFetch() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
    await Workmanager().registerPeriodicTask(
      "checkNotificationsTask",
      "checkNotifications",
      frequency: const Duration(minutes: 15),
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      await _checkForNewNotifications();
    });
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    Workmanager().cancelAll();
    return super.close();
  }

  Future<int> _getLastNotificationId() async {
    return CacheHelper.getData('last_notification_id') ?? 0;
  }

  Future<void> _setLastNotificationId(int id) async {
    await CacheHelper.saveData('last_notification_id', id);
  }

  Future<void> _checkForNewAndPersistedNotifications() async {
    emit(NotificationLoading());
    try {
      final List<dynamic> persistedNotifications =
          CacheHelper.getData('pending_notifications') ?? [];
      if (persistedNotifications.isNotEmpty) {
        for (var notif in persistedNotifications) {
          await _handleNewNotification(notif);
        }
        await CacheHelper.saveData('pending_notifications', []);
      }
      await _checkForNewNotifications();
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _checkForNewNotifications() async {
    try {
      final result = await repository.fetchNotifications();
      if (result['status'] == 200) {
        final List<dynamic> newData = result['data'];
        final int lastId = await _getLastNotificationId();

        final newNotifications = newData
            .where((n) => (n['id'] ?? 0) > lastId && n['status'] == 'new')
            .toList();

        _notifications = newData;
        emit(NotificationLoaded(_notifications));

        for (var notif in newNotifications) {
          await _handleNewNotification(notif);
        }
      } else {
        emit(NotificationError(result['message'] ?? "فشل تحميل الإشعارات"));
      }
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> loadNotifications({bool showAllUnread = false}) async {
    emit(NotificationLoading());
    try {
      final result = await repository.fetchNotifications();
      if (result['status'] == 200) {
        _notifications = result['data'];
        emit(NotificationLoaded(_notifications));

        if (showAllUnread) {
          final unreadNotifications =
          _notifications.where((n) => n['status'] != 'seen').toList();
          for (var notif in unreadNotifications) {
            await _showLocalNotification(
              notif['id'] ?? 0,
              notif['not_title'] ?? "إشعار جديد",
              notif['message'] ?? "",
            );
          }
        }
      } else {
        emit(NotificationError(result['message'] ?? "فشل تحميل الإشعارات"));
      }
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _handleNewNotification(dynamic notification) async {
    final int notifId = notification['id'] ?? 0;
    final int lastId = await _getLastNotificationId();

    if (notifId > lastId && notification['status'] == 'new') {
      await _showLocalNotification(
        notifId,
        notification['not_title'] ?? "إشعار جديد",
        notification['message'] ?? "",
      );
      await _setLastNotificationId(notifId);
      emit(NewNotificationReceived(notification));
    }
  }

  Future<void> markAsSeen(int notificationId) async {
    emit(NotificationLoading());
    try {
      final response = await _dio.post(
        "${ApiConstants.baseUrl}/notification-seen",
        data: {'notification_id': notificationId},
        options: Options(
          headers: {
            "Authorization": "Bearer ${CacheHelper.getToken()}",
            "Accept": "application/json",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        _notifications = _notifications.map((notif) {
          if (notif['id'] == notificationId) {
            return {...notif, 'status': 'seen'};
          }
          return notif;
        }).toList();
        emit(NotificationSeenSuccess(response.data));
        emit(NotificationLoaded(_notifications));
      } else {
        emit(NotificationSeenError("Failed with status ${response.statusCode}"));
      }
    } catch (e) {
      emit(NotificationSeenError(e.toString()));
    }
  }

  Future<void> _showLocalNotification(int id, String title, String body) async {
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
      styleInformation: BigTextStyleInformation(body),
      icon: '@mipmap/ic_launcher',
    );

    final details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      id,
      title,
      body,
      details,
      payload: id.toString(), // عشان نعرف انهارده النوتف دي
    );
  }

  /// فتح البوب أب بالرسالة كاملة
  void _showNotificationDialog(BuildContext context, String title, String body) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,

        child: AlertDialog(
          backgroundColor: Colors.white,
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child:  Text("إغلاق",style:
                AppTextStyles.boldPrimary12
                ,),
            ),
          ],
        ),
      ),
    );
  }
}

@pragma('vm:entry-point')
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
          const initSettings = InitializationSettings(android: androidSettings);
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
              styleInformation: BigTextStyleInformation(
                notif['message'] ?? "",
                contentTitle: notif['not_title'] ?? "إشعار جديد",
              ),
              icon: '@mipmap/ic_launcher',
            );
            final details = NotificationDetails(android: androidDetails);
            await localNotifications.show(
              notif['id'] ?? 0,
              notif['not_title'] ?? "إشعار جديد",
              notif['message'] ?? "",
              details,
              payload: (notif['id'] ?? 0).toString(),
            );

            pendingNotifications.add(notif);
            await CacheHelper.saveData(
                'last_notification_id', notif['id'] ?? 0);
          }
          await CacheHelper.saveData(
              'pending_notifications', pendingNotifications);
        }
      }
    } catch (e) {}
    return Future.value(true);
  });
}

