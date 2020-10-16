import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

/*
* this cache store the current updated location
* of the actual user 
*/

class LocationCache {
  static LatLng _cachedLocation;

  /// return the current location as LatLng
  static LatLng get location => _cachedLocation;

  /// return the current location as GeoFirePoint
  static GeoFirePoint get locationGeoPoint =>
      GeoFirePoint(_cachedLocation.latitude, _cachedLocation.longitude);

  /// when the location is not enabled, we need a dummy location
  static GeoFirePoint get dummyLocationGeoPoint => GeoFirePoint(0, 0);

  static void init(LatLng location) {
    putLocation(location);
  }

  static void putLocation(LatLng location) {
    _cachedLocation = location;
  }
}
