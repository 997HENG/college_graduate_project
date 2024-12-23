import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tutor_app/blocs/webrtc/webrtc_bloc.dart';
import 'package:tutor_app/presentation/routes/room/widgets/camera_button.dart';
import 'package:tutor_app/presentation/routes/room/widgets/display_button.dart';
import 'package:tutor_app/presentation/routes/room/widgets/leave_button.dart';
import 'package:tutor_app/presentation/routes/room/widgets/microphone_button.dart';

class BottomActionButtons extends StatelessWidget {
  const BottomActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final label = context.select((WebrtcBloc bloc) => bloc.state.localLabel);

      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          MicrophoneButton(label['mic']!),
          const SizedBox(width: 10),
          CameraButton(label['camera']!),
          const SizedBox(width: 10),
          DisplayButton(label['display']),
          const SizedBox(width: 10),
          const LeaveButton(),
        ],
      );
    });
  }
}
