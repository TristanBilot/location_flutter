import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/repositories/image_repository.dart';
import 'package:location_project/repositories/user/time_measurable.dart';
import 'package:location_project/storage/memory/memory_store.dart';

class UserIconInfo implements TimeMeasurable {
  int timeToFetch;
  BitmapDescriptor icon;

  UserIconInfo(this.timeToFetch, this.icon);
}

class UserIconInfoFetcher {
  final _imageRepo = ImageRepository();

  Future<UserIconInfo> fetch(
    String id, {
    bool shouldTryFromCache = true,
  }) async {
    Stopwatch stopwatch = Stopwatch()..start();
    BitmapDescriptor icon;
    if (shouldTryFromCache && MemoryStore().userExists(id)) {
      User cachedUser = MemoryStore().getUser(id);
      icon = cachedUser.icon;
    } else {
      icon = await _imageRepo.fetchUserIcon(id);
    }
    final timeToFetch = stopwatch.elapsed.inMilliseconds;
    return UserIconInfo(timeToFetch, icon);
  }
}
