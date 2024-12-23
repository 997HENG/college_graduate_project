part of 'firestore_snapshot.dart';

final class FirestoreQuerySnapshotProvider implements QuerySnapshot {
  FirestoreQuerySnapshotProvider(this._querySnapshot);

  final firestore.QuerySnapshot _querySnapshot;

  @override
  List<QueryDocumentSnapshot> get docs => _querySnapshot.docs
      .map((queryDocumentSnapshot) =>
          FirestoreQueryDocumentSnapshotProvider(queryDocumentSnapshot))
      .toList();

  @override
  int get size => _querySnapshot.size;
}
