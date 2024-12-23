part of 'connection_bloc.dart';

@immutable
sealed class ConnectionEvent {}

final class ConnectionStarted extends ConnectionEvent {}
