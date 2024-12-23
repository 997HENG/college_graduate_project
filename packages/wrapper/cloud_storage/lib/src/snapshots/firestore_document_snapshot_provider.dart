part of 'firestore_snapshot.dart';

final class FirestoreDocumentSnapshotProvider implements DocumentSnapshot {
  final firestore.DocumentSnapshot _documentSnapshot;

  FirestoreDocumentSnapshotProvider(this._documentSnapshot);

  @override
  Object? data() => _documentSnapshot.data();

  @override
  bool exists() => _documentSnapshot.exists;

  @override
  String id() => _documentSnapshot.id;

  @override
  T? dataWithJsonModel<T extends JsonModel>() {
    final model = _documentSnapshot.data();
    if (model != null) {
      return model as T;
    }
    return null;
  }
}
