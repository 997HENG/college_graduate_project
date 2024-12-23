import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import 'constants.dart';

final class ChatMessage extends Equatable {
  final String uuid;
  final String body;
  final String whoAmI;
  final int curSorPosition;
  final bool isComplete;

  factory ChatMessage.user(String body) => ChatMessage(
        body: body,
        uuid: const Uuid().v4(),
        whoAmI: imHuman,
        curSorPosition: body.length,
        isComplete: true,
      );

  factory ChatMessage.llm(String body, {int? cursorPosition}) => ChatMessage(
        body: body,
        uuid: const Uuid().v4(),
        whoAmI: imLLM,
        curSorPosition: cursorPosition ?? 0,
        isComplete: false,
      );

  ChatMessage complete() => copyWith(isComplete: true);

  ChatMessage advanceCursor() => copyWith(curSorPosition: curSorPosition + 1);

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'body': body,
      'whoAmI': whoAmI,
      'curSorPosition': curSorPosition,
      'isComplete': isComplete,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      uuid: json['uuid'] ?? '',
      body: json['body'] ?? '',
      whoAmI: json['whoAmI'] ?? '',
      curSorPosition: json['curSorPosition']?.toInt() ?? 0,
      isComplete: json['isComplete'] ?? false,
    );
  }

  const ChatMessage({
    required this.uuid,
    required this.body,
    required this.whoAmI,
    required this.curSorPosition,
    required this.isComplete,
  });

  ChatMessage copyWith({
    String? uuid,
    String? body,
    String? whoAmI,
    int? curSorPosition,
    bool? isComplete,
  }) {
    return ChatMessage(
      uuid: uuid ?? this.uuid,
      body: body ?? this.body,
      whoAmI: whoAmI ?? this.whoAmI,
      curSorPosition: curSorPosition ?? this.curSorPosition,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  @override
  List<Object?> get props => [uuid, body, whoAmI, curSorPosition, isComplete];
}
