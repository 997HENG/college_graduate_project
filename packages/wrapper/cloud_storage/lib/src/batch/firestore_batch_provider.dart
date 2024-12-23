part of 'batch.dart';

class FirestoreBatchProvider implements Batch {
  final firestore.WriteBatch _batch;

  FirestoreBatchProvider({firestore.WriteBatch? batch})
      : _batch = batch ?? firestore.FirebaseFirestore.instance.batch();

  @override
  Future<void> commit() async => await _batch.commit();

  @override
  void delete(DocumentReference document) => _batch.delete(document.doc);

  @override
  void set(DocumentReference document, Object data, {bool merge = false}) =>
      _batch.set(document.doc, data, firestore.SetOptions(merge: merge));

  @override
  void update(DocumentReference document, Map<String, dynamic> data) =>
      _batch.update(document.doc, data);

  @override
  void updateArrayAdd(
    DocumentReference document,
    String field,
    String newElement,
  ) =>
      _batch.update(
        document.doc,
        {
          field: firestore.FieldValue.arrayUnion(
            [newElement],
          )
        },
      );
}
