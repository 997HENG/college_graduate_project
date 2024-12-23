part of 'login_bloc.dart';

enum LoginStatus {
  success,
  failure,
  inProgress,
}

final class LoginState extends Equatable {
  const LoginState({this.status, this.error});

  LoginState copyWith({
    LoginStatus? status,
    String? errorMessage,
  }) =>
      LoginState(
        status: status ?? this.status,
        error: errorMessage,
      );

  final LoginStatus? status;
  final String? error;

  @override
  List<Object?> get props => [status, error];
}
