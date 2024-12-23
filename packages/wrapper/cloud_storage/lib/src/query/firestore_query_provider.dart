part of 'query.dart';

class FirestoreQueryProvider implements Query {
  final firestore.Query _query;

  FirestoreQueryProvider(this._query);

  @override
  Future<QuerySnapshot> get() async {
    final querySnapshot = await _query.get();
    return FirestoreQuerySnapshotProvider(querySnapshot);
  }

  @override
  Query limit(int limit) {
    final limited = _query.limit(limit);
    return FirestoreQueryProvider(limited);
  }

  @override
  Query orderBy(Object field, {bool descending = false}) {
    final ordered = _query.orderBy(field, descending: descending);
    return FirestoreQueryProvider(ordered);
  }

  @override
  Stream<QuerySnapshot> snapshots({bool includeMetadataChanges = false}) =>
      _query.snapshots(includeMetadataChanges: includeMetadataChanges).map(
            (snapshot) => FirestoreQuerySnapshotProvider(snapshot),
          );

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
    final query = _query.where(
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

  @override
  Query withJsonModel<T extends JsonModel>(FromJson fromJson) {
    final query = _query.withConverter<JsonModel>(
        fromFirestore: (snapshot, _) => fromJson(snapshot.data()!),
        toFirestore: (model, _) => model.toJson());
    return FirestoreQueryProvider(query);
  }
}
