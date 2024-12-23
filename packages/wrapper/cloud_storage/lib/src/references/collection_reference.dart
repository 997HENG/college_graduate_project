import 'package:meta/meta.dart' show immutable;
import 'package:storage/storage.dart' show JsonModel, FromJson;
import 'document_reference.dart';
import '../snapshots/query_snapshot.dart';
import '../query/query.dart';

@immutable
abstract class CollectionReference {
  CollectionReference withJsonModel<T extends JsonModel>(FromJson fromJson);

  Future<DocumentReference> add(Object? data);

  DocumentReference doc([String? path]);

  Future<QuerySnapshot> get();

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
