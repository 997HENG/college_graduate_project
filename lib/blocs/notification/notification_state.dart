part of 'notification_bloc.dart';

enum NotificationStatus {
  initial,
  inProgress,
  newNotifications,
  noNewNotifications,
}

@immutable
final class NotificationState extends Equatable {
  const NotificationState.started(User user)
      : this(
          user: user,
          status: NotificationStatus.initial,
          notifications: const [],
        );

  NotificationState.noNewNotifiaction(
    NotificationState previousState,
  ) : this(
          user: previousState.user,
          status: NotificationStatus.noNewNotifications,
          notifications: previousState.notifications,
        );

  NotificationState copyWith({
    User? user,
    NotificationStatus? status,
    List<Notification?>? notifications,
    String? error,
  }) =>
      NotificationState(
        user: user ?? this.user,
        status: status ?? this.status,
        notifications: notifications ?? this.notifications,
        error: error ?? this.error,
      );

  const NotificationState(
      {required this.user,
      required this.status,
      required this.notifications,
      this.error});

  final User user;
  final NotificationStatus status;
  final List<Notification?> notifications;
  final String? error;

  @override
  List<Object?> get props => [user, status, notifications, error];
}
