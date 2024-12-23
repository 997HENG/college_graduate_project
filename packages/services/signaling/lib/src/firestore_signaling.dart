part of 'signaling.dart';

final class FirestoreSignaling implements Signaling {
  @override
  Future<void> handleSignaling() async {
    if (peerConnection == null) {
      throw Exception('signaling: peerConnection is null');
    }

    return createOrJoin ? await _createRoom() : await _joinRoom();
  }

  @override
  Future<void> addTrack(MediaStreamTrack track, MediaStream stream) async =>
      await peerConnection!.addTrack(track, stream);

  @override
  Future<void> cleanUp() async {
    try {
      candidatesSnapSub?.cancel();
      sdpSnapSub?.cancel();
      _deleteRoomNotification();

      _deleteRoom();
    } catch (_) {}

    peerConnection?.dispose();
  }

  Future<void> _deleteRoomNotification() async =>
      await _store.collection(notificationPath).doc(senderUid).delete();

  @override
  Future<void> updateLabel({
    required String type,
    required bool? status,
  }) async =>
      await roomRef
          .collection(labelPath)
          .doc(createOrJoin ? callerLabel : calleeLabel)
          .update({type: status});

  @override
  Stream<Map<String, bool?>> labelChange() {
    final labelSnapshots = roomRef
        .collection(labelPath)
        .doc(createOrJoin ? calleeLabel : callerLabel)
        .snapshots();

    final labelChange = labelSnapshots.map(_labelChangeMapper);

    return labelChange;
  }

  Map<String, bool?> _labelChangeMapper(DocumentSnapshot docSnap) {
    final rawLabel = docSnap.data() as Map<String, dynamic>?;

    if (rawLabel == null) {
      return initialLabel;
    }

    Map<String, bool?> label = _deserializeLabel(rawLabel);

    return label;
  }

  Map<String, bool?> _deserializeLabel(Map<String, dynamic> rawLabel) {
    final label = {
      'camera': rawLabel['camera'] as bool?,
      'mic': rawLabel['mic'] as bool?,
      'display': rawLabel['display'] as bool?
    };
    return label;
  }

  Future<void> _createRoom() async {
    try {
      final roomSnap = await roomRef.get();

      if (roomSnap.exists) {
        await _deleteRoom();
      }

      _onCandidates();

      await _initializeLabel();

      await _createOfferAndSend();

      _listenToSdp();

      _listenToCandidates();

      await _sendRoomNotification();
      log('here');

      _onRenegotiationNeeded();
    } catch (e) {
      throw Exception('signaling: create room: $e');
    }
  }

  void _onRenegotiationNeeded() {
    peerConnection!.onRenegotiationNeeded = () async {
      if (peerConnection!.signalingState !=
          RTCSignalingState.RTCSignalingStateStable) {
        log('signaling state is not stable');

        //todo: maybe throw exception for ui to react
        return;
      }
      await _createOfferAndSend();
    };
  }

  Future<void> _joinRoom() async {
    await _deleteRoomNotification();

    final roomSnap = await roomRef.get();

    if (!roomSnap.exists) {
      return;
    }

    _onCandidates();

    _listenToSdp();

    _onRenegotiationNeeded();
  }

  Future<void> _createOfferAndSend() async {
    waittingForOffer = false;
    haveSetCanSub = true;

    Map<String, dynamic> offer = await _createOffer();

    await _sendOffer(offer);
  }

  Future<Map<String, dynamic>> _createOffer() async {
    final offer = await peerConnection!.createOffer();
    await peerConnection!.setLocalDescription(offer);

    final roomWithOffer = {
      'offer': offer.toMap(),
      'waitingForAnswer': true,
    };
    return roomWithOffer;
  }

  Future<void> _sendOffer(Map<String, dynamic> offer) async {
    await roomRef.set(offer);
  }

  void _listenToSdp() {
    sdpSnapSub = roomRef.snapshots().listen(
      (DocumentSnapshot snapshot) async {
        if (!snapshot.exists) return;

        Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

        if (data == null) return;

        if (peerConnection!.signalingState !=
            RTCSignalingState.RTCSignalingStateStable) {
          log('new offer signaling state not stable');
        }

        await _handleNewOffer(data);

        await _handleNewAnswer(data);
      },
    );
  }

  Future<void> _handleNewOffer(Map<String, dynamic> data) async {
    if (data['offer'] != null &&
        waittingForOffer == true &&
        data['waitingForAnswer'] == true) {
      waittingForOffer = true;
      _ensuredListenToCandidates();

      RTCSessionDescription offer = _newOffer(data);

      await peerConnection?.setRemoteDescription(offer);

      RTCSessionDescription answer = await peerConnection!.createAnswer();
      await peerConnection?.setLocalDescription(answer);

      Map<String, dynamic> answerWithOffer = {
        'answer': answer.toMap(),
        'waitingForAnswer': false,
      };
      await roomRef.update(answerWithOffer);
    }
  }

  RTCSessionDescription _newOffer(Map<String, dynamic> data) {
    Map<String, dynamic> offerData = data['offer'];
    RTCSessionDescription offer = RTCSessionDescription(
      offerData['sdp'],
      offerData['type'],
    );
    return offer;
  }

  void _ensuredListenToCandidates() {
    if (!haveSetCanSub) {
      haveSetCanSub = true;
      _listenToCandidates();
    }
  }

  Future<void> _handleNewAnswer(Map<String, dynamic> data) async {
    if (data['answer'] != null &&
        waittingForOffer == false &&
        data['waitingForAnswer'] == false) {
      waittingForOffer = true;

      RTCSessionDescription answer = _newAnswer(data);

      await peerConnection!.setRemoteDescription(answer);
    }
  }

  RTCSessionDescription _newAnswer(Map<String, dynamic> data) {
    Map<String, dynamic> answerData = data['answer'];

    RTCSessionDescription answer = RTCSessionDescription(
      answerData['sdp'],
      answerData['type'],
    );
    return answer;
  }

  Future<void> _initializeLabel() async {
    final labelCollection = roomRef.collection(labelPath);
    await labelCollection.doc(callerLabel).set(initialLabel);
    await labelCollection.doc(calleeLabel).set(initialLabel);
    await labelCollection.doc('subtitle').set({'caller': [], 'callee': []});
  }

  @override
  Stream<(List<String>, List<String>)> subtitleChange() {
    final labelSnapshots =
        roomRef.collection(labelPath).doc('subtitle').snapshots();

    final subtitleChange = labelSnapshots.map(_subtitleChangeMapper);

    return subtitleChange;
  }

  (List<String>, List<String>) _subtitleChangeMapper(DocumentSnapshot docSnap) {
    final rawSubtitle = docSnap.data() as Map<String, dynamic>?;

    if (rawSubtitle == null) {
      return (<String>[], <String>[]);
    }

    (List<String>, List<String>) subtitle = _deserializeSubtitle(rawSubtitle);

    return subtitle;
  }

  (List<String>, List<String>) _deserializeSubtitle(
    Map<String, dynamic> rawSubtitle,
  ) {
    final rawCaller = rawSubtitle['caller'];
    final rawCallee = rawSubtitle['callee'];

    log('Raw caller: $rawCaller, type: ${rawCaller.runtimeType}');
    log('Raw callee: $rawCallee, type: ${rawCallee.runtimeType}');

    final callerSubtitle =
        (rawCaller as List<dynamic>? ?? []).map((e) => e.toString()).toList();

    final calleeSubtitle =
        (rawCallee as List<dynamic>? ?? []).map((e) => e.toString()).toList();

    final subtitle = switch (createOrJoin) {
      true => (callerSubtitle, calleeSubtitle),
      false => (calleeSubtitle, callerSubtitle),
    };

    return subtitle;
  }

  @override
  Future<void> updateSubtitle(String newSubtitle) async {
    if (newSubtitle == '') {
      return;
    }

    await roomRef.collection(labelPath).doc('subtitle').update(
      {
        createOrJoin ? 'caller' : 'callee': FieldValue.arrayUnion([newSubtitle])
      },
    );
  }

  Future<void> _sendRoomNotification() async {
    final notificationCollection = _store.collection(notificationPath);

    final notification = Notification.roomNotificaiton(
      senderName,
      senderUid,
      receiverUid,
    );

    final doc = notificationCollection.doc(senderUid);

    final orphanNotification = await doc.get();
    if (orphanNotification.exists) {
      await doc.delete();
    }

    await doc.set(notification.toJson());
  }

  void _onCandidates() {
    final candidatesCollection = roomRef
        .collection(createOrJoin ? callerCandidatesPath : calleeCandidatesPath);

    peerConnection?.onIceCandidate = (RTCIceCandidate candidate) =>
        candidatesCollection.add(candidate.toMap());
  }

  void _listenToCandidates() {
    candidatesSnapSub = roomRef
        .collection(createOrJoin ? calleeCandidatesPath : callerCandidatesPath)
        .snapshots()
        .listen(
      (snapshot) {
        for (final change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            final data = change.doc.data() as Map<String, dynamic>;

            peerConnection!.addCandidate(
              RTCIceCandidate(
                data['candidate'],
                data['sdpMid'],
                data['sdpMLineIndex'],
              ),
            );
          }
        }
      },
    );
  }

  Future<void> _deleteRoom() async {
    try {
      final calleeCandidates =
          await roomRef.collection(calleeCandidatesPath).get();
      final callerCandidates =
          await roomRef.collection(callerCandidatesPath).get();
      final labels = await roomRef.collection(labelPath).get();

      final batch = _store.batch();

      final docRefList = [
        ...calleeCandidates.docs
            .map((doc) => doc.id)
            .map((id) => roomRef.collection(calleeCandidatesPath).doc(id)),
        ...callerCandidates.docs
            .map((doc) => doc.id)
            .map((id) => roomRef.collection(callerCandidatesPath).doc(id)),
        ...labels.docs
            .map((doc) => doc.id)
            .map((id) => roomRef.collection(labelPath).doc(id)),
      ];

      for (final doc in docRefList) {
        batch.delete(doc);
      }

      await Future.wait(
        [
          batch.commit(),
          roomRef.delete(),
        ],
      );
    } catch (e) {
      throw Exception('signaling: deleteOldRoom: $e');
    }
  }

  final String senderName;
  final String senderUid;
  final String receiverUid;

  final bool createOrJoin;

  @override
  late final RTCPeerConnection? peerConnection;

  final FirebaseFirestore _store;

  late final DocumentReference roomRef;

  bool waittingForOffer = true;
  bool haveSetCanSub = false;

  late final StreamSubscription<DocumentSnapshot>? sdpSnapSub;
  late final StreamSubscription<QuerySnapshot>? candidatesSnapSub;

  FirestoreSignaling({
    required this.senderUid,
    required this.senderName,
    required this.receiverUid,
    required this.createOrJoin,
  }) : _store = FirebaseFirestore.instance {
    roomRef = _store.collection(roomPath).doc(
          generateKey(
            senderUid,
            receiverUid,
          ),
        );
  }
}

String generateKey(String sender, String receiver) {
  final keyList = [sender, receiver];
  keyList.sort((a, b) => a.compareTo(b));

  final key = '${keyList[0]}${keyList[1]}';

  return key;
}
