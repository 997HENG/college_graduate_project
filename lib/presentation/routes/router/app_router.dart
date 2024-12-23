import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group/group.dart';
import 'package:tutor_app/blocs/authentication/authentication_bloc.dart';
import 'package:tutor_app/blocs/llm/llm_bloc.dart';
import 'package:tutor_app/presentation/routes/chat/chat_route.dart';
import 'package:tutor_app/presentation/routes/config/config_route.dart';
import 'package:tutor_app/presentation/routes/gemma/gemma_route.dart';
import 'package:tutor_app/presentation/routes/group_chat/group_chat_route.dart';
import 'package:tutor_app/presentation/routes/home/home_route.dart';
import 'package:tutor_app/presentation/routes/login/login_route.dart';
import 'package:tutor_app/presentation/routes/model/model_route.dart';
import 'package:tutor_app/presentation/routes/router/router_navigator.dart';
import 'package:tutor_app/presentation/routes/splash/splash_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tutor_app/presentation/routes/summary/summary_route.dart';

import '../room/room_route.dart';

sealed class AppRouter {
  static final router = GoRouter(
    routes: [
      GoRoute(
        path: RoutePath.splash,
        builder: (context, state) => const SplashRoute(),
      ),
      GoRoute(
        path: RoutePath.home,
        builder: (context, state) => const HomeRoute(),
      ),
      GoRoute(
        path: RoutePath.login,
        builder: (context, state) => const LoginRoute(),
      ),
      GoRoute(
        path: RoutePath.config,
        builder: (context, state) => const ConfigRoute(),
      ),
      GoRoute(
        path: RoutePath.chat,
        builder: (context, state) {
          final extra = state.extra as Map<String, String>;

          return ChatRoute(
            userUid: extra['userUid'] as String,
            userName: extra['userName'] as String,
            friendUid: extra['friendUid'] as String,
            friendName: extra['friendName'] as String,
          );
        },
      ),
      GoRoute(
        path: RoutePath.model,
        builder: (context, state) {
          final extra = state.extra as Map<String, LlmBloc>;

          return ModelRoute(extra['bloc']!);
        },
      ),
      GoRoute(
        path: RoutePath.gemma,
        builder: (context, state) {
          final extra = state.extra as Map<String, LlmBloc>;

          return GemmaRoute(extra['bloc']!);
        },
      ),
      GoRoute(
        path: RoutePath.chat,
        builder: (context, state) {
          final extra = state.extra as Map<String, String>;

          return ChatRoute(
            userUid: extra['userUid'] as String,
            userName: extra['userName'] as String,
            friendUid: extra['friendUid'] as String,
            friendName: extra['friendName'] as String,
          );
        },
      ),
      GoRoute(
        path: RoutePath.room,
        builder: (context, state) {
          final extra = state.extra as Map<String, Object>;

          return RoomRoute(
            senderUid: extra['senderUid'] as String,
            senderName: extra['senderName'] as String,
            receiverUid: extra['receiverUid'] as String,
            isCreate: extra['isCreate'] as bool,
          );
        },
      ),
      GoRoute(
        path: RoutePath.groupChat,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;

          return GroupChatRoute(
            group: extra['group'] as Group,
          );
        },
      ),
      GoRoute(
        path: RoutePath.summary,
        builder: (context, state) {
          final extra = state.extra as Map<String, Object>;

          return SummaryRoute(
            extra['sl1'] as List<String>,
            extra['sl2'] as List<String>,
            extra['context'] as LlmBloc,
          );
        },
      ),
    ],
    errorPageBuilder: (context, state) => const MaterialPage(
      child: Scaffold(
        body: Center(
          child: Text('Route not found'),
        ),
      ),
    ),
    redirect: (context, state) {
      final authStatus = context.read<AuthenticationBloc>().state.status;

      final path = switch (authStatus) {
        AuthenticationStatus.unknown => RoutePath.splash,
        AuthenticationStatus.authenticated => state.fullPath,
        AuthenticationStatus.unauthenticated => RoutePath.login
      };

      return path;
    },
    observers: [
      AppRouterObserver(),
    ],
  );
}

final class RoutePath {
  static const String splash = '/';
  static const String home = '/home';
  static const String login = '/login';
  static const String config = '/config';
  static const String chat = '/chat';
  static const String room = '/room';
  static const String model = '/model';
  static const String gemma = '/gemma';
  static const String exam = '/exam';
  static const String groupChat = '/group_chat';
  static const String summary = '/summary';
}
