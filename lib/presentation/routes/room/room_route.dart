
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tutor_app/blocs/llm/llm_bloc.dart';
import 'package:tutor_app/blocs/webrtc/webrtc_bloc.dart';
import 'package:tutor_app/presentation/routes/room/remote/remote_stream_renderer.dart';
import 'package:tutor_app/presentation/routes/room/widgets/bottom_action_buttons.dart';
import 'package:tutor_app/presentation/routes/room/widgets/leave_button.dart';
import 'package:tutor_app/presentation/routes/router/app_router.dart';

class RoomRoute extends StatelessWidget {
  const RoomRoute({
    super.key,
    required this.senderName,
    required this.senderUid,
    required this.receiverUid,
    required this.isCreate,
  });
  final String senderName;
  final String senderUid;
  final String receiverUid;
  final bool isCreate;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WebrtcBloc(
        senderUid: senderUid,
        senderName: senderName,
        receiverUid: receiverUid,
        createOrJoin: isCreate,
      )..add(const WebrtcInitialized()),
      child: MultiBlocListener(
        listeners: [
          BlocListener<WebrtcBloc, WebrtcState>(
            listenWhen: (previous, current) =>
                previous.status == WebrtcStatus.initial &&
                current.status == WebrtcStatus.loading,
            listener: (context, _) =>
                context.read<WebrtcBloc>()..add(const WebrtcSignaled()),
          ),
          BlocListener<WebrtcBloc, WebrtcState>(
            listenWhen: (previous, current) =>
                previous.status != WebrtcStatus.connected &&
                current.status == WebrtcStatus.connected,
            listener: (context, _) => context.read<WebrtcBloc>()
              ..add(const WebrtcLabelChanged())
              ..add(const WebrtcSubtitleChanged()),
          ),
          BlocListener<WebrtcBloc, WebrtcState>(
            listenWhen: (previous, current) =>
                previous.status == WebrtcStatus.connected &&
                current.status == WebrtcStatus.disconnected,
            listener: (context, _) => context
                .read<WebrtcBloc>()
                .add(const WebrtcConnectionDisconnected()),
          ),
          BlocListener<WebrtcBloc, WebrtcState>(
            listenWhen: (previous, current) =>
                previous.status != WebrtcStatus.failed &&
                current.status == WebrtcStatus.failed,
            listener: (context, _) =>
                context.read<WebrtcBloc>().add(const WebrtcConnectionFailed()),
          ),
          BlocListener<WebrtcBloc, WebrtcState>(
            listenWhen: (previous, current) =>
                previous.error != current.error &&
                current.error != null &&
                current.error != 'camera' &&
                current.error != 'display',
            listener: (context, state) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('something wrong: ${state.error}'),
                  duration: const Duration(
                    seconds: 10,
                  ), // How long the SnackBar is visible`
                  action: SnackBarAction(
                    label: 'ok',
                    onPressed: () {},
                  ),
                ),
              );
            },
          )
        ],
        child: Scaffold(
          body: Builder(
            builder: (context) {
              final status =
                  context.select((WebrtcBloc bloc) => bloc.state.status);

              final widget = switch (status) {
                WebrtcStatus.initial => const Center(
                    child: Text('initialize....'),
                  ),
                WebrtcStatus.connected => const RemoteStreamRenderer(),
                WebrtcStatus.failed => const Center(
                    child: Text('failed'),
                  ),
                WebrtcStatus.disconnected => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Disconnected',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                            height:
                                10), // Adds spacing between the text and the button
                        TextButton(
                          onPressed: () {
                            final sl1 =
                                context.read<WebrtcBloc>().state.localSub;
                            final sl2 =
                                context.read<WebrtcBloc>().state.remoteSub;

                            if (sl1.isEmpty && sl2.isEmpty) {
                              showDialog(
                                context: context,
                                barrierDismissible:
                                    false, // Prevents closing by tapping outside
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Operation Not Allowed'),
                                    content: const Text(
                                        'You can\'t do this operation because there is no content in the class.'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); // Close the dialog
                                        },
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }

                            context.push(
                              RoutePath.summary,
                              extra: {
                                'sl1': sl1,
                                'sl2': sl2,
                                'context': context.read<LlmBloc>(),
                              },
                            );

                            context.read<LlmBloc>().add(LlmSummaried(sl1, sl2));
                          },
                          child: const Text('Go to Summary'),
                        ),
                      ],
                    ),
                  ),
                _ => const Center(
                    child: CircularProgressIndicator(),
                  )
              };
              return widget;
            },
          ),
          floatingActionButton: Builder(
            builder: (context) {
              final status =
                  context.select((WebrtcBloc bloc) => bloc.state.status);

              final widget = switch (status) {
                WebrtcStatus.connected => const BottomActionButtons(),
                _ => const LeaveButton(),
              };
              return widget;
            },
          ),
        ),
      ),
    );
  }
}
