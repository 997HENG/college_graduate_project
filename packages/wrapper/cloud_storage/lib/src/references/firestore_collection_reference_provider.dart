part of 'firestore_reference.dart';

final class FirestoreCollectionReferenceProvider
    implements CollectionReference {
  FirestoreCollectionReferenceProvider(this._collectionReference);

  final firestore.CollectionReference _collectionReference;

  @override
  CollectionReference withJsonModel<T extends JsonModel>(
    FromJson fromJson,
  ) {
    final collectionReference = _collectionReference.withConverter<JsonModel>(
        fromFirestore: (snapshot, _) => fromJson(snapshot.data()!),
        toFirestore: (model, _) => model.toJson());
    return FirestoreCollectionReferenceProvider(collectionReference);
  }

  @override
  Future<DocumentReference> add(Object? data) async {
    final documentReference = await _collectionReference.add(data);
    return FirestoreDocumentReferenceProvider(documentReference);
  }

  @override
  DocumentReference doc([String? path]) {
    final documentReference = _collectionReference.doc(path);
    return FirestoreDocumentReferenceProvider(documentReference);
  }

  @override
  Future<QuerySnapshot> get() async {
    final querySnapshot = await _collectionReference.get();
    return FirestoreQuerySnapshotProvider(querySnapshot);
  }

  @override
  Stream<QuerySnapshot> snapshots({bool includeMetadataChanges = false}) =>
      _collectionReference
          .snapshots(includeMetadataChanges: includeMetadataChanges)
          .map(
              (querySnapshot) => FirestoreQuerySnapshotProvider(querySnapshot));

  @override
  Query where(Object field,
      {Object? isEqualTo,
      Object? isNotEqualTo,
      Object? isLessThan,
      Object? isLessThanOrEqualTo,
      Object? isGreaterThan,
      Object? isGreaterThanOrEqualTo,
      Object? arrayContains,
      Iterable<Object?>? arrayContainsAny,
      Iterable<Object?>? whereIn,
      Iterable<Object?>? whereNotIn,
      bool? isNull}) {
    final query = _collectionReference.where(
      field,
      isEqualTo: isEqualTo,
      isNotEqualTo: isNotEqualTo,
      isLessThan: isLessThan,
      isLessThanOrEqualTo: isLessThanOrEqualTo,
      isGreaterThan: isGreaterThan,
      isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
      arrayContains: arrayContains,
      arrayContainsAny: arrayContainsAny,
      whereIn: whereIn,
      whereNotIn: whereNotIn,
    );
    return FirestoreQueryProvider(query);
  }
}
