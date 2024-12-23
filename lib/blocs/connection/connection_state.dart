part of 'connection_bloc.dart';

enum ConnectionStatus {
  checking,
  connected,
  disconnected,
}

@immutable
final class ConnectionState extends Equatable {
  const ConnectionState._({required this.status});

  const ConnectionState.checking() : this._(status: ConnectionStatus.checking);

  const ConnectionState.connected()
      : this._(status: ConnectionStatus.connected);

  const ConnectionState.disconnected()
      : this._(status: ConnectionStatus.disconnected);

  final ConnectionStatus status;

  @override
  String toString() => switch (status) {
        ConnectionStatus.checking => "checking",
        ConnectionStatus.connected => "connected",
        ConnectionStatus.disconnected => "disconnected",
      };

  @override
  List<Object?> get props => [status];
}
