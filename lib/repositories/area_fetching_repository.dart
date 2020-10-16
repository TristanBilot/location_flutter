import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location_project/caches/location_cache.dart';
import 'dart:async';
import 'image_repository.dart';
import '../models/user.dart';
import '../stores/store.dart';
import '../caches/user_cache.dart';
import '../stores/conf.dart';
import '../stores/extensions.dart';

class AreaFetchingRepository {
  Geoflutterfire _geo;
  FirebaseFirestore _firestore;
  ImageRepository _imageRepo;

  static final double radius = 50; // 50 meters area

  AreaFetchingRepository() {
    _geo = Geoflutterfire();
    _firestore = FirebaseFirestore.instance;
    _imageRepo = ImageRepository();
  }

  /*
  ^ FUNCTION
  * Get the current location and fetch all the users
  * in the defined radius thanks to Geoflutterfire.
  * It returns the stream of User snapshots.
  */
  Future<void> fetch(Function completion) async {
    final ref = _firestore.collection('locations');

    final GeoFirePoint center =
        Conf.testMode ? Store.parisGeoPosition : LocationCache.locationGeoPoint;
    Stream<List<DocumentSnapshot>> stream = _geo
        .collection(collectionRef: ref)
        .within(
            center: center,
            radius: radius / 1000,
            field: UserField.Position.value);
    return _listenAreaStream(stream, center, completion);
  }

  /* 
  ^ PRIVATE FUNCTION
  * Listens to the stream of users around the current location.
  * For each user around, the picture is fetched and a User object 
  * is created. The completion is used to setState() in the view
  * to update the list of markers to display to the map.
  */
  Future<void> _listenAreaStream(Stream<List<DocumentSnapshot>> stream,
      GeoFirePoint center, Function completion) async {
    stream.listen((List<DocumentSnapshot> users) async {
      int userCount = 0;
      List<User> usersList = List();
      users.forEach((user) async {
        userCount++;
        final geoPoint = user.data()[UserField.Position.value]['geopoint'];
        final geoFirePoint =
            GeoFirePoint(geoPoint.latitude, geoPoint.longitude);
        final distance = (GeoFirePoint.distanceBetween(
                    to: center.coords, from: geoFirePoint.coords) *
                1000)
            .toInt();
        // if (geoPoint.latitude != center.latitude &&
        //     geoPoint.longitude != center.longitude){
        User newUser;
        if (!UserCache.isInit || !UserCache.userExists(user.id)) {
          final icon = await _imageRepo.fetchUserIcon(user.id);
          final downloadURL = await _imageRepo.getPictureDownloadURL(user.id);
          newUser = User(
              user.id,
              user.data()[UserField.FirstName.value],
              user.data()[UserField.LastName.value],
              LatLng(geoPoint.latitude, geoPoint.longitude),
              icon,
              downloadURL,
              distance);
        } else {
          newUser = UserCache.getUser(user.id);
          newUser.coord = LatLng(geoPoint.latitude, geoPoint.longitude);
        }
        if (UserCache.isInit) {
          UserCache.putUser(newUser);
        }
        usersList.add(newUser);
        if (userCount == users.length) completion(usersList);
        print('=> in area: ${newUser.email} at $distance meters');
        // }
      });
    });
  }
}
