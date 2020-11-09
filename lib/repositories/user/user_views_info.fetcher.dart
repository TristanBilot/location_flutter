import 'package:location_project/models/user.dart';
import 'package:location_project/repositories/user/time_measurable.dart';
import 'package:location_project/repositories/user_repository.dart';

class UserViewsInfo implements TimeMeasurable {
  int timeToFetch;
  List<String> viewedUserIDs;
  List<String> userIDsWhoWiewedMe;

  UserViewsInfo(this.timeToFetch, this.viewedUserIDs, this.userIDsWhoWiewedMe);
}

class UserViewsInfoFetcher {
  Future<UserViewsInfo> fetch(String id) async {
    Stopwatch stopwatch = Stopwatch()..start();
    final viewedUserIDs = await UserRepository()
        .getCollectionSnapshotAsStringArray(id, UserField.ViewedUserIDs);
    final userIDsWhoWiewedMe = await UserRepository()
        .getCollectionSnapshotAsStringArray(id, UserField.UserIDsWhoWiewedMe);
    final timeToFetch = stopwatch.elapsed.inMilliseconds;
    return UserViewsInfo(timeToFetch, viewedUserIDs, userIDsWhoWiewedMe);
  }
}
