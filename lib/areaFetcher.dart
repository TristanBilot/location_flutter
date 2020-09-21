import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'user.dart';
import 'dart:async';

class AreaFetcher {
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;
  StreamController<User> _streamController = StreamController<User>();
  Stream<User> get stream => _streamController.stream;

  Location location = new Location();

  // Init firestore and geoFlutterFire
  final geo = Geoflutterfire();
  final _firestore = FirebaseFirestore.instance;

  void fetch() {
    _enableService();
    _grant();
    _getLocationData();
    // _putLocationToFireStore();
    _getUserArea((area) {});
  }

  void _putLocationToFireStore() async {
    _locationData = await location.getLocation();
    // GeoFirePoint geoPoint = geo.point(
    //     latitude: _locationData.latitude, longitude: _locationData.longitude);
    GeoFirePoint paris13 = geo.point(latitude: 48.824557, longitude: 2.363241);
    GeoFirePoint paris13_2 =
        geo.point(latitude: 48.824735, longitude: 2.362852);

    _firestore
        .collection('locations')
        .add({'name': 'random name', 'position': paris13.data});

    _firestore
        .collection('locations')
        .add({'name': 'random name', 'position': paris13_2.data});
  }

  Future<List<User>> _getUserArea(Function completion) async {
    final ref = _firestore.collection('locations');
    _locationData = await location.getLocation();
    // GeoFirePoint center = geo.point(
    // latitude: _locationData.latitude, longitude: _locationData.longitude);
    GeoFirePoint center = geo.point(latitude: 48.824557, longitude: 2.363241);

    final radius = 0.05; // 50 meters area
    final field = 'position';
    Stream<List<DocumentSnapshot>> stream = geo
        .collection(collectionRef: ref)
        .within(center: center, radius: radius, field: field);

    List<User> area = [];
    stream.listen((List<DocumentSnapshot> users) {
      // users.sort((a, b) => a.data()['distance'] < b.data()['distance']);
      users.forEach((user) {
        final geoPoint = user.data()['position']['geopoint'];
        if (geoPoint.latitude != center.latitude &&
            geoPoint.longitude != center.longitude) {
          // list of users
          _streamController.sink.add(User(
              id: 42,
              name: 'Tristan',
              coord: [geoPoint.latitude, geoPoint.longitude]));
          print('geo: ' + user.data()['position']['geopoint'].toString());
          completion(area);
        }
      });
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
