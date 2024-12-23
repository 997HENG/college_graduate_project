part of 'cloud_storage_repository.dart';

@immutable
abstract class CloudException implements Exception {
  const CloudException(this.message);
  final String message;
}

final class CloudUnknownException extends CloudException {
  const CloudUnknownException() : super('an unknown exception');
}

final class CloudUserCannotCreateExcption extends CloudException {
  const CloudUserCannotCreateExcption(super.message);
}

final class CloudNotificationChangedException extends CloudException {
  const CloudNotificationChangedException(super.message);
}

final class CloudSendFriendRequestException extends CloudException {
  const CloudSendFriendRequestException(super.message);
}

final class CloudRespondFriendRequestException extends CloudException {
  const CloudRespondFriendRequestException(super.message);
}

final class CloudSearchFriendException extends CloudException {
  const CloudSearchFriendException(super.message);
}

final class CloudNewChatException extends CloudException {
  const CloudNewChatException(super.message);
}

final class CloudSendChatNotificationException extends CloudException {
  const CloudSendChatNotificationException(super.message);
}

final class CloudOnChatException extends CloudException {
  const CloudOnChatException(super.message);
}

final class CloudLeaveChatException extends CloudException {
  const CloudLeaveChatException(super.message);
}
