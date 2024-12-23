import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tutor_app/blocs/authentication/authentication_bloc.dart';
import 'package:tutor_app/blocs/friend/friend_bloc.dart';
import 'package:tutor_app/blocs/llm/llm_bloc.dart';
import 'package:tutor_app/presentation/routes/home/views/friends_view/widgets/friend_list_view.dart';
import 'package:tutor_app/presentation/routes/home/views/friends_view/widgets/friend_search_view.dart';
import 'package:tutor_app/presentation/routes/router/app_router.dart';

class FriendsView extends StatelessWidget {
  const FriendsView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              FriendBloc(context.read<AuthenticationBloc>().state.user)
                ..add(const FriendChanged()),
        )
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<FriendBloc, FriendState>(
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
          )
        ],
        child: Builder(builder: (blocContext) {
          return Scaffold(
            backgroundColor: Colors.amber[50],
            appBar: AppBar(
              backgroundColor: Colors.amber[200],
              title: Text(
                'Friends',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  onPressed: () {
                    showSearch(
                        context: context, delegate: FriendSearch(blocContext));
                  },
                  icon: const Icon(Icons.search),
                ),
                IconButton(
                  onPressed: () {
                    context.push(
                      RoutePath.model,
                      extra: {'bloc': context.read<LlmBloc>()},
                    );
                  },
                  icon: const Icon(Icons.mood),
                )
              ],
            ),
            body: Builder(
              builder: (context) {
                final status = context.select(
                  (FriendBloc bloc) => bloc.state.status,
                );
                final widget = switch (status) {
                  FriendStatus.initial =>
                    const Center(child: CircularProgressIndicator()),
                  FriendStatus.listLoading =>
                    const Center(child: CircularProgressIndicator()),
                  FriendStatus.listLoaded => const FriendListView(),
                };
                return SafeArea(child: widget);
              },
            ),
          );
        }),
      ),
    );
  }
}
