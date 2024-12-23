part of 'connection.dart';

final class InternetConnectionProvider implements Connection {
  InternetConnectionProvider({
    internet_connection_checker.InternetConnection? instance,
  }) : _instance = instance ?? internet_connection_checker.InternetConnection();

  @override
  Stream<Status> get onStatusChange => _onStatusChange();

  Stream<Status> _onStatusChange() async* {
    final isConnected = await _instance.hasInternetAccess;
    yield switch (isConnected) {
      true => Status.connected,
      false => Status.disconnected
    };
    yield* _instance.onStatusChange.map<Status>(_convert);
  }

  Status _convert(internet_connection_checker.InternetStatus status) =>
      switch (status) {
        internet_connection_checker.InternetStatus.connected =>
          Status.connected,
        internet_connection_checker.InternetStatus.disconnected =>
          Status.disconnected,
      };

  final internet_connection_checker.InternetConnection _instance;
}
