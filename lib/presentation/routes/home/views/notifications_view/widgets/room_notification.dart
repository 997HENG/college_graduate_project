import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tutor_app/presentation/routes/router/app_router.dart';

class RoomNotification extends StatelessWidget {
  const RoomNotification({
    super.key,
    required this.userUid,
    required this.userName,
    required this.friendUid,
  });
  final String userUid;
  final String userName;
  final String friendUid;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.amber[100],
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 4,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: Icon(
          Icons.school,
          color: Colors.amber[300],
        ), // You can change the icon as needed
        title: Text(
          userName,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black54),
        ),
        trailing: TextButton.icon(
          onPressed: () {
            context.push(
              RoutePath.room,
              extra: {
                'senderUid': userUid,
                'senderName': userName,
                'receiverUid': friendUid,
                'isCreate': false,
              },
            );
          },
          icon: const Icon(Icons.chat, color: Colors.white), // Chat icon
          label: const Text('Join Room',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white) // White text for better contrast
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
