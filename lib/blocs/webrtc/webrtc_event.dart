part of 'webrtc_bloc.dart';

@immutable
sealed class WebrtcEvent {
  const WebrtcEvent();
}

final class WebrtcInitialized extends WebrtcEvent {
  const WebrtcInitialized();
}

final class WebrtcSignaled extends WebrtcEvent {
  const WebrtcSignaled();
}

final class WebrtcStreamChanged extends WebrtcEvent {
  const WebrtcStreamChanged();
}

final class WebrtcLabelChanged extends WebrtcEvent {
  const WebrtcLabelChanged();
}

final class WebrtcConnectionFailed extends WebrtcEvent {
  const WebrtcConnectionFailed();
}

final class WebrtcConnectionDisconnected extends WebrtcEvent {
  const WebrtcConnectionDisconnected();
}

final class WebrtcConnectionChanged extends WebrtcEvent {
  const WebrtcConnectionChanged();
}

final class WebrtcCamAndMicOpend extends WebrtcEvent {
  const WebrtcCamAndMicOpend();
}

final class WebrtcDisplayOpend extends WebrtcEvent {
  const WebrtcDisplayOpend();
}

final class WebrtcTrackMuted extends WebrtcEvent {
  const WebrtcTrackMuted({required this.track, required this.type});

  final String type;
  final MediaStreamTrack track;
}

final class WebrtcTrackUnmuted extends WebrtcEvent {
  const WebrtcTrackUnmuted({required this.track, required this.type});

  final String type;
  final MediaStreamTrack track;
}

final class WebrtcSubtitleChanged extends WebrtcEvent {
  const WebrtcSubtitleChanged();
}

final class WebrtcSttStarted extends WebrtcEvent {
  const WebrtcSttStarted();
}

final class WebrtcSttCanceled extends WebrtcEvent {
  const WebrtcSttCanceled();
}
