import 'package:flutter/material.dart';
import 'package:group/group.dart';
import 'package:tutor_app/presentation/routes/group_chat/widgets/chat_page.dart';

class GroupChatRoute extends StatelessWidget {
  final Group group;

  const GroupChatRoute({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChatPage(
        groupId: group.id,
        groupName: group.name,
      ), //(child: Text('歡迎加入 ${group.name} 的聊天室')),
    );
  }
}
