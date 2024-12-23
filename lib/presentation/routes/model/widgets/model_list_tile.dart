import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:llm_model/llm_model.dart';
import 'package:tutor_app/blocs/connection/connection_bloc.dart';
import 'package:tutor_app/blocs/llm/llm_bloc.dart';

class ModelListTile extends StatelessWidget {
  const ModelListTile(this.modelInfo, {super.key});
  final LlmModelInfo modelInfo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.amber[50], // 背景色
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            modelInfo.type.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Builder(
            builder: (context) {
              final modelState = modelInfo.state;

              final widget = switch (modelState) {
                ModelState.downloaded => Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          context
                              .read<LlmBloc>()
                              .add(LlmModelSelected(modelInfo.type));
                        },
                        icon: const Icon(Icons.chat),
                        color: Colors.amber[600],
                      ),
                      IconButton(
                        onPressed: () {
                          context
                              .read<LlmBloc>()
                              .add(LlmModelDeleted(modelInfo.type));
                        },
                        icon: const Icon(Icons.delete),
                        color: Colors.red[300],
                      )
                    ],
                  ),
                ModelState.downloading =>
                  Text(
                    '${modelInfo.downloadPercent.toString()}%',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ModelState.empty => IconButton(
                    onPressed: () {
                      if (context.read<ConnectionBloc>().state.status !=
                          ConnectionStatus.connected) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("No Internet Connection"),
                              content: const Text(
                                  "Please connect to the internet to proceed."),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("OK"),
                                ),
                              ],
                            );
                          },
                        );

                        return;
                      }
                      context
                          .read<LlmBloc>()
                          .add(LlmModelDownloaded(modelInfo.type));
                    },
                    icon: const Icon(Icons.download),
                    color: Colors.amber[600],
                  )
              };

              return widget;
            },
          )
        ],
      ),
    );
  }
}
