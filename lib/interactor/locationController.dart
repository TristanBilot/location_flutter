import 'package:location/location.dart';

class LocationController {
  static bool _serviceEnabled;
  static PermissionStatus _permissionGranted;
  static LocationData _locationData;

  static Location _location;

  static Future init() async {
    _location = new Location();
    _enableService();
    _grant();
    _getLocationData();
  }

  static Future<LocationData> getLocation() async {
    return _location.getLocation();
  }

  static void _enableService() async {
    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
  }

  static void _grant() async {
    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  static void _getLocationData() async {
    _locationData = await _location.getLocation();
    print(_locationData);
    // location.onLocationChanged.listen((LocationData currentLocation) {
    //   // Use current location
    // });
  }
}
