import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location_project/helpers/location_controller.dart';
import 'dart:async';
import '../stores/repository.dart';
import '../models/user.dart';
import '../stores/store.dart';
import '../stores/cache_manager.dart';
import '../stores/conf.dart';

class AreaFetcher {
  final _geo = Geoflutterfire();
  final _firestore = FirebaseFirestore.instance;
  final _repo = Repository();

  static final double radius = 50; // 50 meters area

  /*
  ^ FUNCTION
  * Get the current location and fetch all the users
  * in the defined radius thanks to Geoflutterfire.
  * It returns the stream of User snapshots.
  */
  Future<void> fetch(Function completion) async {
    final ref = _firestore.collection('locations');
    final GeoFirePoint center = Conf.testMode
        ? Store.parisGeoPosition
        : LocationController.getLocationGeoFirePoint();
    final field = 'position';

    Stream<List<DocumentSnapshot>> stream = _geo
        .collection(collectionRef: ref)
        .within(center: center, radius: radius / 1000, field: field);
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
      users.forEach((user) async {
        final geoPoint = user.data()['position']['geopoint'];
        // if (geoPoint.latitude != center.latitude &&
        //     geoPoint.longitude != center.longitude){
        User newUser;
        if (CacheManager.userExists(user.id)) {
          newUser = CacheManager.getUser(user.id);
          newUser.coord = LatLng(geoPoint.latitude, geoPoint.longitude);
        } else {
          final icon = await _repo.fetchUserIcon(user.id);
          final downloadURL = await _repo.getPictureDownloadURL(user.id);
          newUser = User(
              user.id,
              user.data()['first_name'],
              user.data()['last_name'],
              LatLng(geoPoint.latitude, geoPoint.longitude),
              icon,
              downloadURL);
        }
        CacheManager.putUser(newUser);
        completion(newUser);
        print('=> in area: ' + newUser.email);
        // }
      });
    });
  }
}
