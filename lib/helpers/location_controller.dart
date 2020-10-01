import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart' as locator;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationController {
  static bool _serviceEnabled;
  static PermissionStatus _permissionGranted;
  static Location _location;
  static LatLng _cachedLocation;

  static LatLng get location => _cachedLocation;
  static GeoFirePoint get locationGeoPoint =>
      GeoFirePoint(_cachedLocation.latitude, _cachedLocation.longitude);

  /*
  ^ FUNCTION
  * This method should be used at first and after that,
  * only use the static methods.
  */
  static Future init() async {
    _location = new Location();
    await _enableService();
    await _grant();
    _handleLocation();
  }

  /*
  ^ PRIVATE FUNCTION
  * When launched (at the start of the app), update every 0.5s
  * the position of the device in a cache variable.
  */
  static void _handleLocation() {
    locator
        .getPositionStream(
            desiredAccuracy: locator.LocationAccuracy.best,
            timeLimit: Duration(milliseconds: 500))
        .listen((locator.Position position) async {
      _cachedLocation = LatLng(position.latitude, position.longitude);
    });
  }

  /*
  ^ FUNCTION
  * Returns the current location of the device.
  */
  static Future<LocationData> getLocation() async {
    return _location.getLocation();
  }

  /*
  ^ FUNCTION
  * Returns the current location of the device as a GeoFirePoint.
  */
  static Future<GeoFirePoint> getLocationGeoFirePoint() async {
    final location = await getLocation();
    return Geoflutterfire()
        .point(latitude: location.latitude, longitude: location.longitude);
  }

  static Future _enableService() async {
    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
  }

  static Future _grant() async {
    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  static void _onLocationChanged() async {
    // _location.onLocationChanged.listen((LocationData currentLocation) {
    //   // Use current location
    // });
  }
}
