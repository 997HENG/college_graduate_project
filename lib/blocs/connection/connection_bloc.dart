import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection/connection.dart';

part 'connection_event.dart';
part 'connection_state.dart';

class ConnectionBloc extends Bloc<ConnectionEvent, ConnectionState> {
  ConnectionBloc({Connection? connection})
      : _connection = connection ?? InternetConnectionProvider(),
        super(const ConnectionState.checking()) {
    on<ConnectionStarted>(
      _handleStarted,
      transformer: restartable(),
    );
  }

  final Connection _connection;

  void _handleStarted(
    ConnectionStarted event,
    Emitter<ConnectionState> emit,
  ) async {
    emit(const ConnectionState.checking());

    await emit.forEach(
      _connection.onStatusChange,
      onData: (status) => switch (status) {
        Status.connected => const ConnectionState.connected(),
        Status.disconnected => const ConnectionState.disconnected(),
      },
    );
  }
}
