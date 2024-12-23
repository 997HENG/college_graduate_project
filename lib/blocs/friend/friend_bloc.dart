import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:cloud_storage_repository/cloud_storage_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart' show immutable;
import 'package:rxdart/rxdart.dart' show DebounceExtensions;
import 'package:equatable/equatable.dart';
import 'package:storage/storage.dart';

part 'friend_event.dart';
part 'friend_state.dart';

final class FriendBloc extends Bloc<FriendEvent, FriendState> {
  FriendBloc(User user, {CloudStorageRepository? cloud})
      : _cloud = cloud ?? FirestoreCloudStorageRepository.instace,
        super(FriendState.started(user)) {
    on<FriendClearSearch>(
      _handleClearSearch,
      transformer: concurrent(),
    );

    on<FriendChanged>(
      _handleStarted,
      transformer: restartable(),
    );

    on<FriendRequested>(
      _handleRequested,
      transformer: droppable(),
    );

    on<FriendSearched>(
      _handleSearched,
      transformer: debounceRestartable(const Duration(seconds: 1)),
    );
  }

  Future<void> _handleStarted(
    FriendChanged _,
    Emitter<FriendState> emit,
  ) async {
    emit(state.copyWith(status: FriendStatus.listLoading));
    await emit
        .forEach(
      _cloud.friendsChange(state.user),
      onData: (friends) => state.copyWith(
        status: FriendStatus.listLoaded,
        friends: friends,
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

  Future<void> _handleRequested(
    FriendRequested event,
    Emitter<FriendState> emit,
  ) async {
    try {
      await _cloud.friendRequest(
        state.user,
        event.receiver,
      );
      emit(
        state.copyWith(action: true),
      );
    } on CloudException catch (e) {
      emit(
        state.copyWith(
          action: false,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> _handleSearched(
    FriendSearched event,
    Emitter<FriendState> emit,
  ) async {
    if (state.previousSearch != event.name) {
      try {
        final results = await _cloud.searchFriend(state.user, event.name);

        emit(
          state.copyWith(results: results),
        );
      } catch (e) {
        final error = switch (e) {
          CloudException e => e.message,
          _ => 'unknown exception: ${e.toString()}',
        };

        emit(
          state.copyWith(
            results: [],
            error: error,
          ),
        );
      }
    }
    emit(state.copyWith(previousSearch: event.name));
  }

  Future<void> _handleClearSearch(
    FriendClearSearch _,
    Emitter<FriendState> emit,
  ) async {
    emit(
      state.copyWith(results: [], previousSearch: ''),
    );
  }

  EventTransformer<FriendEvent> debounceRestartable<FriendEvent>(
    Duration duration,
  ) =>
      (events, mapper) => restartable<FriendEvent>()
          .call(events.debounceTime(duration), mapper);

  final CloudStorageRepository _cloud;
}
