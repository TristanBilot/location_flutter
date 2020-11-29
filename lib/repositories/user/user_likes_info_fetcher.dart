import 'package:location_project/models/user.dart';
import 'package:location_project/repositories/user/time_measurable.dart';
import 'package:location_project/repositories/user_repository.dart';

class UserLikesInfo implements TimeMeasurable {
  int timeToFetch;
  List<String> likedUsers;
  List<String> unlikedUsers;

  UserLikesInfo(this.timeToFetch, this.likedUsers, this.unlikedUsers);
}

class UserLikesInfoFetcher {
  Future<UserLikesInfo> fetch(String id) async {
    Stopwatch stopwatch = Stopwatch()..start();
    final likedUsers = await UserRepository()
        .getCollectionSnapshotAsStringArray(id, UserField.LikedUsers);
    final unlikedUsers = await UserRepository()
        .getCollectionSnapshotAsStringArray(id, UserField.UnlikedUsers);
    final timeToFetch = stopwatch.elapsed.inMilliseconds;
    return UserLikesInfo(timeToFetch, likedUsers, unlikedUsers);
  }
}
