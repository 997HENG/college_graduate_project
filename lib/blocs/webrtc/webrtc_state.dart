part of 'webrtc_bloc.dart';

enum WebrtcStatus {
  initial,
  loading,
  connecting,
  connected,
  failed,
  disconnected,
}

final class WebrtcState extends Equatable {
  final WebrtcStatus status;

  final RTCPeerConnection? peerConnection;

  final RTCVideoRenderer cameraRenderer;
  final RTCVideoRenderer displayRenderer;

  final MediaStream? remoteCameraStream;
  final MediaStream? remoteDisplayStream;

  final MediaStreamTrack? cameraTrack;
  final MediaStreamTrack? microPhoneTrack;
  final MediaStreamTrack? displayTrack;

  final Map<String, bool?> remoteLabel;
  final Map<String, bool?> localLabel;

  final List<String> localSub;
  final List<String> remoteSub;

  final String? error;

  const WebrtcState({
    required this.status,
    required this.cameraRenderer,
    required this.displayRenderer,
    required this.peerConnection,
    required this.remoteCameraStream,
    required this.remoteDisplayStream,
    required this.cameraTrack,
    required this.microPhoneTrack,
    required this.displayTrack,
    required this.remoteLabel,
    required this.localLabel,
    required this.localSub,
    required this.remoteSub,
    required this.error,
  });

  WebrtcState copyWith(
          {WebrtcStatus? status,
          RTCPeerConnection? peerConnection,
          RTCVideoRenderer? cameraRenderer,
          RTCVideoRenderer? diplayRenderer,
          MediaStream? remoteCameraStream,
          MediaStream? remoteDisplayStream,
          MediaStreamTrack? cameraTrack,
          MediaStreamTrack? microPhoneTrack,
          MediaStreamTrack? displayTrack,
          Map<String, bool?>? remoteLabel,
          Map<String, bool?>? localLabel,
          List<String>? localSub,
          List<String>? remoteSub,
          String? error}) =>
      WebrtcState(
        status: status ?? this.status,
        cameraRenderer: cameraRenderer ?? this.cameraRenderer,
        displayRenderer: diplayRenderer ?? displayRenderer,
        peerConnection: peerConnection ?? this.peerConnection,
        remoteCameraStream: remoteCameraStream ?? this.remoteCameraStream,
        remoteDisplayStream: remoteDisplayStream ?? this.remoteDisplayStream,
        cameraTrack: cameraTrack ?? this.cameraTrack,
        microPhoneTrack: microPhoneTrack ?? this.microPhoneTrack,
        displayTrack: displayTrack ?? this.displayTrack,
        remoteLabel: remoteLabel ?? this.remoteLabel,
        localLabel: localLabel ?? this.localLabel,
        localSub: localSub ?? this.localSub,
        remoteSub: remoteSub ?? this.remoteSub,
        error: error ?? this.error,
      );

  WebrtcState.initial()
      : status = WebrtcStatus.initial,
        cameraRenderer = RTCVideoRenderer(),
        displayRenderer = RTCVideoRenderer(),
        peerConnection = null,
        remoteCameraStream = null,
        remoteDisplayStream = null,
        cameraTrack = null,
        microPhoneTrack = null,
        displayTrack = null,
        remoteLabel = {
          'camera': false,
          'mic': true,
          'display': null,
        },
        localLabel = {
          'camera': null,
          'mic': null,
          'display': null,
        },
        localSub = <String>[],
        remoteSub = <String>[],
        error = null;

  @override
  List<Object?> get props => [
        status,
        cameraRenderer,
        displayRenderer,
        peerConnection,
        remoteCameraStream,
        remoteDisplayStream,
        cameraTrack,
        microPhoneTrack,
        displayTrack,
        remoteLabel,
        localLabel,
        localSub,
        remoteSub,
        error,
      ];

  @override
  String toString() => '$status\n $localSub $remoteSub $error\n';
}
