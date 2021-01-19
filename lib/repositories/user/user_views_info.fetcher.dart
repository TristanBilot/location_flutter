import 'package:location_project/repositories/user/time_measurable.dart';
import 'package:location_project/repositories/user_repository.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/view.dart';

class UserViewsInfo implements TimeMeasurable {
  int timeToFetch;
  List<View> viewedUserIDs;
  List<View> userIDsWhoViewedMe;

  UserViewsInfo(this.timeToFetch, this.viewedUserIDs, this.userIDsWhoViewedMe);
}

class UserViewsInfoFetcher {
  Future<UserViewsInfo> fetch(String id) async {
    Stopwatch stopwatch = Stopwatch()..start();
    final viewedUserIDs = await UserRepository().fetchViewsAsList(id);
    final userIDsWhoViewedMe = await UserRepository().fetchViewsAsList(id);
    final timeToFetch = stopwatch.elapsed.inMilliseconds;
    return UserViewsInfo(timeToFetch, viewedUserIDs, userIDsWhoViewedMe);
  }
}
