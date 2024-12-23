import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'config_event.dart';
part 'config_state.dart';

class ConfigBloc extends HydratedBloc<ConfigEvent, ConfigState> {
  ConfigBloc() : super(const ConfigState()) {
    //? processing all event one by one make them won`t collision
    on<ConfigEvent>(
      _handleEvent,
      transformer: sequential(),
    );
  }

  void _handleEvent(ConfigEvent event, Emitter<ConfigState> emit) =>
      switch (event) {
        ConfigThemeChanged(:final theme) => emit(state.copyWith(theme: theme)),
      };

  @override
  fromJson(Map<String, dynamic> json) {
    return ConfigState.fromMap(json);
  }

  @override
  Map<String, dynamic>? toJson(state) => state.toMap();
}
