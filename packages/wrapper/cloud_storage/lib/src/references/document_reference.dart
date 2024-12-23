import 'package:cloud_firestore/cloud_firestore.dart' as firestore
    show DocumentReference;
import 'package:cloud_storage/cloud_storage.dart';
import 'package:meta/meta.dart' show immutable;
import 'package:storage/storage.dart' show JsonModel, FromJson;

@immutable
abstract class DocumentReference {
  DocumentReference withJsonModel<T extends JsonModel?>(FromJson fromJson);

  CollectionReference collection(String collectionPath);

  Future<void> delete();

  Future<DocumentSnapshot> get();

  Future<void> set(Object data, {bool merge = false});

  Stream<DocumentSnapshot> snapshots({bool includeMetaChanges = false});

  Future<void> update(Map<String, Object?> data);

  String get id;

  firestore.DocumentReference get doc;
}
