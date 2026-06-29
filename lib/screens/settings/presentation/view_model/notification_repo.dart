import 'notification_services.dart';

class NotificationRepository {
  final NotificationService service;

  NotificationRepository(this.service);

  Future<Map<String, dynamic>> fetchNotifications() {
    return service.fetchNotifications();
  }
}
