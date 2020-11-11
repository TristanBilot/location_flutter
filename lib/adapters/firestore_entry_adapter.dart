import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location_project/helpers/logger.dart';
import 'package:location_project/models/firestore_entry.dart';
import 'package:location_project/use_cases/tab_pages/messaging/firestore_chat_entry.dart';

class FirestoreEntryAdapter {
  /// Generic function to transform a [DocumentSnapshot] in a
  /// FirestoreEntry [T].
  T adapt<T extends FirestoreEntry>(DocumentSnapshot snapshot) {
    if (T == Chat) return Chat.fromFirestoreObject(snapshot.data()) as T;
    Logger()
        .e('adaptFirestoreObject(): missing entry or invalid FirestoreEntry');
    return null;
  }
}
