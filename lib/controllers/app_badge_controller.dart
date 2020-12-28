import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:location_project/storage/databases/messaging_database.dart';

class AppBadgeController {
  final MessagingDatabase _database = MessagingDatabase();

  void updateAppBadge() {
    int count = _database.get(nbUnreadChats: true) +
        _database.get(nbNewMatches: true) +
        _database.get(nbNewLikes: true) +
        _database.get(nbNewViews: true);
    FlutterAppBadger.updateBadgeCount(count);
  }
}
