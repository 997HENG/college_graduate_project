import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:llm/llm.dart';
import 'package:llm_model/llm_model.dart';

part 'llm_state.dart';
part 'llm_event.dart';

final class LlmBloc extends Bloc<LlmEvent, LlmState> {
  LlmBloc({Llm? llm})
      : _llm = llm ?? GemmaLlm(),
        super(LlmState.initial()) {
    on<LlmGotLocalModelInfoMap>(
      _onLlmGotLocalModelInfoMap,
      transformer: concurrent(),
    );

    on<LlmModelDownloaded>(
      _onLlmModelDownloaded,
      transformer: droppable(),
    );

    on<LlmSetPercentDownloaded>(
      _onLlmSetPercentDownloaded,
      transformer: concurrent(),
    );

    on<LlmClearList>(
      _onLlmClearList,
      transformer: concurrent(),
    );

    on<LlmSummaried>(
      _onLlmSummried,
      transformer: concurrent(),
    );

    on<LlmModelDeleted>(
      _onLlmModelDeleted,
      transformer: concurrent(),
    );

    on<LlmTopKUpdated>(
      _onLlmTopKUpdated,
      transformer: droppable(),
    );

    on<LlmMaxTokensUpdated>(
      _onLlmMaxTokensUpdated,
      transformer: droppable(),
    );

    on<LlmTemperatureUpdated>(
      _onLlmTemperatureUpdated,
      transformer: droppable(),
    );

    on<LlmModelSelected>(
      _onLlmModelSelected,
      transformer: restartable(),
    );

    on<LlmMessageAdded>(
      _onLlmMessageAdded,
      transformer: droppable(),
    );

    on<LlmMessageExtended>(
      _onLlmMessageExtended,
      transformer: sequential(),
    );

    on<LlmMessageCompleted>(
      _onLlmMessageCompleted,
      transformer: droppable(),
    );

    on<LlmQuitTalking>(
      _onLlmStoppedTalking,
      transformer: droppable(),
    );

    add(const LlmGotLocalModelInfoMap());
  }
  Future<void> _onLlmGotLocalModelInfoMap(
    LlmGotLocalModelInfoMap _,
    Emitter<LlmState> emit,
  ) async {
    emit(state.copyWith(status: LlmStatus.loading));

    try {
      final modelInfoMap = await _llm.getModelInfoMap();

      emit(
        state.copyWith(
          status: LlmStatus.loaded,
          modelInfoMap: modelInfoMap,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(error: e.toString()),
      );
    }
  }

  Future<void> _onLlmModelDownloaded(
    LlmModelDownloaded event,
    Emitter<LlmState> emit,
  ) async {
    final modelToDownload = event.model;
    final modelInfo = state.modelInfoMap[modelToDownload]!;

    final newModelInfoMap =
        Map<ModelType, LlmModelInfo>.from(state.modelInfoMap);

    newModelInfoMap[modelToDownload] = modelInfo.copyWith(
      downloadPercent: 1,
    );

    emit(state.copyWith(modelInfoMap: newModelInfoMap));

    try {
      final isExisted = modelInfo.state == ModelState.downloaded;

      final intergrity = _llm.checkForModelIntergrity(modelInfo);

      late final Stream<int>? downloadStream;

      switch ((isExisted, intergrity)) {
        case (false, _):
          downloadStream = await _llm.downloadFile(modelInfo);
        case (true, _):
          throw Exception('Please delete this model and download again.');
      }

      await for (final percent in downloadStream) {
        add(
          LlmSetPercentDownloaded(
            model: modelToDownload,
            modelInfo: state.modelInfoMap[modelToDownload]!.copyWith(
              downloadPercent: percent,
              downloadedBytes: null,
            ),
            percentDownloaded: percent,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          error: e.toString(),
        ),
      );
    }

    final newModelInfoMap2 =
        Map<ModelType, LlmModelInfo>.from(state.modelInfoMap);

    newModelInfoMap2[modelToDownload] =
        modelInfo.copyWith(downloadPercent: 100);

    emit(state.copyWith(modelInfoMap: newModelInfoMap2));
  }

  Future<void> _onLlmSetPercentDownloaded(
    LlmSetPercentDownloaded event,
    Emitter<LlmState> emit,
  ) async {
    final newModelInfoMap =
        Map<ModelType, LlmModelInfo>.from(state.modelInfoMap);
    newModelInfoMap[event.model] = event.modelInfo;

    emit(state.copyWith(modelInfoMap: newModelInfoMap));
  }

  Future<void> _onLlmModelDeleted(
    LlmModelDeleted event,
    Emitter<LlmState> emit,
  ) async {
    final modelToDelete = event.model;
    final modelInfo = state.modelInfoMap[modelToDelete]!;
    await _llm.delete(modelInfo);

    final newModelInfoMap =
        Map<ModelType, LlmModelInfo>.from(state.modelInfoMap);

    newModelInfoMap[modelToDelete] = modelInfo.copyWith(
      downloadPercent: 0,
      downloadedBytes: 0,
    );

    emit(state.copyWith(modelInfoMap: newModelInfoMap));
  }

  Future<void> _onLlmTopKUpdated(
    LlmTopKUpdated event,
    Emitter<LlmState> emit,
  ) async {
    emit(state.copyWith(topK: event.topK));
  }

  Future<void> _onLlmMaxTokensUpdated(
    LlmMaxTokensUpdated event,
    Emitter<LlmState> emit,
  ) async {
    emit(state.copyWith(maxTokens: event.maxTokens));
  }

  Future<void> _onLlmClearList(
    LlmClearList _,
    Emitter<LlmState> emit,
  ) async {
    emit(state.copyWith(messageList: <ChatMessage>[]));
  }

  Future<void> _onLlmSummried(
    LlmSummaried event,
    Emitter<LlmState> emit,
  ) async {
    final modelInfoMap = await _llm.getModelInfoMap();
    final modelInfo = switch (Platform.isAndroid) {
      true => modelInfoMap[ModelType.gemma4bgpu],
      false => modelInfoMap[ModelType.gemma4bcpu],
    };

    if (modelInfo == null) {
      emit(state.copyWith(summary: 'No model is currently available'));
      return;
    }

    final intergrity = _llm.checkForModelIntergrity(modelInfo);

    if (intergrity == false) {
      emit(state.copyWith(summary: 'No model is currently available'));
      return;
    }

    final responseStream = _llm.summary(
      modelInfo: modelInfo,
      sl1: event.sl1,
      sl2: event.sl2,
    );

    bool first = true;

    await for (final chunk in responseStream) {
      emit(
        state.extendSummary(
          chunk,
          first: first,
          last: false,
        ),
      );

      first = false;
    }

    emit(
      state.extendSummary(
        '',
        first: first,
        last: true,
      ),
    );
  }

  Future<void> _onLlmTemperatureUpdated(
    LlmTemperatureUpdated event,
    Emitter<LlmState> emit,
  ) async {
    emit(state.copyWith(temperature: event.temperature));
  }

  Future<void> _onLlmModelSelected(
    LlmModelSelected event,
    Emitter<LlmState> emit,
  ) async {
    emit(state.copyWith(status: LlmStatus.loading));
    final modelInfo = state.modelInfoMap[event.model]!;

    final intergrity = _llm.checkForModelIntergrity(modelInfo);

    if (intergrity == false) {
      emit(
        state.copyWith(
          status: LlmStatus.loaded,
          error: 'Please delete this model and download again.',
        ),
      );
      return;
    }

    final modelSelected = state.modelInfoMap[event.model]!;

    emit(state.copyWith(
      status: LlmStatus.loaded,
      currentModelInfo: modelSelected,
      modelIntergrity: true,
    ));
  }

  Future<void> _onLlmMessageAdded(
    LlmMessageAdded event,
    Emitter<LlmState> emit,
  ) async {
    final message = event.message;
    emit(state.addMessage(message));

    final modelInfo = state.currentModelInfo!;
    final chatHistory = state.messageList;
    messageUpdateStream.add(true);

    emit(
      state
          .copyWith(
            isLlmTyping: true,
          )
          .addMessage(
            ChatMessage.llm(''),
          ),
    );

    final messageIndex = state.messageList.length - 1;

    final responseStream = _llm.generateResponse(
      modelInfo: modelInfo,
      chatHistory: chatHistory,
      topK: state.topK,
      temperature: state.temperature,
      maxtoken: state.maxTokens,
    );

    bool first = true;

    await for (final chunk in responseStream) {
      add(
        LlmMessageExtended(
          chunk: chunk,
          index: messageIndex,
          first: first,
          last: false,
        ),
      );

      first = false;
    }

    add(
      LlmMessageExtended(
        chunk: '',
        index: messageIndex,
        first: first,
        last: true,
      ),
    );

    add(const LlmMessageCompleted());
  }

  Future<void> _onLlmMessageExtended(
    LlmMessageExtended event,
    Emitter<LlmState> emit,
  ) async {
    emit(
      state.extendMessage(
        event.chunk,
        index: event.index,
        first: event.first,
        last: event.last,
      ),
    );
    messageUpdateStream.add(event.chunk == '' ? false : true);
  }

  Future<void> _onLlmMessageCompleted(
    LlmMessageCompleted event,
    Emitter<LlmState> emit,
  ) async {
    emit(state.copyWith(isLlmTyping: false).completeMessage());
  }

  Future<void> _onLlmStoppedTalking(
    LlmQuitTalking event,
    Emitter<LlmState> emit,
  ) async {
    emit(
      state.copyWith(
        currentModelInfo: null,
        modelIntergrity: false,
      ),
    );
  }

  final Llm _llm;
  final StreamController<bool> messageUpdateStream =
      StreamController<bool>.broadcast();

  @override
  Future<void> close() {
    messageUpdateStream.close();
    return super.close();
  }
}
