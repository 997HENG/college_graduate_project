import 'package:storage/storage.dart' show JsonModel;

abstract class DocumentSnapshot {
  bool exists();
  String id();
  Object? data();
  T? dataWithJsonModel<T extends JsonModel>();
}
