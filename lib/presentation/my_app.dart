import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tutor_app/blocs/authentication/authentication_bloc.dart';
import 'package:tutor_app/blocs/config/config_bloc.dart';
import 'package:tutor_app/blocs/connection/connection_bloc.dart';
import 'package:tutor_app/blocs/llm/llm_bloc.dart';
import 'package:tutor_app/presentation/routes/router/app_router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ConnectionBloc()..add(ConnectionStarted()),
          lazy: false,
        ),
        BlocProvider(
          create: (_) => ConfigBloc(),
          lazy: false,
        ),
        BlocProvider(
          create: (_) =>
              AuthenticationBloc()..add(const AuthenticationStarted()),
          lazy: false,
        ),
        BlocProvider(
          create: (_) => LlmBloc(),
          lazy: true,
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<AuthenticationBloc, AuthenticationState>(
            listener: (context, state) {
              final authStatus = state.status;

              final path = switch (authStatus) {
                AuthenticationStatus.unknown => RoutePath.splash,
                AuthenticationStatus.authenticated => RoutePath.home,
                AuthenticationStatus.unauthenticated => RoutePath.login
              };

              AppRouter.router.go(path);
            },
          ),
        ],
        child: BlocListener<AuthenticationBloc, AuthenticationState>(
          listenWhen: (previous, current) =>
              previous.status == AuthenticationStatus.unknown &&
              current.status == AuthenticationStatus.authenticated,
          listener: (context, state) {
            AppRouter.router.refresh();
          },
          child: Builder(
            builder: (context) {
              final themeMode = context.select(
                (ConfigBloc config) => config.state.themeMode,
              );
              return MaterialApp.router(
                routerConfig: AppRouter.router,
                theme: ThemeData(primaryColor: Colors.indigo),
                darkTheme: ThemeData.dark(),
                themeMode: themeMode,
                debugShowCheckedModeBanner: false,
              );
            },
          ),
        ),
      ),
    );
  }
}
