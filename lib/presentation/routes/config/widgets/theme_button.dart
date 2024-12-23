import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tutor_app/blocs/config/config_bloc.dart';

class ThemeButton extends StatelessWidget {
  const ThemeButton({super.key, required this.theme});

  final String theme;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        context.read<ConfigBloc>().add(ConfigThemeChanged(theme: theme));
      },
      child: Text(theme),
    );
  }
}
