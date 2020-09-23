import 'package:location/location.dart';

class LocationController {
  static bool _serviceEnabled;
  static PermissionStatus _permissionGranted;
  static Location _location;

  /*
  ^ FUNCTION
  * This method should be used at first and after that,
  * only use the static methods.
  */
  static Future init() async {
    _location = new Location();
    _enableService();
    _grant();
  }

  /*
  ^ FUNCTION
  * Returns the current location of the device.
  */
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

  static void _onLocationChanged() async {
    // _location.onLocationChanged.listen((LocationData currentLocation) {
    //   // Use current location
    // });
  }
}
