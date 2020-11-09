import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_project/caches/user_cache.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/repositories/image_repository.dart';
import 'package:location_project/repositories/user/time_measurable.dart';

class UserPicturesInfo implements TimeMeasurable {
  int timeToFetch;
  BitmapDescriptor icon;
  String pictureURL;

  UserPicturesInfo(this.timeToFetch, this.icon, this.pictureURL);
}

class UserPicturesInfoFetcher {
  final _imageRepo = ImageRepository();

  Future<UserPicturesInfo> fetch(
    String id, {
    bool shouldTryFromCache = true,
  }) async {
    Stopwatch stopwatch = Stopwatch()..start();
    BitmapDescriptor icon;
    dynamic pictureURL;
    if (shouldTryFromCache && UserCache().userExists(id)) {
      User cachedUser = UserCache().getUser(id);
      icon = cachedUser.icon;
      pictureURL = cachedUser.pictureURL;
    } else {
      icon = await _imageRepo.fetchUserIcon(id);
      pictureURL = await _imageRepo.getPictureDownloadURL(id);
    }
    final timeToFetch = stopwatch.elapsed.inMilliseconds;
    return UserPicturesInfo(timeToFetch, icon, pictureURL);
  }
}
