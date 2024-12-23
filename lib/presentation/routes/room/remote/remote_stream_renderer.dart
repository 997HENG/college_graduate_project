import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:tutor_app/blocs/webrtc/webrtc_bloc.dart';

class RemoteStreamRenderer extends StatefulWidget {
  const RemoteStreamRenderer({super.key});

  @override
  State<RemoteStreamRenderer> createState() => _RemoteStreamRendererState();
}

class _RemoteStreamRendererState extends State<RemoteStreamRenderer> {
  late final RTCVideoRenderer _cameraRenderer =
      context.read<WebrtcBloc>().state.cameraRenderer;
  late final RTCVideoRenderer _displayRenderer =
      context.read<WebrtcBloc>().state.displayRenderer;
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final label = context.watch<WebrtcBloc>().state.remoteLabel;
        final remoteCameraStatus = label['camera'];
        final remoteMicStatus = label['mic'];
        final remoteDisplayStatus = label['display'];

        if (remoteCameraStatus != null || remoteMicStatus != null) {
          _cameraRenderer.srcObject =
              context.read<WebrtcBloc>().state.remoteCameraStream;
        }

        if (remoteDisplayStatus != null) {
          _displayRenderer.srcObject =
              context.read<WebrtcBloc>().state.remoteDisplayStream;
        }

        final remoteStatus =
            (remoteCameraStatus, remoteMicStatus, remoteDisplayStatus);

        log(remoteStatus.toString());

        final widget = switch (remoteStatus) {
          (null || false, null || false, null || false) => const Center(
              child: Text('no signal'),
            ),
          (null || false, true, null || false) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('only sound'),
                  SizedBox.shrink(
                    child: RTCVideoView(_cameraRenderer),
                  )
                ],
              ),
            ),
          (true, _, null || false) => Row(
              children: [
                Expanded(child: RTCVideoView(_cameraRenderer)),
              ],
            ),
          (null || false, _, true) => Row(
              children: [
                Expanded(child: RTCVideoView(_displayRenderer)),
              ],
            ),
          (true, _, true) => Stack(
              children: [
                // Full-screen remote RTCVideoView
                Positioned.fill(
                  child: RTCVideoView(
                    _displayRenderer,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  ),
                ),

                // Small local camera RTCVideoView at bottom-right corner
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    margin:
                        const EdgeInsets.all(10), // Optional margin for spacing
                    width: 160, // Width of the local video view
                    height: 160, // Height of the local video view
                    child: RTCVideoView(
                      _cameraRenderer,
                      mirror:
                          true, // Optional: mirror the local video if it's a front camera
                      objectFit:
                          RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    ),
                  ),
                ),
              ],
            ),
        };

        return Stack(children: [
          widget,
          Positioned(
            bottom: 10,
            left: 20,
            right: 20,
            child: Builder(
              builder: (context) {
                final sub =
                    context.select((WebrtcBloc bloc) => bloc.state.remoteSub);

                final widget = sub.isNotEmpty
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: MediaQuery.sizeOf(context).width * 0.4,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              sub[sub.length - 1],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink();
                return widget;
              },
            ),
          )
        ]);
      },
    );
  }
}
