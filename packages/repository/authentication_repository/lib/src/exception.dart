part of 'authentication_repository.dart';

@immutable
final class LogInWithGoogleException implements Exception {
  const LogInWithGoogleException({this.message = "An unknown exception"});

  factory LogInWithGoogleException.fromCode(String code) => switch (code) {
        "account-exists-with-different-credential" =>
          const LogInWithGoogleException(
              message: "Account exists with different credentials."),
        "invalid-credential" => const LogInWithGoogleException(
            message: "The credential received is malformed or has expired."),
        "user-disabled" => const LogInWithGoogleException(
            message: "This user has been banned. Please contact us for help."),
        "user-not-found" =>
          const LogInWithGoogleException(message: "This user is not found."),
        "operation-not-allowed" =>
          const LogInWithGoogleException(message: "Operation is not allowed."),
        "wrong-password" =>
          const LogInWithGoogleException(message: "Incorrect password."),
        "invalid-verification-code" => const LogInWithGoogleException(
            message: "Verification code is invalid."),
        "invalid-verification-id" => const LogInWithGoogleException(
            message: "Verification ID is invalid."),
        _ => const LogInWithGoogleException(),
      };

  final String message;
}

@immutable
final class LogOutException implements Exception {
  const LogOutException();
}
