import 'package:meta/meta.dart' show immutable;
import '../json_model.dart';
import 'package:equatable/equatable.dart';

part 'constants.dart';

@immutable
class Chat extends Equatable implements JsonModel {
  @override
  factory Chat.fromJson(Map<String, Object?> json) => Chat(
        sender: json[ChatField.sender] as String,
        receiver: json[ChatField.receiver] as String,
        body: json[ChatField.body] as String,
        timeStamp: json[ChatField.timeStamp] as String,
      );

  @override
  Map<String, Object?> toJson() => toMap();

  final String sender;
  final String receiver;
  final String body;
  final String timeStamp;

  const Chat({
    required this.sender,
    required this.receiver,
    required this.body,
    required this.timeStamp,
  });

  Map<String, dynamic> toMap() {
    return {
      ChatField.sender: sender,
      ChatField.receiver: receiver,
      ChatField.body: body,
      ChatField.key: generateKey(sender, receiver),
      ChatField.timeStamp: timeStamp,
    };
  }

  @override
  String toString() {
    // TODO: implement toString
    return '$body $timeStamp \n';
  }

  @override
  List<Object?> get props => [sender, receiver, body, timeStamp];
}
