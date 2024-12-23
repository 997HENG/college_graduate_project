import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart'
    as internet_connection_checker;

part 'internet_connection_provider.dart';

enum Status {
  connected,
  disconnected,
}

@immutable
abstract class Connection {
  Stream<Status> get onStatusChange;
}
