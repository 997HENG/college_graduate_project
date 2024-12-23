import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tutor_app/blocs/llm/llm_bloc.dart';
import 'package:tutor_app/presentation/routes/model/widgets/model_list_tile.dart';
import 'package:tutor_app/presentation/routes/router/app_router.dart';

class ModelListView extends StatelessWidget {
  const ModelListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LlmBloc, LlmState>(
      listenWhen: (previous, current) =>
          current.modelIntergrity == true && previous.modelIntergrity == false,
      listener: (context, state) {
        context.push(
          RoutePath.gemma,
          extra: {'bloc': context.read<LlmBloc>()},
        );
      },
      child: Builder(
        builder: (context) {
          final modelInfoMap =
              context.select((LlmBloc bloc) => bloc.state.modelInfoMap);

          final listTiles = <Widget>[];

          for (final entry in modelInfoMap.entries) {
            final modelInfo = entry.value;
            listTiles.add(ModelListTile(modelInfo));
          }

          return ListView(children: listTiles);
        },
      ),
    );
  }
}
