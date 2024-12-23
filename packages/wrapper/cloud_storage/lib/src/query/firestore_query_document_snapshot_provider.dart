part of 'query.dart';

class FirestoreQueryDocumentSnapshotProvider implements QueryDocumentSnapshot {
  final firestore.QueryDocumentSnapshot _queryDocumentSnapshot;

  FirestoreQueryDocumentSnapshotProvider(this._queryDocumentSnapshot);

  @override
  Object? data() => _queryDocumentSnapshot.data();

  @override
  bool exists() => _queryDocumentSnapshot.exists;

  @override
  String id() => _queryDocumentSnapshot.id;

  @override
  T? dataWithJsonModel<T extends JsonModel>() {
    final model = _queryDocumentSnapshot.data();
    if (model != null) {
      return model as T;
    }
    return null;
  }
}
