import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tutor_app/blocs/notification/notification_bloc.dart';

class FriendRequestNotification extends StatelessWidget {
  const FriendRequestNotification(this.sender, this.receiver, this.name,
      {super.key});
  final String sender;
  final String receiver;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return Card(
          color: Colors.amber[100],
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          elevation: 4,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16.0),
            leading: Icon(Icons.person_add,
                color: Colors.amber[300]), // You can change the icon as needed
            title: Row(
              children: [
                Expanded(
                  child: Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.grey)),
                ),
                const Text(
                  ' sent you a friend request.',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.grey),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    context.read<NotificationBloc>().add(
                        NotificationFriendResponded(sender, receiver, true));
                  },
                  icon:
                      const Icon(Icons.add_circle_outline, color: Colors.green),
                ),
                IconButton(
                  onPressed: () {
                    context.read<NotificationBloc>().add(
                        NotificationFriendResponded(sender, receiver, false));
                  },
                  icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
