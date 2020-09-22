import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'package:location_project/repository.dart';
import 'dart:typed_data';
import 'user.dart';
import 'dart:async';
import 'store.dart';
import 'facebookUserJSON.dart';
import 'dart:io';

class AreaFetcher {
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  final _location = new Location();
  final _geo = Geoflutterfire();
  final _firestore = FirebaseFirestore.instance;
  final _repo = Repository();

  Future<void> fetch(Function completion) async {
    _enableService();
    _grant();
    _getLocationData();
    // _putLocationToFireStore();
    // __();
    // await _putLocationToFireStore();
    return _fetchUserArea(completion);
  }

  Future<void> insertUser(FacebookUserJSON user) async {
    _locationData = await _location.getLocation();
    // GeoFirePoint geoPoint = _geo.point(
    //     latitude: _locationData.latitude, longitude: _locationData.longitude);
    final GeoFirePoint geoPoint = _geo.point(
        latitude: Store.parisPosition.latitude,
        longitude: Store.parisPosition.longitude);

    _firestore.collection('locations').doc(user.email).set({
      'last_name': user.lastName,
      'first_name': user.firstName,
      'position': geoPoint.data,
    });

    File userPicture = await _repo.urlToFile(user.pictureURL);
    _repo.uploadFile(userPicture, user.email + '.png');
  }

  /* ++++++++++ private methods ++++++++++ */

  Future<void> _putLocationToFireStore() async {
    _locationData = await _location.getLocation();
    // GeoFirePoint geoPoint = _geo.point(
    //     latitude: _locationData.latitude, longitude: _locationData.longitude);
    GeoFirePoint paris13 = _geo.point(latitude: 48.825194, longitude: 2.347420);
    GeoFirePoint paris13_2 =
        _geo.point(latitude: 48.824710, longitude: 2.348482);

    _firestore.collection('locations').doc('camille@hotmail.fr').set({
      'email': 'kendall@hotmail.fr',
      'firstName': 'Kendall',
      'lastName': 'Jenner',
      'position': paris13.data
    });
    _firestore.collection('locations').doc('bilot.tristan@hotmail.fr').set({
      'email': 'camille@hotmail.fr',
      'firstName': 'Camille',
      'lastName': 'Houly',
      'position': paris13_2.data
    });
  }

  Future<void> _fetchUserArea(Function completion) async {
    final ref = _firestore.collection('locations');
    final GeoFirePoint center = _geo.point(
        latitude: Store.parisPosition.latitude,
        longitude: Store.parisPosition.longitude);

    final radius = 0.05; // 50 meters area
    final field = 'position';
    _locationData = await _location.getLocation();
    // GeoFirePoint center = _geo.point(
    // latitude: _locationData.latitude, longitude: _locationData.longitude);

    Stream<List<DocumentSnapshot>> stream = _geo
        .collection(collectionRef: ref)
        .within(center: center, radius: radius, field: field);
    return _listenAreaStream(stream, center, completion);
  }

  Future<void> _listenAreaStream(Stream<List<DocumentSnapshot>> stream,
      GeoFirePoint center, Function completion) async {
    stream.listen((List<DocumentSnapshot> users) async {
      users.forEach((user) async {
        final geoPoint = user.data()['position']['geopoint'];
        // if (geoPoint.latitude != center.latitude &&
        //     geoPoint.longitude != center.longitude) {
        // list of users
        final icon = await _repo.fetchUserIcon(user.id);
        final newUser = User(
            email: user.id,
            firstName: user.data()['first_name'],
            lastName: user.data()['last_name'],
            coord: LatLng(geoPoint.latitude, geoPoint.longitude),
            icon: icon);
        completion(newUser);

        print('=> in area: ' + newUser.email);
        // }
      });
    });
  }

  // Future<void> _getFireStoreImageFromId(String id, Function completion) async {
  //   final String firebasePhotoPath = 'photos/';
  //   final String userFirebaseId = 'sdsdsd.png';
  //   final String firebaseURI = 'https://firebasestorage.googleapis.com';

  //   final StorageReference ref = FirebaseStorage.instance
  //       .ref()
  //       .child(firebasePhotoPath + userFirebaseId);

  //   ref.getDownloadURL().then((fileURL) async {
  //     final String uploadedFileURL = fileURL.substring(firebaseURI.length);
  //     final Uint8List data = (await NetworkAssetBundle(Uri.parse(firebaseURI))
  //             .load(uploadedFileURL))
  //         .buffer
  //         .asUint8List();
  //     final markerIcon = BitmapDescriptor.fromBytes(data);
  //     completion(markerIcon);
  //   });
  // }

  void _enableService() async {
    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
  }

  void _grant() async {
    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  void _getLocationData() async {
    _locationData = await _location.getLocation();
    print(_locationData);
    // location.onLocationChanged.listen((LocationData currentLocation) {
    //   // Use current location
    // });
  }
}
