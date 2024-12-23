import 'package:cloud_storage/cloud_storage.dart';

abstract class QuerySnapshot {
  List<QueryDocumentSnapshot> get docs;

  int get size;
}
