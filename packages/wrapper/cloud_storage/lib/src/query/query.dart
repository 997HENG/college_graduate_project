import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:storage/storage.dart' show JsonModel, FromJson;
import '../snapshots/snapshots.dart';

part 'firestore_query_provider.dart';
part 'firestore_query_document_snapshot_provider.dart';

abstract class Query {
  Query withJsonModel<T extends JsonModel>(FromJson fromJson);

  Future<QuerySnapshot> get();

  Query limit(int limit);

  Query orderBy(Object field, {bool descending = false});

  Stream<QuerySnapshot> snapshots({bool includeMetadataChanges = false});

  Query where(
    Object field, {
    Object? isEqualTo,
    Object? isNotEqualTo,
    Object? isLessThan,
    Object? isLessThanOrEqualTo,
    Object? isGreaterThan,
    Object? isGreaterThanOrEqualTo,
    Object? arrayContains,
    Iterable<Object?>? arrayContainsAny,
    Iterable<Object?>? whereIn,
    Iterable<Object?>? whereNotIn,
    bool? isNull,
  });
}

abstract class QueryDocumentSnapshot {
  bool exists();

  String id();

  Object? data();

  T? dataWithJsonModel<T extends JsonModel>();
}
