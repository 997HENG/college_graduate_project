part of 'config_bloc.dart';

@immutable
final class ConfigState extends Equatable {
  const ConfigState({this.theme = "system"});

  final String theme;

  ConfigState copyWith({
    String? theme,
  }) =>
      ConfigState(
        theme: theme ?? this.theme,
      );
  ThemeMode get themeMode => switch (theme) {
        "light" => ThemeMode.light,
        "dark" => ThemeMode.dark,
        "system" => ThemeMode.system,
        _ => ThemeMode.dark,
      };

  Map<String, dynamic> toMap() => {
        'theme': theme,
      };
  factory ConfigState.fromMap(Map<String, dynamic> map) {
    return ConfigState(
      theme: map['theme'] ?? '',
    );
  }

  @override
  List<Object?> get props => [theme];
}
