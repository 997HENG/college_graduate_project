part of 'authentication_bloc.dart';

@immutable
sealed class AuthenticationEvent {
  const AuthenticationEvent();
}

final class AuthenticationStarted extends AuthenticationEvent {
  const AuthenticationStarted();
}

final class AuthenticationLoggedOut extends AuthenticationEvent {
  const AuthenticationLoggedOut();
}

final class AuthenticationUserChanged extends AuthenticationEvent {
  const AuthenticationUserChanged(this.user);

  final User user;
}
