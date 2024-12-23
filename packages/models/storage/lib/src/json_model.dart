abstract class JsonModel {
  factory JsonModel.fromJson(Map<String, Object?> json) =>
      throw UnimplementedError();
  Map<String, Object?> toJson();
}

typedef FromJson = JsonModel Function(Map<String, Object?> json);

extension WithTimeStamp on JsonModel {
  Map<String, Object?> withTimeStamp() {
    final json = toJson();
    final timeStamp = DateTime.now().toIso8601String();
    json['time_stamp'] = timeStamp;
    return json;
  }
}

String timeStamp() => DateTime.now().toString();

String generateKey(String sender, String receiver) {
  final keyList = [sender, receiver];
  keyList.sort((a, b) => a.compareTo(b));

  final key = '${keyList[0]}${keyList[1]}';

  return key;
}
