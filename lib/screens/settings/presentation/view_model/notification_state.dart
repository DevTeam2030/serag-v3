abstract class NotificationState {}

class NotificationInitial extends NotificationState {}
class NotificationLoading extends NotificationState {}
class NotificationLoaded extends NotificationState {
  final List<dynamic> notifications;
  NotificationLoaded(this.notifications);
}
class NotificationError extends NotificationState {
  final String message;
  NotificationError(this.message);
}
class NotificationSeenLoading extends NotificationState {
}
class NotificationSeenSuccess extends NotificationState {
  final dynamic response;
  NotificationSeenSuccess(this.response);
}
class NotificationSeenError extends NotificationState {
  final String message;
  NotificationSeenError(this.message);
}
class NewNotificationReceived extends NotificationState {
  final dynamic notification;
  NewNotificationReceived(this.notification);
}