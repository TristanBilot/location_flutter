import 'package:hive/hive.dart';

class MessagingDatabase {
  static const MessagingBox = 'Messaging';

  static const NbDiscussionsKey = 'nb_discussions';
  static const NbRequestsKey = 'nb_requests';
  static const NbViewsKey = 'nb_views';

  MessagingDatabase._internal();
  static final MessagingDatabase _instance = MessagingDatabase._internal();
  factory MessagingDatabase() => _instance;

  static Future<void> initHiveDatabase() async {
    _instance._box = await Hive.openBox(MessagingBox);
  }

  Box _box;

  Future<void> putNbDiscussions(int nb) async {
    _box.put(NbDiscussionsKey, nb);
  }

  Future<void> putNbRequests(int nb) async {
    _box.put(NbRequestsKey, nb);
  }

  Future<void> putNbViews(int nb) async {
    _box.put(NbViewsKey, nb);
  }

  int getNbDiscussions() {
    return _box.get(NbDiscussionsKey) ?? 0;
  }

  int getNbRequests() {
    return _box.get(NbRequestsKey) ?? 0;
  }

  int getNbViews() {
    return _box.get(NbViewsKey) ?? 0;
  }

  Future clear() async {
    _box.clear();
  }
}
