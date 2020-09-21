import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'user.dart';
import 'dart:async';

class AreaFetcher {
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  final location = new Location();
  final geo = Geoflutterfire();
  final _firestore = FirebaseFirestore.instance;

  Future<void> fetch(Function completion) async {
    _enableService();
    _grant();
    _getLocationData();
    // putLocationToFireStore();
    return _fetchUserArea(completion);
  }

  Future<void> putLocationToFireStore() async {
    _locationData = await location.getLocation();
    // GeoFirePoint geoPoint = geo.point(
    //     latitude: _locationData.latitude, longitude: _locationData.longitude);
    GeoFirePoint paris13 = geo.point(latitude: 48.825194, longitude: 2.347420);
    GeoFirePoint paris13_2 =
        geo.point(latitude: 48.824710, longitude: 2.348482);

    _firestore
        .collection('locations')
        .add({'name': 'Tristan', 'position': paris13.data});

    _firestore
        .collection('locations')
        .add({'name': 'Camille', 'position': paris13_2.data});
  }

  /* ++++++++++ private methods ++++++++++ */

  Future<void> _fetchUserArea(Function completion) async {
    final ref = _firestore.collection('locations');
    _locationData = await location.getLocation();
    // GeoFirePoint center = geo.point(
    // latitude: _locationData.latitude, longitude: _locationData.longitude);
    GeoFirePoint center = geo.point(latitude: 48.825024, longitude: 2.347900);

    final radius = 0.05; // 50 meters area
    final field = 'position';
    Stream<List<DocumentSnapshot>> stream = geo
        .collection(collectionRef: ref)
        .within(center: center, radius: radius, field: field);

    stream.listen((List<DocumentSnapshot> users) async {
      users.forEach((user) async {
        final geoPoint = user.data()['position']['geopoint'];
        if (geoPoint.latitude != center.latitude &&
            geoPoint.longitude != center.longitude) {
          // list of users
          await _getFireStoreImageFromId(user.id, (icon) {
            final newUser = User(
                id: user.id,
                name: user.data()['name'],
                coord: LatLng(geoPoint.latitude, geoPoint.longitude),
                icon: icon);
            completion(newUser);
          });

          print('geo: ' + user.data()['name'].toString());
        }
      });
    });
  }

  Future<void> _getFireStoreImageFromId(String id, Function completion) async {
    final String firebasePhotoPath = 'photos/';
    final String userFirebaseId = 'sdsdsd.png';
    final String firebaseURI = 'https://firebasestorage.googleapis.com';

    final StorageReference ref = FirebaseStorage.instance
        .ref()
        .child(firebasePhotoPath + userFirebaseId);

    ref.getDownloadURL().then((fileURL) async {
      final String uploadedFileURL = fileURL.substring(firebaseURI.length);
      final Uint8List data = (await NetworkAssetBundle(Uri.parse(firebaseURI))
              .load(uploadedFileURL))
          .buffer
          .asUint8List();
      final markerIcon = BitmapDescriptor.fromBytes(data);
      completion(markerIcon);
    });
  }

  void _enableService() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
  }

  void _grant() async {
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  void _getLocationData() async {
    _locationData = await location.getLocation();
    print(_locationData);
    // location.onLocationChanged.listen((LocationData currentLocation) {
    //   // Use current location
    // });
  }
}
