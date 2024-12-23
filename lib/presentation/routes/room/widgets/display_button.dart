import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tutor_app/blocs/webrtc/webrtc_bloc.dart';

class DisplayButton extends StatelessWidget {
  const DisplayButton(this.enable, {super.key});
  final bool? enable;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: switch (enable) {
        null => 'Open display.',
        true => 'Close display.',
        false => 'Open display.'
      },
      child: Container(
        width: 50.0, // Same size as the leave button
        height: 50.0, // Same size as the leave button
        decoration: BoxDecoration(
          color: switch (enable) {
            null => Colors.grey[800],
            true => Colors.amber[400],
            false => Colors.grey[800]
          },
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
            switch (enable) {
              case true:
                bloc.add(
                  WebrtcTrackMuted(
                    track: bloc.state.displayTrack!,
                    type: 'display',
                  ),
                );
              case false:
                bloc.add(
                  WebrtcTrackUnmuted(
                    track: bloc.state.displayTrack!,
                    type: 'display',
                  ),
                );
              case null:
                bloc.add(const WebrtcDisplayOpend());
            }
          },
          icon: Icon(
            switch (enable) {
              null => Icons.cast,
              true => Icons.cast_connected,
              false => Icons.cast
            },
            color: Colors.black, // Icon color
          ),
        ),
      ),
    );
  }
}
