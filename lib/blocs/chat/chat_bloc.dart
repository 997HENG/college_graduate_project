import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:cloud_storage_repository/cloud_storage_repository.dart';
import 'package:meta/meta.dart' show immutable;
import 'package:equatable/equatable.dart';
import 'package:storage/storage.dart';

part 'chat_event.dart';
part 'chat_state.dart';

final class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc(
    String userUid,
    String userName,
    String friendUid,
    String friendName, {
    CloudStorageRepository? cloud,
  })  : _cloud = cloud ?? FirestoreCloudStorageRepository.instace,
        super(
          ChatState.initial(
            userUid,
            userName,
            friendUid,
            friendName,
          ),
        ) {
    on<ChatStarted>(
      _handleStarted,
      transformer: restartable(),
    );

    on<ChatFriendOnlined>(
      _handleFriendOnlined,
      transformer: restartable(),
    );

    on<ChatMessageSent>(
      _handleMessageSent,
      transformer: sequential(),
    );

    on<ChatOpend>(
      _handleOpend,
      transformer: restartable(),
    );
  }

  Future<void> _handleStarted(
    ChatStarted event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(status: ChatStatus.loading));

    await emit
        .forEach(
      _cloud.chatChange(state.userUid, state.friendUid),
      onData: (newChats) => state.copyWith(
        status: ChatStatus.loaded,
        chats: newChats,
      ),
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

  Future<void> _handleFriendOnlined(
    ChatFriendOnlined event,
    Emitter<ChatState> emit,
  ) async {
    await emit
        .forEach(
      _cloud.realTimeOnline(state.userUid, state.friendUid),
      onData: (onChat) => state.copyWith(onChat: onChat),
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

  Future<void> _handleMessageSent(
    ChatMessageSent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await Future.wait(
        [
          _cloud.sendMessage(state.userUid, state.friendUid, event.body),
          _cloud.sendChatNotification(
            state.userUid,
            state.userName,
            state.friendUid,
          )
        ],
      );
    } catch (e) {
      final error = switch (e) {
        CloudException e => e.message,
        _ => 'unknown exception: ${e.toString()}',
      };

      emit(
        state.copyWith(
          error: error,
        ),
      );
    }
  }

  Future<void> _handleOpend(
    ChatOpend _,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _cloud.openChat(state.userUid, state.friendUid, state.friendName);
    } catch (e) {
      final error = switch (e) {
        CloudException e => e.message,
        _ => 'unknown exception: ${e.toString()}',
      };

      emit(
        state.copyWith(
          error: error,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    unawaited(
      _cloud.leaveChat(state.userUid, state.friendUid),
    );
    return super.close();
  }

  final CloudStorageRepository _cloud;
}
