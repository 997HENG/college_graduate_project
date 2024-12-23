part of 'notification_bloc.dart';

@immutable
sealed class NotificationEvent {
  const NotificationEvent();
}

final class NotificationStarted extends NotificationEvent {
  const NotificationStarted();
}

final class NotificationOrphanCleaned extends NotificationEvent {
  const NotificationOrphanCleaned();
}

final class NotificationTabPressed extends NotificationEvent {
  const NotificationTabPressed();
}

final class NotificationFriendResponded extends NotificationEvent {
  const NotificationFriendResponded(this.sender, this.receiver, this.response);

  final String sender;
  final String receiver;

  final bool response;
}
