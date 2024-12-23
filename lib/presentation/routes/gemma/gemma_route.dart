import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:llm_model/llm_model.dart';
import 'package:tutor_app/blocs/llm/llm_bloc.dart';
import 'package:tutor_app/presentation/routes/gemma/widgets/gemma_chat_input.dart';
import 'package:tutor_app/presentation/routes/gemma/widgets/gemma_chat_list_view.dart';
import 'package:tutor_app/presentation/routes/gemma/widgets/setting_panel.dart';

class GemmaRoute extends StatelessWidget {
  GemmaRoute(this.bloc, {super.key});
  final LlmBloc bloc;
  late final LlmModelInfo modelInfo = bloc.state.currentModelInfo!;
  late final Stream<bool> messageStream = bloc.messageUpdateStream.stream;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: bloc,
      child: Builder(
        builder: (context) {
          return PopScope(
            onPopInvokedWithResult: (didPop, result) =>
                context.read<LlmBloc>().add(const LlmQuitTalking()),
            child: Scaffold(
              appBar: AppBar(
                title: Text(modelInfo.type.name),
              ),
              endDrawer: const Drawer(
                child: Padding(
                  padding: EdgeInsets.all(6),
                  child: SettingPanel(),
                ),
              ),
              body: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Column(
                  children: [
                    Expanded(child: GemmaChatListView(messageStream)),
                    const Align(
                      alignment: Alignment.bottomCenter,
                      child: GemmaChatInput(),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
