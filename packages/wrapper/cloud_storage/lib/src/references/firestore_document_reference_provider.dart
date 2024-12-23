part of 'firestore_reference.dart';

final class FirestoreDocumentReferenceProvider implements DocumentReference {
  FirestoreDocumentReferenceProvider(this._documentReference);

  final firestore.DocumentReference _documentReference;

  @override
  DocumentReference withJsonModel<T extends JsonModel?>(FromJson fromJson) {
    final documentReference = _documentReference.withConverter<JsonModel>(
        fromFirestore: (snapshot, _) => fromJson(snapshot.data()!),
        toFirestore: (model, _) => model.toJson());
    return FirestoreDocumentReferenceProvider(documentReference);
  }

  @override
  CollectionReference collection(String collectionPath) {
    final collectionReference = _documentReference.collection(collectionPath);
    return FirestoreCollectionReferenceProvider(collectionReference);
  }

  @override
  Future<void> delete() async => await _documentReference.delete();

  @override
  Future<DocumentSnapshot> get() async {
    final documentSnapshot = await _documentReference.get();
    return FirestoreDocumentSnapshotProvider(documentSnapshot);
  }

  @override
  Future<void> set(Object data, {bool merge = false}) async =>
      await _documentReference.set(data, firestore.SetOptions(merge: merge));

  @override
  Stream<DocumentSnapshot> snapshots({bool includeMetaChanges = false}) =>
      _documentReference
          .snapshots(includeMetadataChanges: includeMetaChanges)
          .map((snapshot) => FirestoreDocumentSnapshotProvider(snapshot));

  @override
  Future<void> update(Map<Object, Object?> data) async =>
      await _documentReference.update(data);

  @override
  firestore.DocumentReference<Object?> get doc => _documentReference;

  @override
  String get id => _documentReference.id;
}
