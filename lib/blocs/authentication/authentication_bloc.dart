import 'dart:async';

import 'package:cloud_storage_repository/cloud_storage_repository.dart';
import 'package:storage/storage.dart' show User;
import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc(
      {AuthenticationRepository? auth, CloudStorageRepository? cloud})
      : _auth = auth ?? FirebaseAuthenticationRepository.instance,
        super(const AuthenticationState.unknown()) {
    on<AuthenticationStarted>(
      _handleStarted,
      transformer: restartable(),
    );
    on<AuthenticationLoggedOut>(
      _handleLoggedOut,
      transformer: droppable(),
    );
    on<AuthenticationUserChanged>(
      _handleUserChanged,
      transformer: droppable(),
    );
  }

  void _handleStarted(
    AuthenticationStarted event,
    Emitter<AuthenticationState> emit,
  ) async =>
      await emit
          .forEach(
            _auth.authStateChanges,
            onData: (user) => switch (user) {
              User.empty => const AuthenticationState.unauthenticated(),
              _ => AuthenticationState.authenticated(user)
            },
          )
          .onError(
            (e, _) => emit(
              const AuthenticationState.unauthenticated(),
            ),
          );

  void _handleLoggedOut(
    AuthenticationLoggedOut event,
    Emitter<AuthenticationState> emit,
  ) =>
      unawaited(_auth.logOut());

  void _handleUserChanged(
    AuthenticationUserChanged event,
    Emitter<AuthenticationState> emit,
  ) =>
      emit(AuthenticationState.authenticated(event.user));

  final AuthenticationRepository _auth;
}
