import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:core';

import '../../../../blocs/chat/chat_bloc.dart';

class ChatListView extends StatelessWidget {
  const ChatListView(this.userId, {super.key});
  final String userId;

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final chats = context.select((ChatBloc bloc) => bloc.state.chats);

      return SingleChildScrollView(
        reverse: false,
        child: ListView.builder(
          shrinkWrap: true,
          itemBuilder: (_, index) {
            final chat = chats[index];
            final isUser = chat!.sender == userId;

            final message = Align(
              alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: isUser ? const Color.fromARGB(255, 240, 188, 33) : Colors.grey.shade200,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(12),
                    topRight: const Radius.circular(12),
                    bottomLeft: isUser
                        ? const Radius.circular(12)
                        : const Radius.circular(0),
                    bottomRight: isUser
                        ? const Radius.circular(0)
                        : const Radius.circular(12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: isUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      chat.body, // Assuming chat.body contains the message text
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(
                        height: 4), // Space between message and timestamp
                    Text(
                      formatDateTime(chat.timeStamp),
                      style: TextStyle(
                        color: isUser ? Colors.white70 : Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );

            return message;
          },
          itemCount: chats.length,
        ),
      );
    });
  }
}

String formatDateTime(String dateTimeString) {
  // Parse the string into a DateTime object
  DateTime dateTime = DateTime.parse(dateTimeString);

  // Format to display only the time in 24-hour format
  String formattedTime = "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";

  return formattedTime;
}