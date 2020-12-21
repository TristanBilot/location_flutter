import 'package:flutter/material.dart';
import 'package:location_project/repositories/image_repository.dart';
import 'package:location_project/repositories/user/time_measurable.dart';
import 'package:location_project/storage/local/custom_cache_manager.dart';

class UserPicturesInfo implements TimeMeasurable {
  int timeToFetch;
  List<Image> pictures;

  UserPicturesInfo(this.timeToFetch, this.pictures);
}

class UserPicturesInfoFetcher {
  Future<UserPicturesInfo> fetch(List<String> pictureURLs) async {
    Stopwatch stopwatch = Stopwatch()..start();
    List<Image> pictures = List();
    for (var url in pictureURLs) {
      final fileInfo = await CustomCacheManager.instance.getFileFromCache(url);
      var file = fileInfo != null ? fileInfo.file : null;
      if (fileInfo == null) {
        var fetchedFile = await ImageRepository().urlToFile(url);
        fetchedFile = await CustomCacheManager.instance.putFile(
          url,
          fetchedFile.readAsBytesSync(),
          eTag: url,
        );
        file = fetchedFile;
      }
      Image picture = Image.memory(file.readAsBytesSync());
      pictures.add(picture);
    }
    final timeToFetch = stopwatch.elapsed.inMilliseconds;
    return UserPicturesInfo(timeToFetch, pictures);
  }
}
