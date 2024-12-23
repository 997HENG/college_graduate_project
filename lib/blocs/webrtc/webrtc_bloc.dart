import 'dart:developer' show log;

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:meta/meta.dart' show immutable;
import 'package:bloc/bloc.dart';
import 'package:signaling/signaling.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:webrtc_repository/webrtc_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

part 'webrtc_event.dart';
part 'webrtc_state.dart';

final class WebrtcBloc extends Bloc<WebrtcEvent, WebrtcState> {
  WebrtcBloc({
    required String senderUid,
    required String senderName,
    required String receiverUid,
    required bool createOrJoin,
    WebrtcRepository? webrtc,
    Signaling? signaling,
  })  : _webrtc = webrtc ?? const WebrtcRepository(),
        _signaling = signaling ??
            FirestoreSignaling(
              senderUid: senderUid,
              senderName: senderName,
              receiverUid: receiverUid,
              createOrJoin: createOrJoin,
            ),
        super(
          WebrtcState.initial(),
        ) {
    on<WebrtcInitialized>(
      _handleInitialized,
      transformer: droppable(),
    );

    on<WebrtcConnectionChanged>(
      _handleConnectionChanged,
      transformer: restartable(),
    );

    on<WebrtcSignaled>(
      _handleSignaled,
      transformer: droppable(),
    );

    on<WebrtcStreamChanged>(
      _handleStreamChanged,
      transformer: restartable(),
    );

    on<WebrtcLabelChanged>(
      _handleLabelChanged,
      transformer: restartable(),
    );

    on<WebrtcConnectionDisconnected>(
      _handleWebrtcDisconnected,
      transformer: concurrent(),
    );

    on<WebrtcConnectionFailed>(
      _handleWebrtcConnectionFailed,
      transformer: concurrent(),
    );

    on<WebrtcCamAndMicOpend>(
      _handleCamAndMicOpend,
      transformer: droppable(),
    );

    on<WebrtcDisplayOpend>(
      _handleDisplayOpend,
      transformer: droppable(),
    );

    on<WebrtcTrackMuted>(
      _handleTrackMuted,
      transformer: concurrent(),
    );

    on<WebrtcTrackUnmuted>(
      _handleTrackUnmuted,
      transformer: concurrent(),
    );

    on<WebrtcSubtitleChanged>(
      _handleSubtitleChanged,
      transformer: restartable(),
    );

    on<WebrtcSttStarted>(
      _handleSttStarted,
      transformer: restartable(),
    );

    on<WebrtcSttCanceled>(
      _handleSttCanceled,
      transformer: concurrent(),
    );
  }

  Future<void> _handleSttStarted(
    WebrtcSttStarted _,
    Emitter<WebrtcState> emit,
  ) async {
    isListening = true;

    while (isListening) {
      log('in loop');
      if (_stt.isNotListening) {
        log('start in stt');
        _stt.listen(
          localeId: 'zh_TW',
          onResult: (final result) async {
            await _signaling.updateSubtitle(result.recognizedWords);
          },
        );
        await Future.delayed(const Duration(seconds: 4));
      }
      log('stop in stt');
      await _stt.stop();
    }
  }

  Future<void> _handleSttCanceled(
    WebrtcSttCanceled _,
    Emitter<WebrtcState> emit,
  ) async {
    log('stop');
    isListening = false;
    await _stt.stop();
  }

  Future<void> _handleInitialized(
    WebrtcInitialized _,
    Emitter<WebrtcState> emit,
  ) async {
    try {
      final peerConnection = await _webrtc.initializePeerConnection();

      await state.cameraRenderer.initialize();
      await state.displayRenderer.initialize();

      _signaling.peerConnection = peerConnection;

      final (cameraMediaStream, displayMediaStream) =
          await _webrtc.initializeMediaStream();

      emit(
        state.copyWith(
          status: WebrtcStatus.initial,
          peerConnection: peerConnection,
          remoteCameraStream: cameraMediaStream,
          remoteDisplayStream: displayMediaStream,
        ),
      );

      add(const WebrtcConnectionChanged());
      add(const WebrtcStreamChanged());
      add(const WebrtcCamAndMicOpend());
    } catch (e) {
      emit(
        state.copyWith(
          status: WebrtcStatus.failed,
          error: '_handleInitialized ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _handleSignaled(
    WebrtcSignaled _,
    Emitter<WebrtcState> emit,
  ) async {
    try {
      await _signaling.handleSignaling();
    } catch (e) {
      emit(
        state.copyWith(
          status: WebrtcStatus.failed,
          error: '_handleSignaling ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _handleConnectionChanged(
    WebrtcConnectionChanged _,
    Emitter<WebrtcState> emit,
  ) async =>
      await emit
          .forEach(
            _webrtc.onPeerConnectionState(state.peerConnection),
            onData: (connectionState) => switch (connectionState) {
              RTCPeerConnectionState.RTCPeerConnectionStateNew =>
                state.copyWith(status: WebrtcStatus.connecting),
              RTCPeerConnectionState.RTCPeerConnectionStateConnecting =>
                state.copyWith(status: WebrtcStatus.connecting),
              RTCPeerConnectionState.RTCPeerConnectionStateConnected =>
                state.copyWith(status: WebrtcStatus.connected),
              RTCPeerConnectionState.RTCPeerConnectionStateFailed =>
                state.copyWith(status: WebrtcStatus.failed),
              RTCPeerConnectionState.RTCPeerConnectionStateDisconnected =>
                state.copyWith(status: WebrtcStatus.disconnected),
              RTCPeerConnectionState.RTCPeerConnectionStateClosed =>
                state.copyWith(status: WebrtcStatus.disconnected),
            },
          )
          .onError(
            (e, _) => emit(
              state.copyWith(
                status: WebrtcStatus.failed,
                error: '_handleConnectionChanged ${e.toString()}',
              ),
            ),
          );

  Future<void> _handleStreamChanged(
    WebrtcStreamChanged _,
    Emitter<WebrtcState> emit,
  ) async =>
      await emit.forEach(
        _webrtc.onTrack(state.peerConnection),
        onData: (track) {
          late final WebrtcState newState;
          final onCameraStream = state.remoteCameraStream!.getTracks().length;

          if (onCameraStream < 2) {
            state.remoteCameraStream!.addTrack(track);

            newState = state.copyWith(
              remoteCameraStream: state.remoteCameraStream,
              error: 'camera',
            );
          } else {
            state.remoteDisplayStream!.addTrack(track);

            newState = state.copyWith(
              remoteDisplayStream: state.remoteDisplayStream,
              error: 'display',
            );
          }

          return newState;
        },
      ).onError(
        (e, _) => emit(
          state.copyWith(
            status: WebrtcStatus.failed,
            error: '_handleStreamChanged ${e.toString()}',
          ),
        ),
      );
  Future<void> _handleLabelChanged(
    WebrtcLabelChanged _,
    Emitter<WebrtcState> emit,
  ) async =>
      await emit
          .forEach(
            _signaling.labelChange(),
            onData: (label) => state.copyWith(remoteLabel: label),
          )
          .onError(
            (e, _) => emit(
              state.copyWith(
                error: '_handleLabelChanged ${e.toString()}',
              ),
            ),
          );

  Future<void> _handleSubtitleChanged(
    WebrtcSubtitleChanged _,
    Emitter<WebrtcState> emit,
  ) async =>
      await emit.forEach(
        _signaling.subtitleChange(),
        onData: (subtitleRecords) {
          if (subtitleRecords.$1.isEmpty && subtitleRecords.$2.isEmpty) {
            return state;
          }
          final List<String> localSub = subtitleRecords.$1;
          final List<String> remoteSub = subtitleRecords.$2;

          return state.copyWith(
            localSub: localSub,
            remoteSub: remoteSub,
          );
        },
      ).onError(
        (e, _) => emit(
          state.copyWith(
            error: '_handleSubtitleChanged ${e.toString()}',
          ),
        ),
      );

  Future<void> _handleWebrtcConnectionFailed(
    WebrtcConnectionFailed _,
    Emitter<WebrtcState> emit,
  ) async {
    try {
      await _webrtc.cleanUp(
        state.remoteCameraStream,
        state.remoteDisplayStream,
        [state.cameraTrack, state.displayTrack, state.microPhoneTrack],
      );
      await _signaling.cleanUp();

      emit(
        state.copyWith(
          status: WebrtcStatus.disconnected,
          error: 'handle connection failed cleanup done',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          error: 'handle connection failed cleanup failed: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _handleWebrtcDisconnected(
    WebrtcConnectionDisconnected _,
    Emitter<WebrtcState> emit,
  ) async {
    try {
      await _webrtc.cleanUp(
        state.remoteCameraStream,
        state.remoteDisplayStream,
        [state.cameraTrack, state.displayTrack, state.microPhoneTrack],
      );
      await _signaling.cleanUp();
    } catch (e) {
      emit(
        state.copyWith(
          error:
              'handle connection disconnected cleanup failed: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _handleCamAndMicOpend(
    WebrtcCamAndMicOpend _,
    Emitter<WebrtcState> emit,
  ) async {
    try {
      final (l, c, m) = await _webrtc.openCameraAndMicrophone(
        state.peerConnection,
      );

      await _signaling.addTrack(c, l);
      await _signaling.addTrack(m, l);
      final newLocalLabel = {...state.localLabel, 'mic': true, 'camera': false};

      add(const WebrtcSttStarted());

      emit(
        state.copyWith(
          status: WebrtcStatus.loading,
          cameraTrack: c,
          microPhoneTrack: m,
          localLabel: newLocalLabel,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: WebrtcStatus.failed,
          error: '_handleCamAndMicOpend ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _handleDisplayOpend(
    WebrtcDisplayOpend _,
    Emitter<WebrtcState> emit,
  ) async {
    try {
      final (l, d) = await _webrtc.openDisplay(
        state.peerConnection,
      );

      await _signaling.addTrack(d, l);
      await _signaling.updateLabel(type: 'display', status: true);
      final newLocalLabel = {...state.localLabel, 'display': true};
      emit(
        state.copyWith(
          displayTrack: d,
          localLabel: newLocalLabel,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: WebrtcStatus.failed,
          error: '_handleDisplayOpend ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _handleTrackMuted(
    WebrtcTrackMuted event,
    Emitter<WebrtcState> emit,
  ) async {
    try {
      _webrtc.muteTrack(event.track);

      if (event.type == 'mic') {
        add(const WebrtcSttCanceled());
      }

      final newLocalLabel = {...state.localLabel, event.type: false};
      await _signaling.updateLabel(type: event.type, status: false);
      emit(
        state.copyWith(
          localLabel: newLocalLabel,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: WebrtcStatus.failed,
          error: '_handleTrackMuted ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _handleTrackUnmuted(
    WebrtcTrackUnmuted event,
    Emitter<WebrtcState> emit,
  ) async {
    try {
      _webrtc.unmuteTrack(event.track);
      if (event.type == 'mic') {
        add(const WebrtcSttStarted());
      }
      final newLocalLabel = {...state.localLabel, event.type: true};
      await _signaling.updateLabel(type: event.type, status: true);
      emit(
        state.copyWith(
          localLabel: newLocalLabel,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: WebrtcStatus.failed,
          error: '_handleTrackUnmuted ${e.toString()}',
        ),
      );
    }
  }

  final WebrtcRepository _webrtc;
  final Signaling _signaling;
  final SpeechToText _stt = SpeechToText()..initialize();
  bool isListening = false;

  @override
  Future<void> close() {
    try {
      state.cameraRenderer.dispose();
      state.displayRenderer.dispose();
      isListening = false;
      log('cancel');
      _stt.cancel();
      _webrtc.cleanUp(
        state.remoteCameraStream,
        state.remoteDisplayStream,
        [state.cameraTrack, state.displayTrack, state.microPhoneTrack],
      );
      _signaling.cleanUp();
    } catch (_) {}

    return super.close();
  }
}
