part of 'config_bloc.dart';

@immutable
sealed class ConfigEvent {
  const ConfigEvent();
}

final class ConfigThemeChanged extends ConfigEvent {
  const ConfigThemeChanged({required this.theme});
  final String theme;
}
