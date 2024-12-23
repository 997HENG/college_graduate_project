part of 'llm_bloc.dart';

@immutable
sealed class LlmEvent {
  const LlmEvent();
}

final class LlmGotLocalModelInfoMap extends LlmEvent {
  const LlmGotLocalModelInfoMap();
}

final class LlmModelDownloaded extends LlmEvent {
  final ModelType model;
  const LlmModelDownloaded(this.model);
}

final class LlmSetPercentDownloaded extends LlmEvent {
  final ModelType model;
  final LlmModelInfo modelInfo;
  final int percentDownloaded;

  const LlmSetPercentDownloaded({
    required this.model,
    required this.modelInfo,
    required this.percentDownloaded,
  });
}

final class LlmModelDeleted extends LlmEvent {
  final ModelType model;
  const LlmModelDeleted(this.model);
}

final class LlmTopKUpdated extends LlmEvent {
  final int topK;
  const LlmTopKUpdated(this.topK);
}

final class LlmMaxTokensUpdated extends LlmEvent {
  final int maxTokens;
  const LlmMaxTokensUpdated(this.maxTokens);
}

final class LlmTemperatureUpdated extends LlmEvent {
  final double temperature;
  const LlmTemperatureUpdated(this.temperature);
}

final class LlmModelSelected extends LlmEvent {
  final ModelType model;
  const LlmModelSelected(this.model);
}

final class LlmMessageAdded extends LlmEvent {
  final ChatMessage message;
  const LlmMessageAdded(this.message);
}

final class LlmMessageExtended extends LlmEvent {
  final String chunk;
  final int index;
  final bool first;
  final bool last;

  const LlmMessageExtended({
    required this.chunk,
    required this.index,
    required this.first,
    required this.last,
  });
}

final class LlmMessageCompleted extends LlmEvent {
  const LlmMessageCompleted();
}

final class LlmQuitTalking extends LlmEvent {
  const LlmQuitTalking();
}

final class LlmClearList extends LlmEvent {
  const LlmClearList();
}

final class LlmSummaried extends LlmEvent {
  final List<String> sl1;
  final List<String> sl2;

  const LlmSummaried(this.sl1, this.sl2);
}
