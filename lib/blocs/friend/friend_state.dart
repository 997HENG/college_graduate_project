part of 'friend_bloc.dart';

enum FriendStatus {
  initial,
  listLoading,
  listLoaded,
}

@immutable
final class FriendState extends Equatable {
  const FriendState.started(User user)
      : this(
          user: user,
          status: FriendStatus.initial,
          previousSearch: '',
          friends: const [],
          results: const [],
        );

  FriendState copyWith({
    User? user,
    FriendStatus? status,
    String? previousSearch,
    List<User?>? friends,
    List<User?>? results,
    bool? action,
    String? error,
  }) =>
      FriendState(
        user: user ?? this.user,
        previousSearch: previousSearch ?? this.previousSearch,
        status: status ?? this.status,
        friends: friends ?? this.friends,
        results: results ?? this.results,
        action: action ?? this.action,
        error: error ?? this.error,
      );

  const FriendState({
    required this.user,
    required this.previousSearch,
    required this.status,
    required this.friends,
    required this.results,
    this.action,
    this.error,
  });

  final User user;
  final String previousSearch;
  final FriendStatus status;
  final List<User?> friends;
  final List<User?> results;
  final bool? action;
  final String? error;

  @override
  List<Object?> get props => [
        user,
        status,
        friends,
        results,
        action,
        error,
        previousSearch,
      ];
}
