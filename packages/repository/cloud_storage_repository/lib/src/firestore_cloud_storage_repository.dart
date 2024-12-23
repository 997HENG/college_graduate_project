part of 'cloud_storage_repository.dart';

@immutable
final class FirestoreCloudStorageRepository implements CloudStorageRepository {
  @override
  Future<void> test() async {}

  CollectionReference _userCollection() =>
      _store.collection(CollectionPath.user).withJsonModel<User>(User.fromJson);

  CollectionReference _notificationCollection() => _store
      .collection(CollectionPath.notification)
      .withJsonModel<Notification>(Notification.fromJson);

  CollectionReference _chatCollection() =>
      _store.collection(CollectionPath.chat).withJsonModel<Chat>(Chat.fromJson);

  @override
  Future<void> createUser(User user) async {
    final userDocRef = _userCollection().doc(user.uid);

    try {
      final userSnapshot = await userDocRef.get();
      if (userSnapshot.exists()) {
        return;
      }
      await userDocRef.set(user);
    } on FirebaseException catch (e) {
      log("${runtimeType.toString()}: createUser(): ${e.code}");
      throw CloudUserCannotCreateExcption(e.code);
    } catch (e) {
      log(e.toString());
      throw const CloudUnknownException();
    }
  }

  @override
  Stream<List<Notification?>> notificationsChange(User user) {
    final notificationQuery = _notificationCollection()
        .where(NotificationField.receiverUid, isEqualTo: user.uid)
        .orderBy(NotificationField.timeStamp, descending: true)
        .withJsonModel<Notification>(Notification.fromJson);

    final notificationsChange =
        notificationQuery.snapshots().map(_notificationsChangeMapper);

    return notificationsChange;
  }

  List<Notification?> _notificationsChangeMapper(QuerySnapshot querySnap) {
    if (querySnap.size == 0) {
      return [];
    }

    final docSnapList = querySnap.docs;
    final notifications = docSnapList
        .map((docSnapshot) => docSnapshot.dataWithJsonModel<Notification>())
        .where((raw) => !raw!.onChat)
        .toList();

    return notifications;
  }

  @override
  Future<void> cleanOrphanNotification(User user) async {
    final notificationQuery = _notificationCollection()
        .where(NotificationField.receiverUid, isEqualTo: user.uid)
        .withJsonModel<Notification>(Notification.fromJson);

    final querySnap = await notificationQuery.get();

    if (querySnap.size == 0) {
      return;
    }

    for (final docSnap in querySnap.docs) {
      final notification = docSnap.dataWithJsonModel<Notification>();
      if (notification!.onChat) {
        await _notificationCollection().doc(docSnap.id()).delete();
      }
    }
  }

  @override
  Stream<List<User?>> friendsChange(User user) {
    final userDocRef = _userCollection().doc(user.uid);

    final friendsChange = userDocRef.snapshots().asyncMap(_friendsChangeMapper);

    return friendsChange;
  }

  Future<List<User?>> _friendsChangeMapper(DocumentSnapshot docSnap) async {
    final user = docSnap.dataWithJsonModel<User>();
    if (user!.friends.isEmpty) {
      return [];
    }

    final friendsUidList = user.friends;

    final friendsDocSnap = await Future.wait(
      friendsUidList.map((id) => _userCollection().doc(id).get()),
    );

    final friends = friendsDocSnap
        .map((docSnap) => docSnap.dataWithJsonModel<User>())
        .toList();

    return friends;
  }

  @override
  Future<List<User?>> searchFriend(User user, String name) async {
    final userCollection = _userCollection();

    try {
      final resultsQuerySnap =
          await userCollection.where(UserField.name, isEqualTo: name).get();

      if (resultsQuerySnap.size == 0) {
        return [];
      }

      final userUid = user.uid;

      final results = resultsQuerySnap.docs
          .map((querySnap) => querySnap.dataWithJsonModel<User>())
          .where((user) => user!.uid != userUid);

      final resultsNotFriendYet = results
          .where((result) => result!.friends.notContains(userUid))
          .toList();

      return resultsNotFriendYet;
    } on FirebaseException catch (e) {
      log('${runtimeType.toString()}: searchFriend(): ${e.toString()}');
      throw CloudSearchFriendException(e.code);
    } catch (e) {
      log(e.toString());
      throw const CloudUnknownException();
    }
  }

  @override
  Future<void> friendRequest(User user, String receiver) async {
    final notificationCollection = _notificationCollection();

    try {
      final receiverFriendRequest = await notificationCollection
          .where(
            NotificationField.type,
            isEqualTo: NotificationType.friendRequest,
          )
          .where(NotificationField.senderUid, isEqualTo: user.uid)
          .where(NotificationField.receiverUid, isEqualTo: receiver)
          .get();

      if (receiverFriendRequest.size > 0) {
        return;
      }

      final friendRequest =
          Notification.friendRequest(user.name, user.uid, receiver);

      await notificationCollection.add(friendRequest);
    } on FirebaseException catch (e) {
      log('${runtimeType.toString()}: friendRequest(): ${e.toString()}');
      throw CloudSendFriendRequestException(e.code);
    } catch (e) {
      log(e.toString());
      throw const CloudUnknownException();
    }
  }

  @override
  Future<void> friendResponse(
      String sender, String receiver, bool response) async {
    final notificationCollection = _notificationCollection();

    try {
      final requestQuerySnap = await notificationCollection
          .where(NotificationField.senderUid, isEqualTo: sender)
          .where(NotificationField.receiverUid, isEqualTo: receiver)
          .where(
            NotificationField.type,
            isEqualTo: NotificationType.friendRequest,
          )
          .get();

      if (requestQuerySnap.docs.isEmpty && requestQuerySnap.docs.length != 1) {
        return;
      }

      final requestQueryDocSnap = requestQuerySnap.docs[0];

      final requestDocRef =
          notificationCollection.doc(requestQueryDocSnap.id());

      if (response == false) {
        await requestDocRef.delete();
        return;
      }

      final request = requestQueryDocSnap.dataWithJsonModel<Notification>();

      final userCollection = _userCollection();
      final senderDocRef = userCollection.doc(request!.senderUid);
      final receiverDocRef = userCollection.doc(request.receiverUid);

      final batch = _store.batch();
      batch.updateArrayAdd(
          senderDocRef, UserField.friends, request.receiverUid);
      batch.updateArrayAdd(
          receiverDocRef, UserField.friends, request.senderUid);
      batch.delete(requestDocRef);
      await batch.commit();
    } on FirebaseException catch (e) {
      log('${runtimeType.toString()}: friendResponse(): ${e.toString()}');
      throw CloudRespondFriendRequestException(e.code);
    } catch (e) {
      log(e.toString());
      throw const CloudUnknownException();
    }
  }

  //? chat

  @override
  Stream<List<Chat?>> chatChange(String userUid, String friendUid) {
    final chatCollection = _chatCollection();
    final key = generateKey(userUid, friendUid);

    final chatChange = chatCollection
        .where(ChatField.key, isEqualTo: key)
        .orderBy(ChatField.timeStamp)
        .snapshots()
        .map(_chatChangeMapper);

    return chatChange;
  }

  List<Chat?> _chatChangeMapper(QuerySnapshot querySnap) {
    if (querySnap.docs.isEmpty) {
      return [];
    }

    final docSnapList = querySnap.docs;

    final chats = docSnapList
        .map((docSnap) => docSnap.dataWithJsonModel<Chat>())
        .toList();

    return chats;
  }

  @override
  Future<void> sendMessage(
    String userUid,
    String friendUid,
    String body,
  ) async {
    if (body == '') {
      return;
    }

    final chatCollection = _chatCollection();
    final chat = Chat(
      sender: userUid,
      receiver: friendUid,
      body: body,
      timeStamp: timeStamp(),
    );
    try {
      await chatCollection.add(chat);
    } on FirebaseException catch (e) {
      log('${runtimeType.toString()}: newChat(): ${e.toString()}');
      throw CloudNewChatException(e.code);
    } catch (e) {
      log(e.toString());
      throw const CloudUnknownException();
    }
  }

  @override
  Future<void> sendChatNotification(
    String userUid,
    String userName,
    String friendUid,
  ) async {
    final notificationCollection = _notificationCollection();

    try {
      final notificationQuerySnap = await notificationCollection
          .where(NotificationField.type, isEqualTo: NotificationType.chat)
          .where(NotificationField.senderUid, isEqualTo: userUid)
          .where(NotificationField.receiverUid, isEqualTo: friendUid)
          .get();

      if (notificationQuerySnap.docs.isNotEmpty) {}
      switch (notificationQuerySnap.docs.length) {
        case 0:
          final chatNotification = Notification.chatNotification(
            userName,
            userUid,
            friendUid,
            false,
          );

          await notificationCollection.add(chatNotification);
        case 1:
          final docId = notificationQuerySnap.docs[0].id();
          final notificationDocRef = notificationCollection.doc(docId);
          await notificationDocRef
              .update({NotificationField.timeStamp: timeStamp()});
        default:
          final docQuerySnapList = notificationQuerySnap.docs;
          final notifications = docQuerySnapList.map(
              (docQuerySnap) => docQuerySnap.dataWithJsonModel<Notification>());
          if (notifications
              .map((notification) => notification!.onChat)
              .contains(true)) {
            return;
          }
          final docRefIdList =
              docQuerySnapList.map((docQuerySnap) => docQuerySnap.id());
          final docRefList = docRefIdList
              .map((docRefId) => notificationCollection.doc(docRefId));
          final batch = _store.batch();
          for (var docRef in docRefList) {
            batch.delete(docRef);
          }

          await batch.commit();
          final chatNotification = Notification.chatNotification(
            userName,
            userUid,
            friendUid,
            false,
          );

          await notificationCollection.add(chatNotification);
      }
    } on FirebaseException catch (e) {
      log('${runtimeType.toString()}: newChat(): ${e.toString()}');
      throw CloudSendChatNotificationException(e.code);
    } catch (e) {
      log(e.toString());
      throw const CloudUnknownException();
    }
  }

  @override
  Future<void> openChat(
    String userUid,
    String friendUid,
    String friendName,
  ) async {
    final notificationCollection = _notificationCollection();

    try {
      final notificationQuerySnap = await notificationCollection
          .where(NotificationField.type, isEqualTo: NotificationType.chat)
          .where(NotificationField.senderUid, isEqualTo: friendUid)
          .where(NotificationField.receiverUid, isEqualTo: userUid)
          .get();

      final chatNotificationAmount = notificationQuerySnap.docs.length;

      final chatNotification = Notification.chatNotification(
        friendName,
        friendUid,
        userUid,
        true,
      );

      switch (chatNotificationAmount) {
        case == 0:
          await notificationCollection.add(chatNotification);
        case == 1:
          final notificationDocSnap = notificationQuerySnap.docs.first;

          final notification =
              notificationDocSnap.dataWithJsonModel<Notification>();
          if (notification!.onChat) {
            return;
          }

          final notificationDocRefId = notificationDocSnap.id();

          await notificationCollection
              .doc(notificationDocRefId)
              .update({NotificationField.onChat: true});

        case > 1:
          final chatNotificationIdlist = notificationQuerySnap.docs.map(
            (queryDocSnap) => queryDocSnap.id(),
          );

          final docRefList = chatNotificationIdlist
              .map((id) => notificationCollection.doc(id));

          final batch = _store.batch();
          for (final docRef in docRefList) {
            batch.delete(docRef);
          }

          await Future.wait(
            [
              batch.commit(),
              notificationCollection.add(chatNotification),
            ],
          );
      }
    } on FirebaseException catch (e) {
      log('${runtimeType.toString()}: newChat(): ${e.toString()}');
      throw CloudOnChatException(e.code);
    } catch (e) {
      log(e.toString());
      throw const CloudUnknownException();
    }
  }

  @override
  Future<void> leaveChat(String userUid, String friendUid) async {
    final notificationCollection = _notificationCollection();
    try {
      final notificationQuerySnap = await notificationCollection
          .where(NotificationField.type, isEqualTo: NotificationType.chat)
          .where(NotificationField.senderUid, isEqualTo: friendUid)
          .where(NotificationField.receiverUid, isEqualTo: userUid)
          .get();

      final docSnapList = notificationQuerySnap.docs;

      if (docSnapList.isEmpty) {
        return;
      }

      final chatNotificationIdList = docSnapList.map((docSnap) => docSnap.id());

      final docRefList =
          chatNotificationIdList.map((id) => notificationCollection.doc(id));

      final batch = _store.batch();

      for (var docRef in docRefList) {
        batch.delete(docRef);
      }

      await batch.commit();
    } on FirebaseException catch (e) {
      log('${runtimeType.toString()}: newChat(): ${e.toString()}');
      throw CloudLeaveChatException(e.code);
    } catch (e) {
      log(e.toString());
      throw const CloudUnknownException();
    }
  }

  @override
  Stream<bool?> realTimeOnline(String userUid, String friendUid) {
    final notificationCollection = _notificationCollection();
    try {
      final notificationChange = notificationCollection
          .where(NotificationField.type, isEqualTo: NotificationType.chat)
          .where(NotificationField.senderUid, isEqualTo: userUid)
          .where(NotificationField.receiverUid, isEqualTo: friendUid)
          .snapshots();

      final realTimeFriendOnline =
          notificationChange.map(_isFriendOnlineMapper);

      return realTimeFriendOnline;
    } on FirebaseException catch (e) {
      log('${runtimeType.toString()}: newChat(): ${e.toString()}');
      throw CloudLeaveChatException(e.code);
    } catch (e) {
      log(e.toString());
      throw const CloudUnknownException();
    }
  }

  bool? _isFriendOnlineMapper(QuerySnapshot querySnap) {
    final docSnapList = querySnap.docs;

    if (docSnapList.isEmpty) {
      return false;
    }

    final notficiations =
        docSnapList.map((docSnap) => docSnap.dataWithJsonModel<Notification>());
    final onChatList =
        notficiations.map((notification) => notification!.onChat);
    final anyOnChat = onChatList.contains(true);

    return anyOnChat;
  }

  static get instace => _sharedInstance;

  FirestoreCloudStorageRepository._({Store? store})
      : _store = store ?? FirestoreStoreProvider();

  static final FirestoreCloudStorageRepository _sharedInstance =
      FirestoreCloudStorageRepository._();

  final Store _store;
}

extension ListUtil on List {
  bool notContains(Object? element) => !contains(element);
}
