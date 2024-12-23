import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart' show immutable;
import '../json_model.dart';

part 'constants.dart';

@immutable
class Notification extends Equatable implements JsonModel {
  @override
  Map<String, Object?> toJson() => toMap();

  @override
  factory Notification.fromJson(Map<String, Object?> json) => Notification(
        uid: json[NotificationField.uid] as String,
        senderName: json[NotificationField.senderName] as String,
        senderUid: json[NotificationField.senderUid] as String,
        receiverUid: json[NotificationField.receiverUid] as String,
        type: json[NotificationField.type] as String,
        onChat: json[NotificationField.onChat] as bool,
      );
  factory Notification.onChat(Notification unmodified) => Notification(
        uid: unmodified.uid,
        senderUid: unmodified.senderUid,
        receiverUid: unmodified.receiverUid,
        type: unmodified.type,
        senderName: unmodified.senderName,
        onChat: true,
      );

  factory Notification.friendRequest(
    String senderName,
    String senderUid,
    String receiver,
  ) =>
      Notification(
        senderName: senderName,
        uid: generateKey(senderUid, receiver),
        senderUid: senderUid,
        receiverUid: receiver,
        type: NotificationType.friendRequest,
        onChat: false,
      );

  factory Notification.chatNotification(
    String senderName,
    String senderUid,
    String receiver,
    bool onChat,
  ) =>
      Notification(
        senderName: senderName,
        uid: generateKey(senderUid, receiver),
        senderUid: senderUid,
        receiverUid: receiver,
        type: NotificationType.chat,
        onChat: onChat,
      );

  factory Notification.roomNotificaiton(
    String senderName,
    String senderUid,
    String receiver,
  ) =>
      Notification(
        senderName: senderName,
        uid: generateKey(senderUid, receiver),
        senderUid: senderUid,
        receiverUid: receiver,
        type: NotificationType.room,
        onChat: false,
      );

  const Notification(
      {required this.uid,
      required this.senderUid,
      required this.receiverUid,
      required this.type,
      required this.senderName,
      required this.onChat});

  final String uid;
  final String senderUid;
  final String senderName;
  final String receiverUid;
  final String type;
  final bool onChat;

  @override
  List<Object?> get props => [
        uid,
        senderUid,
        receiverUid,
        type,
        senderName,
        onChat,
      ];

  Map<String, dynamic> toMap() {
    return {
      NotificationField.uid: uid,
      NotificationField.senderUid: senderUid,
      NotificationField.senderName: senderName,
      NotificationField.receiverUid: receiverUid,
      NotificationField.type: type,
      NotificationField.onChat: onChat,
      NotificationField.timeStamp: timeStamp(),
    };
  }
}
