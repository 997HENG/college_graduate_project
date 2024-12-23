import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseException;
import 'package:meta/meta.dart' show immutable;
import 'package:storage/storage.dart';
import 'dart:developer' show log;
import 'package:cloud_storage/cloud_storage.dart';

part 'firestore_cloud_storage_repository.dart';
part 'exceptions.dart';
part 'constants.dart';

abstract class CloudStorageRepository {
  Future<void> test();

  Future<void> createUser(User user);

  //? Notification
  Stream<List<Notification?>> notificationsChange(User user);

  Future<void> cleanOrphanNotification(User user);

  Future<void> friendResponse(String sender, String receiver, bool response);

  //? Friend
  Future<void> friendRequest(User user, String receiver);

  Stream<List<User?>> friendsChange(User user);

  Future<List<User?>> searchFriend(User user, String name);

  //? Chat
  Stream<List<Chat?>> chatChange(String userUid, String friendUid);

  Future<void> sendMessage(String userUid, String friendUid, String body);

  Future<void> sendChatNotification(
    String userUid,
    String userName,
    String friendUid,
  );

  Future<void> openChat(String userUid, String friendUid, String friendName);

  Future<void> leaveChat(String userUid, String friendUid);

  Stream<bool?> realTimeOnline(String userUid, String friendUid);
}
