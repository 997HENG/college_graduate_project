import 'package:cloud_firestore/cloud_firestore.dart' as firestore
    show FirebaseFirestore, WriteBatch, SetOptions, FieldValue;
import '../references/document_reference.dart';

part 'firestore_batch_provider.dart';

abstract class Batch {
  Future<void> commit();
  void delete(DocumentReference document);
  void set(DocumentReference document, Object data, {bool merge = false});
  void update(DocumentReference document, Map<String, dynamic> data);
  void updateArrayAdd(
    DocumentReference document,
    String field,
    String newElement,
  );
}
