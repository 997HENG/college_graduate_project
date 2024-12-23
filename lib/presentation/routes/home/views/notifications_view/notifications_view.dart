import 'package:flutter/material.dart';
import 'package:tutor_app/blocs/notification/notification_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tutor_app/presentation/routes/home/views/notifications_view/widgets/chat_notification.dart';
import 'package:tutor_app/presentation/routes/home/views/notifications_view/widgets/friend_request_notification.dart';
import 'package:storage/storage.dart' show NotificationType;
import 'package:tutor_app/presentation/routes/home/views/notifications_view/widgets/room_notification.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationBloc, NotificationState>(
      listenWhen: (previous, current) =>
          previous.error != current.error && current.error != null,
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
      child: Container(
        color: Colors.amber[50],
        child: Builder(
          builder: (context) {
            final notifications = context
                .select((NotificationBloc bloc) => bloc.state.notifications);
            return SafeArea(
              child: Builder(builder: (context) {
                // Check if the notifications list is empty
                if (notifications.isEmpty) {
                  return Container(
                    color: Colors.amber[50],
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_off,
                            color: Colors.black45,

                            size: 40, // Adjust icon size as needed
                          ),
                          SizedBox(
                              height:
                                  16), // Add space between the icon and text
                          Text(
                            'No Notifications',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black45,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(
                              height:
                                  8), // Add space between title and subtitle
                          Text(
                            'You have no new notifications at this time.',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // If notifications are present, build the list view
                return ListView.builder(
                  itemBuilder: (_, index) {
                    final notification = notifications[index];

                    // Use switch expression to determine the type of notification
                    final widget = switch (notification!.type) {
                      NotificationType.friendRequest => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FriendRequestNotification(
                            notification.senderUid,
                            notification.receiverUid,
                            notification.senderName,
                          ),
                        ),
                      NotificationType.chat => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ChatNotification(
                            userUid: notification.receiverUid,
                            userName: context
                                .read<NotificationBloc>()
                                .state
                                .user
                                .name,
                            senderUid: notification.senderUid,
                            senderName: notification.senderName,
                          ),
                        ),
                      NotificationType.room => RoomNotification(
                          userUid: notification.senderUid,
                          userName: notification.senderName,
                          friendUid: notification.receiverUid,
                        ),
                      _ => const Text('Unknown notification'),
                    };
                    return widget;
                  },
                  itemCount: notifications.length,
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
