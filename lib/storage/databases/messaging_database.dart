import 'package:hive/hive.dart';

class MessagingDatabase {
  static const MessagingBox = 'Messaging';

  static const NbChatsKey = 'nb_discussions';
  static const NbRequestsKey = 'nb_requests';
  static const NbViewsKey = 'nb_views';

  static const NbUnreadChatsKey = 'nb_unread_discussions';
  static const NbUnreadRequestsKey = 'nb_unread_requests';
  static const NbUnreadViewsKey = 'nb_unread_views';

  MessagingDatabase._internal();
  static final MessagingDatabase _instance = MessagingDatabase._internal();
  factory MessagingDatabase() => _instance;

  static Future<void> initHiveDatabase() async {
    _instance._box = await Hive.openBox(MessagingBox);
  }

  Box _box;

  Future<void> put({
    int nbChats,
    int nbUnreadChats,
    int nbRequests,
    int nbUnreadRequests,
    int nbViews,
    int nbUnreadViews,
  }) async {
    if (nbChats != null) _box.put(NbChatsKey, nbChats);
    if (nbUnreadChats != null) _box.put(NbUnreadChatsKey, nbUnreadChats);
    if (nbRequests != null) _box.put(NbRequestsKey, nbRequests);
    if (nbUnreadRequests != null)
      _box.put(NbUnreadRequestsKey, nbUnreadRequests);
    if (nbViews != null) _box.put(NbViewsKey, nbViews);
    if (nbUnreadViews != null) _box.put(NbUnreadViewsKey, nbUnreadViews);
  }

  int get({
    bool nbChats,
    bool nbUnreadChats,
    bool nbRequests,
    bool nbUnreadRequests,
    bool nbViews,
    bool nbUnreadViews,
  }) {
    if (nbChats != null) return _box.get(NbChatsKey) ?? 0;
    if (nbUnreadChats != null) return _box.get(NbUnreadChatsKey) ?? 0;
    if (nbRequests != null) return _box.get(NbRequestsKey) ?? 0;
    if (nbUnreadRequests != null) return _box.get(NbUnreadRequestsKey) ?? 0;
    if (nbViews != null) return _box.get(NbViewsKey) ?? 0;
    if (nbUnreadViews != null) return _box.get(NbUnreadViewsKey) ?? 0;
    return 0;
  }

  Future clear() async {
    _box.deleteFromDisk();
  }
}
