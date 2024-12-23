part of 'store.dart';

final class FirestoreStoreProvider implements Store {
  @override
  Batch batch() => FirestoreBatchProvider();

  @override
  FirestoreCollectionReferenceProvider collection(String collectionPath) {
    final collection = _instance.collection(collectionPath);
    return FirestoreCollectionReferenceProvider(collection);
  }

  FirestoreStoreProvider({firestore.FirebaseFirestore? instance})
      : _instance = instance ?? firestore.FirebaseFirestore.instance;

  final firestore.FirebaseFirestore _instance;
}
