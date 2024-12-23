import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tutor_app/blocs/webrtc/webrtc_bloc.dart';

class MicrophoneButton extends StatelessWidget {
  const MicrophoneButton(this.enable, {super.key});
  final bool enable;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: enable ? 'Close microphone.' : 'Open microphone.',
      child: Container(
        width: 50.0, // Same size as the leave button
        height: 50.0, // Same size as the leave button
        decoration: BoxDecoration(
          color: enable
              ? Colors.amber[400]
              : Colors.grey[800], // Background color of the circle
          shape: BoxShape.circle, // Makes the container circular
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              spreadRadius: 2,
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(enable ? Icons.mic_outlined : Icons.mic_off_rounded),
          onPressed: () {
            final bloc = context.read<WebrtcBloc>();
            if (enable) {
              bloc.add(
                WebrtcTrackMuted(
                  track: bloc.state.microPhoneTrack!,
                  type: 'mic',
                ),
              );
            } else {
              bloc.add(
                WebrtcTrackUnmuted(
                  track: bloc.state.microPhoneTrack!,
                  type: 'mic',
                ),
              );
            }
          },
          color: Colors.black, // Icon color
        ),
      ),
    );
  }
}
