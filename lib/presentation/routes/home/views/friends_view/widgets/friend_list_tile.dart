import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:storage/storage.dart';
import '../../../../router/app_router.dart';

class FriendListTile extends StatelessWidget {
  const FriendListTile(this.user, this.friend, {super.key});
  final User user;
  final User friend;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.amber[100],
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      elevation: 4,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        leading: CircleAvatar(
          backgroundImage:
              NetworkImage(friend.photoURL), // Assuming friend has a photoURL
          radius: 24, // Adjust size as needed
        ),
        title: Text(
          friend.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
            fontSize: 18,
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.chat,
            color: Colors.amber[600],
          ),
          onPressed: () {
            context.push(
              RoutePath.chat,
              extra: {
                'userUid': user.uid,
                'userName': user.name,
                'friendUid': friend.uid,
                'friendName': friend.name,
              },
            );
          },
        ),
        onTap: () {
          // Optional onTap functionality
        },
      ),
    );
  }
}
