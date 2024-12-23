part of 'model_storage.dart';

const defaultModelFileNameMap = {
  ModelType.gemma4bcpu: gemma4bCpuFileName,
  ModelType.gemma4bgpu: gemma4bGpuFileName,
  ModelType.gemma7bgpu: gemma7bGpuFileName,
};

final supportedModelDownloadUrl = {
  ModelType.gemma4bcpu: Uri.parse(gemma4bCpuDownloadlocation),
  ModelType.gemma4bgpu: Uri.parse(gemma4bGpuDownloadlocation),
  ModelType.gemma7bgpu: Uri.parse(gemma7bGpuDownloadlocation),
};

final supportedModelFileSize = {
  ModelType.gemma4bcpu: gemma4bCpuFileSize,
  ModelType.gemma4bgpu: gemma4bGpuFileSize,
  ModelType.gemma7bgpu: gemma7bGpuFileSize,
};
