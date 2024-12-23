part of 'chat_bloc.dart';

@immutable
sealed class ChatEvent {
  const ChatEvent();
}

final class ChatStarted extends ChatEvent {
  const ChatStarted();
}

final class ChatFriendOnlined extends ChatEvent {
  const ChatFriendOnlined();
}

final class ChatMessageSent extends ChatEvent {
  const ChatMessageSent(this.body);

  final String body;
}

final class ChatOpend extends ChatEvent {
  const ChatOpend();
}

final class ChatLeft extends ChatEvent {
  const ChatLeft();
}
