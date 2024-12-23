part of 'authentication_repository.dart';

final class FirebaseAuthenticationRepository
    implements AuthenticationRepository {
  @override
  Stream<User> get authStateChanges => _auth.authStateChanges.map(
        (user) => switch (user) {
          null => User.empty,
          _ => user.toUser,
        },
      );

  @override
  Future<void> logInWithGoogle() async {
    try {
      await _auth.logInWithGoogle();
    } on firebase_auth.FirebaseAuthException catch (e) {
      log("${runtimeType.toString()}: logInWithGoogle(): ${e.code}");
      throw LogInWithGoogleException.fromCode(e.code);
    } catch (e) {
      log(e.toString());
      throw const LogInWithGoogleException();
    }
  }

  @override
  Future<void> logOut() async {
    try {
      await _auth.logOut();
    } catch (_) {
      throw const LogOutException();
    }
  }

  @override
  User get currentUser {
    final currentUser = _auth.currentUser;

    final user = switch (currentUser) {
      null => User.empty,
      _ => currentUser.toUser,
    };

    return user;
  }

  FirebaseAuthenticationRepository._({Auth? auth})
      : _auth = auth ?? FirebaseAuthProvider();

  static final FirebaseAuthenticationRepository _sharedInstance =
      FirebaseAuthenticationRepository._();

  static get instance => _sharedInstance;

  final Auth _auth;
}

extension FirebaseUser on firebase_auth.User {
  User get toUser => User.fromFirebase(
        uid: uid,
        name: displayName ?? 'none',
        photoURL: photoURL ?? 'none',
      );
}
