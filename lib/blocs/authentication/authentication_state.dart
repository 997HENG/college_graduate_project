part of 'authentication_bloc.dart';

enum AuthenticationStatus {
  authenticated,
  unauthenticated,
  unknown,
}

@immutable
final class AuthenticationState extends Equatable {
  const AuthenticationState.authenticated(User user)
      : this._(
          status: AuthenticationStatus.authenticated,
          user: user,
        );
  const AuthenticationState.unauthenticated()
      : this._(
          status: AuthenticationStatus.unauthenticated,
        );
  const AuthenticationState.unknown()
      : this._(
          status: AuthenticationStatus.unknown,
        );

  const AuthenticationState._({
    required this.status,
    User? user,
  }) : user = user ?? User.empty;

  final AuthenticationStatus status;
  final User user;

  @override
  String toString() => switch (status) {
        AuthenticationStatus.unknown => "unknown",
        AuthenticationStatus.authenticated => "authenticated",
        AuthenticationStatus.unauthenticated => "unauthenticated",
      };

  @override
  List<Object?> get props => [status, user];
}
