part of 'chat_bloc.dart';

enum ChatStatus {
  initial,
  loading,
  loaded,
}

@immutable
class ChatState extends Equatable {
  final String userUid;
  final String userName;
  final String friendUid;
  final String friendName;

  final ChatStatus status;
  final List<Chat?> chats;
  final bool onChat;
  final String? error;

  ChatState.initial(
    this.userUid,
    this.userName,
    this.friendUid,
    this.friendName,
  )   : status = ChatStatus.initial,
        chats = [],
        onChat = false,
        error = null;

  const ChatState({
    required this.userUid,
    required this.userName,
    required this.friendUid,
    required this.friendName,
    required this.status,
    required this.chats,
    required this.onChat,
    this.error,
  });

  ChatState copyWith({
    String? userUid,
    String? userName,
    String? friendUid,
    String? friendName,
    ChatStatus? status,
    List<Chat?>? chats,
    bool? onChat,
    String? error,
  }) {
    return ChatState(
      userUid: userUid ?? this.userUid,
      userName: userName ?? this.userName,
      friendUid: friendUid ?? this.friendUid,
      friendName: friendName ?? this.friendName,
      status: status ?? this.status,
      chats: chats ?? this.chats,
      onChat: onChat ?? this.onChat,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props =>
      [userUid, userName, friendUid, friendName, status, chats, onChat, error];
}
