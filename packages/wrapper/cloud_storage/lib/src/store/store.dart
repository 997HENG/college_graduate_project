import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:meta/meta.dart' show immutable;
import '../references/references.dart';
import '../batch/batch.dart';

part 'firestore_store_provider.dart';

@immutable
abstract class Store {
  CollectionReference collection(String collectionPath);
  Batch batch();
}
