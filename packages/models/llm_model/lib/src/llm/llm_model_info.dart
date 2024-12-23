import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart' show immutable;

part 'constants.dart';

@immutable
final class LlmModelInfo extends Equatable {
  final ModelType type;
  final String path;
  final int? downloadedBytes;
  final int? downloadPercent;

  ModelState get state {
    if (downloadedBytes == 0 && downloadPercent == 0) {
      return ModelState.empty;
    }
    if (downloadedBytes != null && downloadPercent == null) {
      return ModelState.downloaded;
    } else if (downloadPercent != null) {
      if (downloadPercent == 100) {
        return ModelState.downloaded;
      }
      return ModelState.downloading;
    }
    return ModelState.empty;
  }

  LlmModelInfo copyWith({
    ModelType? type,
    String? path,
    int? downloadedBytes,
    int? downloadPercent,
  }) =>
      LlmModelInfo(
        type: type ?? this.type,
        path: path ?? this.path,
        downloadedBytes: downloadedBytes ?? this.downloadedBytes,
        downloadPercent: downloadPercent ?? this.downloadPercent,
      );

  const LlmModelInfo({
    required this.type,
    required this.path,
    this.downloadedBytes,
    this.downloadPercent,
  });

  @override
  List<Object?> get props => [
        type,
        path,
        downloadedBytes,
        downloadPercent,
      ];
}
