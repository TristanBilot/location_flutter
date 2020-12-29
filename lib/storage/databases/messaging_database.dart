import 'package:shared_preferences/shared_preferences.dart';

class MessagingDatabase {
  static const MessagingBox = 'Messaging';

  static const NbMatchesKey = 'nb_matches';
  static const NbUnreadChatsKey = 'nb_unread_matches';
  static const NbLikesKey = 'nb_likes';
  static const NbViewsKey = 'nb_views';

  static const NbNewChatsKey = 'nb_new_chats';
  static const NbNewLikesKey = 'nb_new_likes';
  static const NbNewViewsKey = 'nb_new_views';

  MessagingDatabase._internal();
  static final MessagingDatabase _instance = MessagingDatabase._internal();
  factory MessagingDatabase() => _instance;

  SharedPreferences _prefs;

  static Future<MessagingDatabase> initAsynchronously() async {
    await _instance.getSharedPreferencesInstance();
    return _instance;
  }

  Future<void> getSharedPreferencesInstance() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> put({
    int nbMatches, // all the chats (matches)
    int nbNewMatches, // only the chats with no conversation engaged
    int nbUnreadChats, // chats unread (notifs)
    int nbLikes,
    int nbNewLikes,
    int nbViews,
    int nbNewViews,
  }) async {
    if (nbMatches != null) _prefs.setInt(NbMatchesKey, nbMatches);
    if (nbNewMatches != null) _prefs.setInt(NbNewChatsKey, nbNewMatches);
    if (nbUnreadChats != null) _prefs.setInt(NbUnreadChatsKey, nbUnreadChats);
    if (nbLikes != null) _prefs.setInt(NbLikesKey, nbLikes);
    if (nbNewLikes != null) _prefs.setInt(NbNewLikesKey, nbNewLikes);
    if (nbViews != null) _prefs.setInt(NbViewsKey, nbViews);
    if (nbNewViews != null) _prefs.setInt(NbNewViewsKey, nbNewViews);
  }

  int get({
    bool nbMatches,
    bool nbNewMatches,
    bool nbUnreadChats,
    bool nbLikes,
    bool nbNewLikes,
    bool nbViews,
    bool nbNewViews,
  }) {
    if (nbMatches != null) return _prefs.getInt(NbMatchesKey) ?? 0;
    if (nbNewMatches != null) return _prefs.getInt(NbNewChatsKey) ?? 0;
    if (nbUnreadChats != null) return _prefs.getInt(NbUnreadChatsKey) ?? 0;
    if (nbLikes != null) return _prefs.getInt(NbLikesKey) ?? 0;
    if (nbNewLikes != null) return _prefs.getInt(NbNewLikesKey) ?? 0;
    if (nbViews != null) return _prefs.getInt(NbViewsKey) ?? 0;
    if (nbNewViews != null) return _prefs.getInt(NbNewViewsKey) ?? 0;
    return 0;
  }

  Future clear() async {
    _prefs.clear();
  }
}
