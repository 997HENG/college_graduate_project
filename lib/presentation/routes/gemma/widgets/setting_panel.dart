import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tutor_app/blocs/llm/llm_bloc.dart';

class SettingPanel extends StatelessWidget {
  const SettingPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final topK = context.select((LlmBloc bloc) => bloc.state.topK!);
      final temperature =
          context.select((LlmBloc bloc) => bloc.state.temperature!);
      final maxTokens = context.select((LlmBloc bloc) => bloc.state.maxTokens!);

      return ListView(
        children: <Widget>[
          Text('Top K', style: Theme.of(context).textTheme.bodyLarge),
          Text('Number of tokens to be sampled from for each decoding step.',
              style: Theme.of(context).textTheme.bodySmall),
          Slider(
            value: topK.toDouble(),
            min: 1,
            max: 100,
            divisions: 100,
            onChanged: (newTopK) =>
                context.read<LlmBloc>().add(LlmTopKUpdated(newTopK.toInt())),
          ),
          Text(
            topK.toString(),
            style: Theme.of(context)
                .textTheme
                .bodySmall!
                .copyWith(color: Colors.grey),
          ),
          const Divider(),
          Text('Temperature', style: Theme.of(context).textTheme.bodyLarge),
          Text('Randomness when decoding the next token.',
              style: Theme.of(context).textTheme.bodySmall),
          Slider(
            value: temperature,
            min: 0,
            max: 1,
            onChanged: (newTemperature) => context
                .read<LlmBloc>()
                .add(LlmTemperatureUpdated(newTemperature)),
          ),
          Text(
            temperature.roundTo(3).toString(),
            style: Theme.of(context)
                .textTheme
                .bodySmall!
                .copyWith(color: Colors.grey),
          ),
          const Divider(),
          Text('Max Tokens', style: Theme.of(context).textTheme.bodyLarge),
          Text(
              'Maximum context window for the LLM. Larger windows can tax '
              'certain devices.',
              style: Theme.of(context).textTheme.bodySmall),
          Slider(
            value: maxTokens.toDouble(),
            min: 512,
            max: 8192,
            onChanged: (newMaxTokens) => context
                .read<LlmBloc>()
                .add(LlmMaxTokensUpdated(newMaxTokens.toInt())),
          ),
          Text(
            maxTokens.toString(),
            style: Theme.of(context)
                .textTheme
                .bodySmall!
                .copyWith(color: Colors.grey),
          ),
          const Divider(),
          IconButton(
              onPressed: () =>
                  context.read<LlmBloc>().add(const LlmClearList()),
              icon: const Icon(Icons.close_sharp)),
          const Divider(),
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.exit_to_app_rounded),
          )
        ],
      );
    });
  }
}

extension on double {
  double roundTo(int decimalPlaces) =>
      double.parse(toStringAsFixed(decimalPlaces));
}
