part of 'llm_bloc.dart';

enum LlmStatus {
  loading,
  loaded,
}

final class LlmState extends Equatable {
  final LlmStatus status;
  final ModelInfoMap modelInfoMap;
  final bool modelIntergrity;
  final LlmModelInfo? currentModelInfo;
  final List<ChatMessage> messageList;
  final bool isLlmTyping;
  final String? error;
  final double? temperature;
  final int? topK;
  final int? maxTokens;
  final String summary;

  factory LlmState.initial() {
    return LlmState(
      status: LlmStatus.loading,
      modelIntergrity: false,
      modelInfoMap: ModelInfoMap(),
      messageList: const <ChatMessage>[],
      isLlmTyping: false,
      topK: defaultTopKParameter,
      temperature: defaultTemperatureParameter,
      maxTokens: defaultMaxTokensParameter,
      summary: '',
    );
  }

  LlmState copyWith({
    LlmStatus? status,
    ModelInfoMap? modelInfoMap,
    bool? modelIntergrity,
    LlmModelInfo? currentModelInfo,
    List<ChatMessage>? messageList,
    bool? isLlmTyping,
    String? error,
    double? temperature,
    int? topK,
    int? maxTokens,
    String? summary,
  }) {
    return LlmState(
      status: status ?? this.status,
      modelInfoMap: modelInfoMap ?? this.modelInfoMap,
      modelIntergrity: modelIntergrity ?? this.modelIntergrity,
      messageList: messageList ?? this.messageList,
      isLlmTyping: isLlmTyping ?? this.isLlmTyping,
      error: error ?? this.error,
      currentModelInfo: currentModelInfo ?? this.currentModelInfo,
      temperature: temperature ?? this.temperature,
      topK: topK ?? this.topK,
      maxTokens: maxTokens ?? this.maxTokens,
      summary: summary ?? this.summary,
    );
  }

  LlmState addMessage(ChatMessage message) {
    final newMessageList = _copyMessageList();

    newMessageList.add(message);

    return copyWith(messageList: newMessageList);
  }

  LlmState extendMessage(
    String chunk, {
    required int index,
    required bool first,
    required bool last,
  }) {
    final newMessageList = _copyMessageList();

    final oldMessage = newMessageList[index];
    final newMessage = oldMessage.copyWith(
      body: '${oldMessage.body}$chunk'.sanitize(first, last),
    );
    newMessageList[index] = newMessage;
    return copyWith(messageList: newMessageList);
  }

  LlmState extendSummary(
    String chunk, {
    required bool first,
    required bool last,
  }) {
    final newSummary = '$summary$chunk'.sanitize(first, last);

    return copyWith(summary: newSummary);
  }

  LlmState completeMessage() {
    final newMessageList = _copyMessageList();

    newMessageList.last = newMessageList.last.copyWith(isComplete: true);

    return copyWith(messageList: newMessageList);
  }

  List<ChatMessage> _copyMessageList() {
    final newMesageList = List<ChatMessage>.from(messageList);
    return newMesageList;
  }

  const LlmState({
    required this.status,
    required this.modelInfoMap,
    required this.modelIntergrity,
    this.currentModelInfo,
    required this.messageList,
    required this.isLlmTyping,
    required this.summary,
    this.error,
    this.temperature,
    this.topK,
    this.maxTokens,
  });

  @override
  List<Object?> get props => [
        status,
        modelInfoMap,
        currentModelInfo,
        messageList,
        isLlmTyping,
        error,
        temperature,
        topK,
        maxTokens,
        modelIntergrity,
        summary,
      ];

  @override
  String toString() {
    return '';
  }
}

extension on String {
  String sanitize(bool first, bool last) {
    final firstOrLast = <String>['\n', ' '];
    final invalidSubstrings = <String>[
      ':',
      ';',
      beginTransmission,
      endTransmission,
      'LLM',
      'Human',
    ];
    String val = sanitizeBeginning(
      invalidSubstrings..addAll(first ? firstOrLast : []),
    );
    return val.sanitizeEnd(
      invalidSubstrings..addAll(last ? firstOrLast : []),
    );
  }

  String sanitizeBeginning(List<String> invalidSubstrings) {
    String val = this;
    while (true) {
      String? matchingSubstring;
      for (String invalidSubstring in invalidSubstrings) {
        if (val.startsWith(invalidSubstring)) {
          matchingSubstring = invalidSubstring;
          break;
        }
      }
      if (matchingSubstring != null) {
        val = val.substring(matchingSubstring.length);
      } else {
        break;
      }
    }
    return val;
  }

  String sanitizeEnd(List<String> invalidSubstrings) {
    String val = this;
    while (true) {
      String? matchingSubstring;
      for (String invalidSubstring in invalidSubstrings) {
        if (val.endsWith(invalidSubstring)) {
          matchingSubstring = invalidSubstring;
          break;
        }
      }
      if (matchingSubstring != null) {
        val = val.substring(0, val.length - matchingSubstring.length);
      } else {
        break;
      }
    }
    return val;
  }
}
