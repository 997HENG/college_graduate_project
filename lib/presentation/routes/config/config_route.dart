import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tutor_app/blocs/config/config_bloc.dart';

import '../../../blocs/authentication/authentication_bloc.dart';

class ConfigRoute extends StatelessWidget {
  const ConfigRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final themeMode = context.select((ConfigBloc bloc) => bloc.state.theme);

        return Scaffold(
          backgroundColor: Colors.amber[50],
          appBar: AppBar(
            backgroundColor: Colors.amber[100],
            title: Text(
              'Setting',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton(
                  onPressed: () {
                    context.read<ConfigBloc>().add(
                          ConfigThemeChanged(
                            theme: themeMode == 'light' ? 'dark' : 'light',
                          ),
                        );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor:
                        themeMode == 'dark' ? Colors.white : Colors.black,
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('Change Theme'),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor:
                        themeMode == 'dark' ? Colors.white : Colors.black,
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('Change language'),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    context
                        .read<AuthenticationBloc>()
                        .add(const AuthenticationLoggedOut());
                  },
                  style: TextButton.styleFrom(
                    foregroundColor:
                        themeMode == 'dark' ? Colors.white : Colors.black,
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('Log Out'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
