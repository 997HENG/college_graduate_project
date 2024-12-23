import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tutor_app/blocs/chat/chat_bloc.dart';
import 'package:tutor_app/blocs/connection/connection_bloc.dart';
import 'package:tutor_app/presentation/routes/chat/widgets/chat_list_view.dart';
import 'package:tutor_app/presentation/routes/chat/widgets/chat_text_field.dart';
import 'package:tutor_app/presentation/routes/router/app_router.dart';

import '../../../blocs/config/config_bloc.dart';

class ChatRoute extends StatelessWidget {
  const ChatRoute({
    super.key,
    required this.userUid,
    required this.userName,
    required this.friendUid,
    required this.friendName,
  });
  final String userUid;
  final String userName;
  final String friendUid;
  final String friendName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatBloc(userUid, userName, friendUid, friendName)
        ..add(const ChatStarted())
        ..add(const ChatFriendOnlined())
        ..add(const ChatOpend()),
      child: BlocListener<ChatBloc, ChatState>(
        listenWhen: (previous, current) => current.error != null,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('something wrong: ${state.error}'),
              duration: const Duration(
                seconds: 10,
              ), // How long the SnackBar is visible
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () {},
              ),
            ),
          );
        },
        child: Builder(
          builder: (context) {
            final themeMode =
                context.select((ConfigBloc bloc) => bloc.state.theme) == 'dark'
                    ? Colors.white
                    : Colors.black;

            return Scaffold(
              backgroundColor: Colors.amber[50],
              appBar: AppBar(
                backgroundColor: Colors.amber[100],
                centerTitle: true,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Builder(
                      builder: (context) {
                        final onChat = context
                            .select((ChatBloc bloc) => bloc.state.onChat);
                        final online = switch (onChat) {
                          true => const Icon(
                              Icons.circle,
                              color: Colors.green,
                            ),
                          false => const Icon(Icons.circle),
                        };
                        return online;
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          friendName,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        if (context.read<ConnectionBloc>().state.status !=
                            ConnectionStatus.connected) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("No Internet Connection"),
                                content: const Text(
                                    "Please connect to the internet to proceed."),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Close the dialog
                                    },
                                    child: const Text("OK"),
                                  ),
                                ],
                              );
                            },
                          );

                          return;
                        }
                        try {
                          context.push(
                            RoutePath.room,
                            extra: {
                              'senderUid': userUid,
                              'senderName': userName,
                              'receiverUid': friendUid,
                              'isCreate': true,
                            },
                          );
                        } catch (e) {
                          log(e.toString());
                        }
                      },
                      icon: Icon(
                        Icons.school, // 替換為學校圖示
                        color: context.read<ConfigBloc>().state.theme == 'light'
                            ? Colors.amber[600]
                            : Colors.white, // 根據主題選擇顏色
                      ),
                    ),
                  ],
                ),
              ),
              body: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Column(
                  children: [
                    Expanded(
                      child: Builder(builder: (context) {
                        final status = context
                            .select((ChatBloc bloc) => bloc.state.status);

                        final widget = switch (status) {
                          ChatStatus.initial => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ChatStatus.loading => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ChatStatus.loaded => ChatListView(userUid),
                        };

                        return widget;
                      }),
                    ),
                    const ChatTextField()
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
