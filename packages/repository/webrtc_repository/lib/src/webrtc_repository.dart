import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'dart:developer' show log;

part 'constants.dart';

final class WebrtcRepository {
  const WebrtcRepository();

  Future<RTCPeerConnection> initializePeerConnection() async {
    final peerConnection = await createPeerConnection(defaultIceConfiguration);

    return peerConnection;
  }

  Stream<RTCPeerConnectionState> onPeerConnectionState(
      RTCPeerConnection? peerConnection) {
    if (peerConnection == null) {
      throw Exception('webrtc: peerConnectionState: pc is null');
    }

    final controller = StreamController<RTCPeerConnectionState>();

    controller.onCancel = () => controller.close();

    peerConnection.onConnectionState =
        (final connectionState) => controller.add(connectionState);

    return controller.stream;
  }

  Stream<MediaStreamTrack> onTrack(RTCPeerConnection? peerConnection) {
    if (peerConnection == null) {
      throw Exception('webrtc: onTrack:pc is null');
    }

    final controller = StreamController<MediaStreamTrack>();

    controller.onCancel = () => controller.close();

    peerConnection.onTrack = (final event) {
      final newTrack = event.track;
      controller.add(newTrack);
    };

    return controller.stream;
  }

  Future<
      (
        MediaStream,
        MediaStreamTrack,
        MediaStreamTrack,
      )> openCameraAndMicrophone(
    RTCPeerConnection? peerConnection,
  ) async {
    if (peerConnection == null) {
      throw Exception('webrtc: openCamera:');
    }

    final localStream =
        await navigator.mediaDevices.getUserMedia(defaultCameraConstraints);

    final cameraTrack = localStream.getVideoTracks()[0];

    final microphoneTrack = localStream.getAudioTracks()[0];

    return (localStream, cameraTrack, microphoneTrack);
  }

  Future<(MediaStream, MediaStreamTrack)> openDisplay(
    RTCPeerConnection? peerconnection,
  ) async {
    if (peerconnection == null) {
      throw Exception('webrtc: openDisplay:');
    }
    final localStream =
        await navigator.mediaDevices.getDisplayMedia(defaultDisplayConstraints);

    final displayTrack = localStream.getVideoTracks()[0];

    return (localStream, displayTrack);
  }

  void muteTrack(MediaStreamTrack track) {
    track.enabled = false;
  }

  void unmuteTrack(MediaStreamTrack track) {
    track.enabled = true;
  }

  Future<(MediaStream, MediaStream)> initializeMediaStream() async => (
        await createLocalMediaStream('camera'),
        await createLocalMediaStream('display')
      );

  Future<void> cleanUp(
    MediaStream? remoteCameraStream,
    MediaStream? remoteDisplayStream,
    List<MediaStreamTrack?> tracks,
  ) async {
    await remoteCameraStream?.dispose();
    await remoteDisplayStream?.dispose();
    for (var track in tracks) {
      await track?.stop();
    }
  }
}
