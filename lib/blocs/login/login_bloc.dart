import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_storage_repository/cloud_storage_repository.dart';
import 'package:authentication_repository/authentication_repository.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({
    AuthenticationRepository? auth,
    CloudStorageRepository? cloud,
  })  : _auth = auth ?? FirebaseAuthenticationRepository.instance,
        _cloud = cloud ?? FirestoreCloudStorageRepository.instace,
        super(const LoginState()) {
    on<LoginEvent>(
      _handleEvent,
      transformer: droppable(),
    );
  }

  Future<void> _handleEvent(LoginEvent event, Emitter<LoginState> emit) async {
    emit(state.copyWith(status: LoginStatus.inProgress));

    String? errorMessage;

    switch (event) {
      case LoginGoogleLoggedIn():
        try {
          await _auth.logInWithGoogle();
        } on LogInWithGoogleException catch (e) {
          errorMessage = e.message;
        } catch (e) {
          errorMessage = "loginBloc: unhandled exception: $e";
        }
    }

    final user = _auth.currentUser;

    try {
      await _cloud.createUser(user);
    } on CloudUserCannotCreateExcption catch (_) {
      errorMessage = "usercannot create";
    } catch (e) {
      errorMessage = "loginBloc: unhandled exception: $e";
    }

    if (errorMessage != null) {
      unawaited(_auth.logOut());
      emit(
        state.copyWith(status: LoginStatus.failure, errorMessage: errorMessage),
      );
      return;
    }

    emit(
      state.copyWith(status: LoginStatus.success, errorMessage: null),
    );
  }

  final AuthenticationRepository _auth;
  final CloudStorageRepository _cloud;
}
