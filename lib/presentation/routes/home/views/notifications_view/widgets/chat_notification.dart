import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../router/app_router.dart';

class ChatNotification extends StatelessWidget {
  const ChatNotification({
    super.key,
    required this.userUid,
    required this.userName,
    required this.senderUid,
    required this.senderName,
  });

  final String userUid;
  final String userName;
  final String senderUid;
  final String senderName;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.amber[100],
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 4,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: Icon(Icons.message,
            color: Colors.amber[300]), // You can change the icon as needed
        title: Row(
          children: [
            Expanded(
              child: Text(
                senderName,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black54),
              ),
            ),
            const Text(
              ' sent you a message.',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey),
            ),
          ],
        ),
        trailing: TextButton.icon(
          onPressed: () {
            context.push(
              RoutePath.chat,
              extra: {
                'userUid': userUid,
                'userName': userName,
                'friendUid': senderUid,
                'friendName': senderName
              },
            );
          },
          label: const Text(
            'View',
            style: TextStyle(
                color: Colors.white), // White text for better contrast
          ),
          style: TextButton.styleFrom(
            backgroundColor:
                Colors.amber[300], // Background color for the button
            padding: const EdgeInsets.symmetric(
                horizontal: 8.0), // Horizontal padding
          ),
        ),
      ),
    );
  }
}
