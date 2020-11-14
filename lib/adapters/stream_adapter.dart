import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location_project/adapters/firestore_entry_adapter.dart';
import 'package:location_project/models/firestore_entry.dart';

class StreamAdapter {
  final _firestoreEntryAdapter = FirestoreEntryAdapter();

  /// Tranforms a Stream: each [QuerySnapshot] become a
  /// FirestoreEntry element [T] and are added to a list.
  StreamTransformer<QuerySnapshot, List<T>>
      mapToListOfEntries<T extends FirestoreEntry>() {
    return StreamTransformer<QuerySnapshot, List<T>>.fromHandlers(
        handleData: (QuerySnapshot snapshot, EventSink<List<T>> sink) {
      var elements = List<T>();
      snapshot.docs.forEach((doc) {
        final e = _firestoreEntryAdapter.adapt<T>(doc);
        elements.add(e);
      });
      sink.add(elements);
    });
  }

  /// Tranforms a Stream<QuerySnapshot> in a Stream<List<T>>.
  StreamTransformer<QuerySnapshot, List<T>> mapToListOf<T>() {
    return StreamTransformer<QuerySnapshot, List<T>>.fromHandlers(
        handleData: (QuerySnapshot snapshot, EventSink<List<T>> sink) {
      var elements = List<T>();
      snapshot.docs.forEach((doc) => elements.add(doc.data() as T));
      sink.add(elements);
    });
  }
}
