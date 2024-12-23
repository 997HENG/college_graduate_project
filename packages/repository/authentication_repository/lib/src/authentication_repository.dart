import 'dart:developer' show log;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:meta/meta.dart' show immutable;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:auth/auth.dart';
import 'package:storage/storage.dart' show User;

part 'exception.dart';
part 'firebase_authentication_repository.dart';

@immutable
abstract class AuthenticationRepository {
  Stream<User> get authStateChanges;

  Future<void> logInWithGoogle();

  Future<void> logOut();

  User get currentUser;
}
