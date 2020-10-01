import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

/*
* this cache store the current updated location
* of the actual user 
*/

class LocationCache {
  static LatLng _cachedLocation;

  /* return the current location as LatLng */
  static LatLng get location => _cachedLocation;

  /* reutrn the current location as GeoFirePoint */
  static GeoFirePoint get locationGeoPoint =>
      GeoFirePoint(_cachedLocation.latitude, _cachedLocation.longitude);

  static void init(LatLng location) {
    putLocation(location);
  }

  static void putLocation(LatLng location) {
    _cachedLocation = location;
  }
}
