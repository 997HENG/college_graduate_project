part of 'model_storage.dart';

final class IoModelStorage implements ModelStorage {
  @override
  Future<String> getCacheDirPath() async {
    final cacheDir = await getApplicationCacheDirectory();
    return cacheDir.absolute.path;
  }

  @override
  Future<ModelInfoMap> getLocalModelInfoMap() async {
    final ModelInfoMap modelInfoMap = {};
    final modelFolder = await _getModelFolder();

    for (var entry in defaultModelFileNameMap.entries) {
      final type = entry.key;
      final fileName = entry.value;
      final path = '${modelFolder.path}/$fileName';

      final binary = File(path);

      final isExists = await binary.exists();

      final modelInfo = isExists
          ? LlmModelInfo(
              type: type,
              path: path,
              downloadedBytes: binary.lengthSync(),
            )
          : LlmModelInfo(
              type: type,
              path: path,
            );

      modelInfoMap[type] = modelInfo;
    }

    return modelInfoMap;
  }

  Directory? _modelFolder;
  Future<Directory> _getModelFolder() async {
    _modelFolder ??= await getApplicationDocumentsDirectory();

    return Future.value(_modelFolder);
  }

  @override
  Future<void> abort(LlmModelInfo modelInfo) async {
    final location = modelInfo.path;

    if (!_downloadCache.containsKey(location)) {
      throw Exception('Abort called for location $location, which is not the '
          'site of an ongoing donwload.');
    }
    final file = File(location);
    if (await file.exists()) {
      await file.delete();
    }
    _downloadCache[location]!.close();
    _downloadCache.remove(location);
  }

  @override
  Future<void> close(LlmModelInfo modelInfo) async {
    final location = modelInfo.path;

    if (!_downloadCache.containsKey(location)) {
      throw Exception('Abort called for location $location, which is not the '
          'site of an ongoing donwload.');
    }
    _downloadCache[location]!.close();
    _downloadCache.remove(location);
  }

  final _downloadCache = <String, StreamSink<List<int>>>{};

  @override
  Future<StreamSink<List<int>>> create(LlmModelInfo modelInfo) async {
    final file = File(modelInfo.path);
    if (await file.exists()) {
      throw Exception(
        'Attempted to download on top of existing file at '
        '${modelInfo.path}. Delete that file before proceeding.',
      );
    }
    _downloadCache[modelInfo.path] = file.openWrite();
    return _downloadCache[modelInfo.path]!;
  }

  @override
  Future<void> delete(LlmModelInfo modelInfo) async {
    final filePath = File(modelInfo.path);

    if (await filePath.exists()) {
      await filePath.delete();
    }
  }

  @override
  Future<bool> downloadExists(LlmModelInfo modelInfo) async =>
      File(modelInfo.path).exists();

  @override
  bool checkModelIntergrity(LlmModelInfo modelInfo) {
    final file = File(modelInfo.path);

    if (!file.existsSync()) {
      return false;
    }

    final intergrity =
        file.lengthSync() == supportedModelFileSize[modelInfo.type];

    return intergrity;
  }
}
