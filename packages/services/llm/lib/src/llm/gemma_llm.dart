part of 'llm.dart';

final class GemmaLlm implements Llm {
  GemmaLlm() {
    if (io.Platform.isAndroid) {
      androidPlatform = const MethodChannel('exmple.tutor.app/channel');
    }
  }

  @override
  bool checkForModelIntergrity(LlmModelInfo modelInfo) {
    final isIntergrated = _storage.checkModelIntergrity(modelInfo);

    return isIntergrated;
  }

  @override
  Future<void> delete(LlmModelInfo model) async => await _storage.delete(model);

  @override
  Future<Stream<int>> downloadFile(
    LlmModelInfo modelInfo,
  ) async {
    if (await _storage.downloadExists(modelInfo)) {
      _storage.delete(modelInfo);
    }
    final downloadSink = await _storage.create(modelInfo);

    final downloadUrl = supportedModelDownloadUrl[modelInfo.type];

    final request = http.Request('GET', downloadUrl!);
    final response = await request.send();
    dv.log(response.headers.toString());
    final contentLength = int.parse(response.headers['content-length']!);
    dv.log('File download: $contentLength bytes');
    final downloadCompleter = Completer<bool>();
    int downloadedBytes = 0;
    int lastPercentEmitted = 0;

    _downloadControllers[modelInfo] = StreamController<int>.broadcast();

    response.stream.listen(
      (List<int> bytes) {
        downloadSink.add(bytes);
        downloadedBytes += bytes.length;
        int percent = ((downloadedBytes / contentLength) * 100).toInt();
        if ((percent > lastPercentEmitted)) {
          dv.log('ModelLocationProvider :: $percent%');

          _downloadControllers[modelInfo]!.add(percent);
          lastPercentEmitted = percent;
        }
      },
      onDone: () => downloadCompleter.complete(true),
      onError: (error, stacktrace) {
        dv.log('error: $error');
        dv.log('stacktrace: $stacktrace');
        downloadCompleter.complete(false);
      },
    );

    downloadCompleter.future.then((downloadSuccessful) async {
      if (downloadSuccessful) {
        _storage.close(modelInfo);
      } else {
        _storage.abort(modelInfo);
      }
      _downloadControllers[modelInfo]?.close();
      _downloadControllers.remove(modelInfo);
    });
    return _downloadControllers[modelInfo]!.stream;
  }

  @override
  Future<ModelInfoMap> getModelInfoMap() async {
    _modelInfoMap ??= await _storage.getLocalModelInfoMap();

    return Future.value(_modelInfoMap);
  }

  @override
  Stream<String> summary({
    required LlmModelInfo modelInfo,
    required List<String> sl1,
    required List<String> sl2,
  }) async* {
    _cacheDirPath ??= await _storage.getCacheDirPath();

    if (io.Platform.isAndroid) {
      final formattedChatHistory = _formatRoomHistory(sl1, sl2);

      final response = await androidPlatform.invokeMethod<String>(
        'generateResponse',
        {
          'path': modelInfo.path,
          'maxtoken': 4196,
          'temperature': 0.2,
          'topK': 20,
          'message': formattedChatHistory,
          'random': Random().nextInt(1000) + 1,
        },
      );

      yield response!;
      return;
    }

    _disposeCurrentEngine();

    await _initEngine(
      modelInfo,
      topK: 20,
      temperature: 0.2,
      maxTokens: 4196,
    );

    final formattedChatHistory = _formatRoomHistory(sl1, sl2);

    final responseStream = _engine!.generateResponse(formattedChatHistory);

    yield* responseStream;
  }

  @override
  Stream<String> generateResponse({
    required LlmModelInfo modelInfo,
    required List<ChatMessage> chatHistory,
    int? maxtoken,
    double? temperature,
    int? topK,
  }) async* {
    _cacheDirPath ??= await _storage.getCacheDirPath();

    if (io.Platform.isAndroid) {
      final formattedChatHistory = _formatChatHistory(chatHistory);

      final response = await androidPlatform.invokeMethod<String>(
        'generateResponse',
        {
          'path': modelInfo.path,
          'maxtoken': maxtoken,
          'temperature': temperature,
          'topK': topK,
          'message': formattedChatHistory,
          'random': Random().nextInt(1000) + 1,
        },
      );

      yield response!;
      return;
    }

    _disposeCurrentEngine();

    await _initEngine(
      modelInfo,
      topK: topK,
      temperature: temperature,
      maxTokens: maxtoken,
    );

    final formattedChatHistory = _formatChatHistory(chatHistory);

    final responseStream = _engine!.generateResponse(formattedChatHistory);

    yield* responseStream;
  }

  String _formatRoomHistory(List<String> sl1, List<String> sl2) {
    final merge = (sl1 + sl2).join('\n');

    return '這個是一個線上課堂的對話紀錄'
        '$merge\n'
        '這個對話紀錄並不表示時間關係'
        '請你依據這串對話紀錄'
        '幫我總結課堂重點'
        '必須要用繁體中文回答';
  }

  String _formatChatHistory(List<ChatMessage> chatHistory) {
    if (chatHistory.length == 1) return chatHistory.last.body;

    final formattedHistory = chatHistory
        .map<String>(
          (message) => '$beginTransmission\n'
              '${message.whoAmI}說: ${message.body}'
              '$endTransmission\n',
        )
        .join('\n');

    return 'you are "$imLLM" talking to me'
        'these records are we told before '
        'tag as "$imLLM" is what you said '
        'tag as"$imHuman" is what I said'
        'there are records'
        '$formattedHistory\n\n'
        'what about your thought ? give me a simple answer';
  }

  Future<void> _initEngine(
    LlmModelInfo modelInfo, {
    int? maxTokens,
    double? temperature,
    int? topK,
  }) async {
    final options = switch (modelInfo.type.hardware) {
      Hardware.cpu => LlmInferenceOptions.cpu(
          modelPath: modelInfo.path,
          cacheDir: _cacheDirPath!,
          maxTokens: maxTokens ?? defaultMaxTokensParameter,
          temperature: temperature ?? defaultTemperatureParameter,
          topK: topK ?? defaultTopKParameter,
          randomSeed: Random().nextInt(1000) + 1,
        ),
      Hardware.gpu => LlmInferenceOptions.gpu(
          modelPath: modelInfo.path,
          sequenceBatchSize: 20,
          maxTokens: maxTokens ?? defaultMaxTokensParameter,
          temperature: temperature ?? defaultTemperatureParameter,
          topK: topK ?? defaultTopKParameter,
          randomSeed: Random().nextInt(1000) + 1,
        ),
    };

    _engine = LlmInferenceEngine(options);
  }

  void _disposeCurrentEngine() => _engine?.dispose();

  ModelInfoMap? _modelInfoMap;
  LlmInferenceEngine? _engine;
  String? _cacheDirPath;
  late final MethodChannel androidPlatform;

  final ModelStorage _storage = IoModelStorage();
  final _downloadControllers = <LlmModelInfo, StreamController<int>>{};
}
