import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tutor_app/blocs/llm/llm_bloc.dart';

class SummaryRoute extends StatelessWidget {
  const SummaryRoute(this.sl1, this.sl2, this.bloc, {super.key});
  final List<String> sl1;
  final List<String> sl2;
  final LlmBloc bloc;

  @override
  Widget build(BuildContext context) {
    log(sl1.toString());
    log(sl2.toString());
    return BlocProvider.value(
      value: bloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Summary'),
          centerTitle: true,
        ),
        body: Builder(
          builder: (context) {
            final summary = context.watch<LlmBloc>().state.summary;

            return Center(
              child: Text(summary),
            );
            // return Text('$sl1\n$sl2\n${sl1.length}\n${sl2.length}\n');
          },
        ),
      ),
    );
  }
}
