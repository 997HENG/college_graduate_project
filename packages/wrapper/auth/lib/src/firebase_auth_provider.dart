part of 'auth.dart';

final class FirebaseAuthProvider implements Auth {
  FirebaseAuthProvider({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.standard();

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  Stream<User?> get userChanges => _firebaseAuth.userChanges();

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  Future<void> logInWithEmailAndPassword({
    required String email,
    required String password,
  }) =>
      _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

  @override
  Future<void> logInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    final userCredential = await googleUser!.authentication;
    final credentialForFirebase = GoogleAuthProvider.credential(
      idToken: userCredential.idToken,
      accessToken: userCredential.accessToken,
    );
    await _firebaseAuth.signInWithCredential(credentialForFirebase);
  }

  @override
  Future<void> signUpWithEmailAndPassword(
          {required String email, required String password}) =>
      _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

  @override
  Future<void> logOut() => Future.wait(
        [
          _firebaseAuth.signOut(),
          _googleSignIn.signOut(),
        ],
      );

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
}

const String clientId =
    "586198957428-biikrqb8578n97acp6vtgu1hr3bnf76o.apps.googleusercontent.com";

const List<String> scopes = <String>[
  'email',
  'https://www.googleapis.com/auth/contacts.readonly',
  'https://www.googleapis.com/auth/userinfo.profile',
];
