import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'tab_state.dart';
part 'tab_event.dart';

class TabBloc extends HydratedBloc<TabEvent, TabState> {
  TabBloc() : super(const TabState.main()) {
    on<TabEvent>(
      _handleTabPressed,
      transformer: sequential(),
    );
  }

  void _handleTabPressed(TabEvent event, Emitter<TabState> emit) {
    emit(const TabState.loading());

    final state = switch (event) {
      TabMainPressed() => const TabState.main(),
      TabFriendsPressed() => const TabState.friends(),
      TabGroupPressed() => const TabState.group(),
      TabNotificationsPressed() => const TabState.notifications(),
    };

    emit(state);
  }

  @override
  TabState? fromJson(Map<String, dynamic> json) => TabState.fromMap(json);

  @override
  Map<String, dynamic>? toJson(TabState state) => state.toMap();
}
