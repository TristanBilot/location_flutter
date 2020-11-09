import 'package:location_project/models/user.dart';
import 'package:location_project/repositories/user/time_measurable.dart';
import 'package:location_project/repositories/user_repository.dart';

class UserBlockInfo implements TimeMeasurable {
  int timeToFetch;
  List<String> blockedUserIDs;
  List<String> userIDsWhoBlockedMe;

  UserBlockInfo(
      this.timeToFetch, this.blockedUserIDs, this.userIDsWhoBlockedMe);
}

class UserBlockInfoFetcher {
  Future<UserBlockInfo> fetch(String id) async {
    Stopwatch stopwatch = Stopwatch()..start();
    final blockedUserIDs = await UserRepository()
        .getCollectionSnapshotAsStringArray(id, UserField.BlockedUserIDs);
    final userIDsWhoBlockedMe = await UserRepository()
        .getCollectionSnapshotAsStringArray(id, UserField.UserIDsWhoBlockedMe);
    final timeToFetch = stopwatch.elapsed.inMilliseconds;
    return UserBlockInfo(timeToFetch, blockedUserIDs, userIDsWhoBlockedMe);
  }
}
