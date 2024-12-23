import 'dart:async';
import 'dart:developer' show log;
import 'package:storage/storage.dart' show Notification;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

part 'constants.dart';
part 'firestore_signaling.dart';

abstract class Signaling {
  Future<void> handleSignaling();

  Future<void> addTrack(MediaStreamTrack track, MediaStream stream);

  Future<void> cleanUp();

  Stream<Map<String, bool?>> labelChange();

  Future<void> updateLabel({required String type, required bool? status});

  Stream<(List<String>, List<String>)> subtitleChange();

  Future<void> updateSubtitle(String newSubtitle);

  late final RTCPeerConnection? peerConnection;
}
