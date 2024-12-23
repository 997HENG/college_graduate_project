import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tutor_app/blocs/notification/notification_bloc.dart';
import 'package:tutor_app/blocs/tab/tab_bloc.dart';
import 'package:badges/badges.dart' as badges;

class BottomBar extends StatelessWidget {
  const BottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      buildWhen: (previous, current) {
        final tabStatus = context.read<TabBloc>().state.status;
        return tabStatus != 'notifications' ||
            current.status == NotificationStatus.noNewNotifications;
      },
      builder: (context, state) {
        final tabStatus = context.watch<TabBloc>().state.status;

        final notificationStatus =
            context.read<NotificationBloc>().state.status;
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

        final notificationLength =
            context.read<NotificationBloc>().state.notifications.length;

        return BottomNavigationBar(
          onTap: (index) {
            final tab = context.read<TabBloc>();

            final event = switch (index) {
              0 => const TabMainPressed(),
              1 => const TabFriendsPressed(),
              2 => const TabGroupPressed(),
              3 => const TabNotificationsPressed(),
              _ => const TabMainPressed()
            };

            tab.add(event);
          },
          items: [
            BottomNavigationBarItem(
              label: "main",
              icon: Icon(Icons.forum,
                  color: tabStatus == 'main'
                      ? Colors.amber[900]
                      : Colors.amber[500]),
              key: const Key("main_tab"),
            ),
            BottomNavigationBarItem(
              label: "friends",
              icon: Icon(Icons.group,
                  color: tabStatus == 'friends'
                      ? Colors.amber[900]
                      : Colors.amber[500]),
              key: const Key("friends_tab"),
            ),
            BottomNavigationBarItem(
              label: "group",
              icon: Icon(Icons.connect_without_contact,
                  color: tabStatus == 'group'
                      ? Colors.amber[900]
                      : Colors.amber[500]),
              key: const Key("group_tab"),
            ),
            BottomNavigationBarItem(
              label: "notifications",
              icon: switch (notificationStatus) {
                NotificationStatus.noNewNotifications => Icon(
                    Icons.notifications,
                    color: tabStatus == 'notifications'
                        ? Colors.amber[900]
                        : Colors.amber[500],
                  ),
                NotificationStatus.newNotifications => badges.Badge(
                    badgeContent: Text('$notificationLength'),
                    child: Icon(
                      Icons.notifications,
                      color: tabStatus == 'notifications'
                          ? Colors.amber[900]
                          : Colors.amber[500],
                    ),
                  ),
                _ => Icon(
                    Icons.notifications,
                    color: tabStatus == 'notifications'
                        ? Colors.amber[900]
                        : Colors.amber[500],
                  ),
              },
              key: const Key("notifications_tab"),
            ),
          ],
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.amber[
              200], // Set background color to match scaffold's background color
          unselectedItemColor: isDarkMode ? Colors.white : Colors.amber[800],
          selectedItemColor: isDarkMode ? Colors.white : Colors.amber[800],
          showSelectedLabels: true,
          showUnselectedLabels: true,
        );
      },
    );
  }
}
