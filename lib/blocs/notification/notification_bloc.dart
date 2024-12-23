import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:cloud_storage_repository/cloud_storage_repository.dart';
import 'package:storage/storage.dart' show Notification, User;
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart' show immutable;

part 'notification_event.dart';
part 'notification_state.dart';

final class NotificationBloc
    extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc(User user, {CloudStorageRepository? cloud})
      : _cloud = cloud ?? FirestoreCloudStorageRepository.instace,
        super(NotificationState.started(user)) {
    on<NotificationStarted>(
      _handleStarted,
      transformer: restartable(),
    );

    on<NotificationOrphanCleaned>(
      _handleOrphanCleaned,
      transformer: droppable(),
    );

    on<NotificationTabPressed>(
      _handleTabPressed,
      transformer: droppable(),
    );

    on<NotificationFriendResponded>(
      _handleFriendsResponded,
      transformer: droppable(),
    );
  }

  Future<void> _handleStarted(
    NotificationStarted _,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(status: NotificationStatus.inProgress));
    await emit
        .forEach(
      _cloud.notificationsChange(state.user),
      onData: (newNotifications) => switch (newNotifications.length) {
        0 => state.copyWith(
            status: NotificationStatus.noNewNotifications,
            notifications: [],
          ),
        _ => state.copyWith(
            status: NotificationStatus.newNotifications,
            notifications: newNotifications,
          ),
      },
    )
        .onError(
      (e, _) {
        final error = switch (e) {
          CloudException e => e.message,
          _ => 'unknown exception: ${e.toString()}',
        };

        emit(
          state.copyWith(
            error: error,
          ),
        );
      },
    );
  }

  Future<void> _handleOrphanCleaned(
    NotificationOrphanCleaned _,
    Emitter<NotificationState> emit,
  ) async {
    try {
      _cloud.cleanOrphanNotification(state.user);
    } catch (e) {
      emit(
        state.copyWith(
          error: 'failed to clean orphan notification: ${e.toString()}',
        ),
      );
    }
  }

  void _handleTabPressed(
    NotificationTabPressed _,
    Emitter<NotificationState> emit,
  ) =>
      emit(NotificationState.noNewNotifiaction(state));

  Future<void> _handleFriendsResponded(NotificationFriendResponded event,
      Emitter<NotificationState> emit) async {
    try {
      await _cloud.friendResponse(event.sender, event.receiver, event.response);
    } catch (e) {
      final error = switch (e) {
        CloudException e => e.message,
        _ => 'unknown exception: ${e.toString()}',
      };

      emit(
        state.copyWith(
          status: state.status,
          error: error,
        ),
      );
    }
  }

  final CloudStorageRepository _cloud;
}
