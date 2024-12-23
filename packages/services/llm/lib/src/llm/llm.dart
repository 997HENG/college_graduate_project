import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';
import 'dart:math';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/services.dart';
import 'package:llm_model/llm_model.dart';
import 'package:mediapipe_genai/mediapipe_genai.dart';
import '../storage/model_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as dv show log;
import 'dart:io' as io show Platform;

part 'gemma_llm.dart';
part 'constants.dart';

abstract class Llm {
  Future<void> delete(LlmModelInfo model);

  Future<Stream<int>> downloadFile(LlmModelInfo modelInfo);

  Future<ModelInfoMap> getModelInfoMap();

  bool checkForModelIntergrity(LlmModelInfo modelInfo);

  Stream<String> summary({
    required LlmModelInfo modelInfo,
    required List<String> sl1,
    required List<String> sl2,
  });

  Stream<String> generateResponse({
    required LlmModelInfo modelInfo,
    required List<ChatMessage> chatHistory,
    int? maxtoken,
    double? temperature,
    int? topK,
  });
}
