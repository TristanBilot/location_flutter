import 'package:app_settings/app_settings.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart' as locator;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_project/storage/memory/location_cache.dart';
import 'package:location_project/storage/shared preferences/local_store.dart';
import 'package:permission_handler/permission_handler.dart' as handler;
import '../repositories/user_repository.dart';

/// Singleton class.
class LocationController {
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  Location _location = Location();
  UserRepository _userRepository = UserRepository();

  LocationController._internal();
  static final LocationController _instance = LocationController._internal();

  factory LocationController() => _instance;

  Future enableLocation() async {
    await _enableService();
    await _grant();
    LocalStore().setLocationAsked(true);
  }

  PermissionStatus get permissionStatus => _permissionGranted;
  bool get isServiceEnabled => _serviceEnabled;

  Future<void> openLocationSettings() async {
    return AppSettings.openLocationSettings();
  }

  Future<bool> isLocationEnabled() async {
    final isEnabled = !await handler.Permission.locationWhenInUse.isDenied;

    return (isEnabled != null && isEnabled) ||
        (permissionStatus != null &&
            permissionStatus == PermissionStatus.granted);
  }

  /*
  ^ FUNCTION
  * When launched, update every 0.2s
  * the position of the device in a cache.
  */
  void _handleLocation() {
    locator.Geolocator.getPositionStream(
            desiredAccuracy: locator.LocationAccuracy.best,
            timeLimit: Duration(milliseconds: 200))
        .listen((locator.Position position) {
      /* update the location in cache */
      LocationCache()
          .putLocation(LatLng(position.latitude, position.longitude));
      /* get the location from cache and send it to Firestore */
      // final loggedUser = UserCache.getLoggedUser;
      // if (loggedUser != null) {
      //   _userRepository.updateUserLocation(
      //       loggedUser, LocationCache.locationGeoPoint);
      // }
    });
  }

  Future handleLocationIfNeeded() async {
    if (!LocationCache().isLocationAvailable && await isLocationEnabled())
      _handleLocation();
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
