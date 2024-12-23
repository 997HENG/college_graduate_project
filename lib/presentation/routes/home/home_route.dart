import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tutor_app/blocs/authentication/authentication_bloc.dart';
import 'package:tutor_app/blocs/connection/connection_bloc.dart' as cn;
import 'package:tutor_app/blocs/notification/notification_bloc.dart';
import 'package:tutor_app/blocs/tab/tab_bloc.dart';
import 'package:tutor_app/presentation/routes/home/views/friends_view/friends_view.dart';
import 'package:tutor_app/presentation/routes/home/views/group_view/group_view.dart';
import 'package:tutor_app/presentation/routes/home/views/util/loading_view.dart';
import 'package:tutor_app/presentation/routes/home/views/main_view/main_view.dart';
import 'package:tutor_app/presentation/routes/home/views/notifications_view/notifications_view.dart';

import 'package:tutor_app/presentation/routes/home/widgets/bottom_bar.dart';

class HomeRoute extends StatelessWidget {
  const HomeRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => TabBloc(),
        ),
        BlocProvider(
          create: (_) => NotificationBloc(
            context.read<AuthenticationBloc>().state.user,
          )
            ..add(
              const NotificationStarted(),
            )
            ..add(
              const NotificationOrphanCleaned(),
            ),
        ),
      ],
      child: Scaffold(
        body: MultiBlocListener(
          listeners: [
            BlocListener<TabBloc, TabState>(
              listenWhen: (previous, current) =>
                  current.status == "notifications" &&
                  previous.status != "notifications",
              listener: (context, state) {
                context
                    .read<NotificationBloc>()
                    .add(const NotificationTabPressed());
              },
            ),
            BlocListener<cn.ConnectionBloc, cn.ConnectionState>(
              listenWhen: (previous, current) =>
                  current.status != cn.ConnectionStatus.connected,
              // previous.status != cn.ConnectionStatus.connected,
              // current.status == cn.ConnectionStatus.connected,
              listener: (context, state) {
                ScaffoldMessenger.of(context).showMaterialBanner(
                  MaterialBanner(
                    backgroundColor:
                        Colors.yellow[200], // Soft yellow background
                    content: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.wifi_off_rounded,
                          color: Colors.black,
                          size: 20,
                        ),
                        SizedBox(width: 8), // Space between icon and text
                        Text(
                          'Lost Connection!',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    actions: const [SizedBox.shrink()], // No action buttons
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ), // Compact padding
                  ),
                );
              },
            ),
            BlocListener<cn.ConnectionBloc, cn.ConnectionState>(
              listenWhen: (previous, current) =>
                  current.status == cn.ConnectionStatus.connected,
              // previous.status != cn.ConnectionStatus.connected,
              // current.status == cn.ConnectionStatus.connected,
              listener: (context, state) {
                ScaffoldMessenger.of(context).clearMaterialBanners();
              },
            ),
          ],
          child: Builder(
            builder: (context) {
              final tabStatus = context.watch<TabBloc>().state.status;

              final view = switch (tabStatus) {
                "main" => const MainView(),
                "friends" => const FriendsView(),
                "group" => const GroupView(),
                "notifications" => const NotificationsView(),
                _ => const LoadingView(),
              };

              return view;
            },
          ),
        ),
        bottomNavigationBar: const BottomBar(),
      ),
    );
  }
}
