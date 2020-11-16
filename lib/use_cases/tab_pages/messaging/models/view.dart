import 'package:location_project/models/firestore_entry.dart';
import '../../../../stores/extensions.dart';

enum ViewField {
  Id,
  IsViewed,
}

class View implements FirestoreEntry {
  final String id;
  final bool isViewed;

  View(this.id, this.isViewed);

  @override
  List<Object> get props => [id, isViewed];

  @override
  bool get stringify => null;

  dynamic toFirestoreObject() {
    return {
      ViewField.Id.value: id,
      ViewField.IsViewed.value: isViewed,
    };
  }

  static View fromFirestoreObject(dynamic data) {
    return View(
      data[ViewField.Id.value],
      data[ViewField.IsViewed.value],
    );
  }
}
