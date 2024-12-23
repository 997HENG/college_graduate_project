import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tutor_app/blocs/llm/llm_bloc.dart';
import 'package:tutor_app/presentation/routes/model/widgets/model_list_view.dart';

class ModelRoute extends StatelessWidget {
  const ModelRoute(this.bloc, {super.key});
  final LlmBloc bloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: bloc,
      child: BlocListener<LlmBloc, LlmState>(
        listenWhen: (previous, current) =>
            current.error != null && previous.error != current.error,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('something wrong: ${state.error}'),
              duration: const Duration(
                seconds: 10,
              ), // How long the SnackBar is visibl
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () {},
              ),
            ),
          );
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('model'),
          ),
          body: Builder(
            builder: (context) {
              final status =
                  context.select((LlmBloc bloc) => bloc.state.status);

              final widget = switch (status) {
                LlmStatus.loaded => const ModelListView(),
                LlmStatus.loading =>
                  const Center(child: CircularProgressIndicator())
              };

              return widget;
            },
          ),
        ),
      ),
    );
  }
}
