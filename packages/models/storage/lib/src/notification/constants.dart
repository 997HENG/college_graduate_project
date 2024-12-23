part of 'notification.dart';

final class NotificationField {
  static const uid = 'uid';
  static const senderUid = 'sender_uid';
  static const receiverUid = 'receiver_uid';
  static const type = 'type';
  static const senderName = 'sender_name';
  static const onChat = 'on_chat';
  static const timeStamp = 'time_stamp';
}

final class NotificationType {
  static const friendRequest = 'friend_request';
  static const room = 'room';
  static const chat = 'chat';
}
