import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

part 'firebase_auth_provider.dart';

abstract class Auth {
  Stream<User?> get authStateChanges;

  Stream<User?> get userChanges;

  User? get currentUser;

  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> logInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> logOut();

  Future<void> logInWithGoogle();
}
