part of 'tab_bloc.dart';

@immutable
sealed class TabEvent {
  const TabEvent();
}

final class TabMainPressed extends TabEvent {
  const TabMainPressed();
}

final class TabFriendsPressed extends TabEvent {
  const TabFriendsPressed();
}

final class TabGroupPressed extends TabEvent {
  const TabGroupPressed();
}

final class TabNotificationsPressed extends TabEvent {
  const TabNotificationsPressed();
}
