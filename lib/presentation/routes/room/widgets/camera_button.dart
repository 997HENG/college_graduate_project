import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tutor_app/blocs/webrtc/webrtc_bloc.dart';

class CameraButton extends StatelessWidget {
  const CameraButton(this.enable, {super.key});
  final bool enable;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: enable ? 'Close camera.' : 'Open camera.',
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
          onPressed: () {
            final bloc = context.read<WebrtcBloc>();
            if (enable) {
              bloc.add(
                WebrtcTrackMuted(
                  track: bloc.state.cameraTrack!,
                  type: 'camera',
                ),
              );
            } else {
              bloc.add(
                WebrtcTrackUnmuted(
                  track: bloc.state.cameraTrack!,
                  type: 'camera',
                ),
              );
            }
          },
          icon: Icon(
            enable ? Icons.photo_camera : Icons.no_photography,
            color: Colors.black, // Icon color
          ),
        ),
      ),
    );
  }
}
