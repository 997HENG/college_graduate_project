import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tutor_app/blocs/llm/llm_bloc.dart';

class GemmaChatListView extends StatefulWidget {
  const GemmaChatListView(this._messageStream, {super.key});
  final Stream<bool> _messageStream;

  @override
  State<GemmaChatListView> createState() => _GemmaChatListViewState();
}

class _GemmaChatListViewState extends State<GemmaChatListView> {
  late final StreamSubscription<bool> _messageStreamSub;
  late final ScrollController _scrollController;

  @override
  void initState() {
    _messageStreamSub = widget._messageStream.listen(
      (newMessage) {
        if (newMessage == true) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      },
    );
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _messageStreamSub.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final messageList =
            context.select((LlmBloc bloc) => bloc.state.messageList);

        return SingleChildScrollView(
          reverse: true,
          child: ListView.builder(
            shrinkWrap: true,
            controller: _scrollController,
            itemBuilder: (_, index) {
              final message = messageList[index];
              final isUser = message.whoAmI == 'Human';

              final listTile = Align(
                alignment:
                    isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 8.0),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: isUser ? Colors.blueAccent : Colors.grey.shade200,
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
                      Text(
                        message
                            .body, // Assuming chat.body contains the message text
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                          height: 4), // Space between message and timestamp
                    ],
                  ),
                ),
              );

              return listTile;
            },
            itemCount: messageList.length,
          ),
        );
      },
    );
  }
}
