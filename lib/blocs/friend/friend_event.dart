part of 'friend_bloc.dart';

@immutable
sealed class FriendEvent {
  const FriendEvent();
}

final class FriendChanged extends FriendEvent {
  const FriendChanged();
}

final class FriendRequested extends FriendEvent {
  const FriendRequested(this.receiver);
  final String receiver;
}

final class FriendClearSearch extends FriendEvent {
  const FriendClearSearch();
}

final class FriendSearched extends FriendEvent {
  const FriendSearched(this.name);
  final String name;
}
