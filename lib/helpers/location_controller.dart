import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart' as locator;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../caches/location_cache.dart';
import '../repositories/user_repository.dart';

class LocationController {
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  Location _location;
  UserRepository _userRepository;

  static LocationController _instance;
  static LocationController get instance {
    return (_instance = _instance == null ? LocationController() : _instance);
  }

  LocationController() {
    _location = Location();
    _userRepository = UserRepository();
  }

  Future enableLocation() async {
    await _enableService();
    await _grant();
    _handleLocation();
  }

  PermissionStatus get permissionStatus => _permissionGranted;
  bool get isServiceEnabled => _serviceEnabled;

  /*
  ^ PRIVATE FUNCTION
  * When launched (at the start of the app), update every 0.5s
  * the position of the device in a cache.
  */
  void _handleLocation() {
    locator
        .getPositionStream(
            desiredAccuracy: locator.LocationAccuracy.best,
            timeLimit: Duration(milliseconds: 500))
        .listen((locator.Position position) async {
      /* update the location in cache */
      LocationCache.putLocation(LatLng(position.latitude, position.longitude));
      /* get the location from cache and send it to Firestore */
      // final loggedUser = UserCache.getLoggedUser;
      // if (loggedUser != null) {
      //   _userRepository.updateUserLocation(
      //       loggedUser, LocationCache.locationGeoPoint);
      // }
    });
  }

  /*
  ^ FUNCTION
  * Returns the current location of the device.
  */
  Future<LocationData> getLocation() async {
    return _location.getLocation();
  }

  /*
  ^ FUNCTION
  * Returns the current location of the device as a GeoFirePoint.
  */
  Future<GeoFirePoint> getLocationGeoFirePoint() async {
    final location = await getLocation();
    return Geoflutterfire()
        .point(latitude: location.latitude, longitude: location.longitude);
  }

  Future _enableService() async {
    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
  }

  Future _grant() async {
    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  // void _onLocationChanged() async {
  // _location.onLocationChanged.listen((LocationData currentLocation) {
  //   // Use current location
  // });
  // }
}
