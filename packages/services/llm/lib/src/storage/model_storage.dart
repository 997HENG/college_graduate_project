import 'dart:async';
import 'dart:io';
import 'package:llm_model/llm_model.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:developer' show log;

part 'constants.dart';
part 'io_model_storage.dart';

typedef ModelInfoMap = Map<ModelType, LlmModelInfo>;

abstract class ModelStorage {
  Future<ModelInfoMap> getLocalModelInfoMap();

  Future<String> getCacheDirPath();

  bool checkModelIntergrity(LlmModelInfo modelInfo);

  Future<void> delete(LlmModelInfo modelInfo);

  Future<StreamSink<List<int>>> create(LlmModelInfo modelInfo);

  Future<void> close(LlmModelInfo modelInfo);

  Future<void> abort(LlmModelInfo modelInfo);

  Future<bool> downloadExists(LlmModelInfo modelInfo);
}
