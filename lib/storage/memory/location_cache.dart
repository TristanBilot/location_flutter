import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

/*
* this cache store the current updated location
* of the actual user 
*/

/// This cache has for unique role to save
/// the most recent location of the logged user.
class LocationCache {
  LatLng _cachedLocation;

  LocationCache._internal();
  static final LocationCache _instance = LocationCache._internal();

  factory LocationCache() => _instance;

  /// return the current location as LatLng
  LatLng get location => _cachedLocation;

  /// return the current location as GeoFirePoint
  GeoFirePoint get locationGeoPoint =>
      GeoFirePoint(_cachedLocation.latitude, _cachedLocation.longitude);

  /// when the location is not enabled, we need a dummy location
  GeoFirePoint get dummyLocationGeoPoint => GeoFirePoint(0, 0);

  void putLocation(LatLng location) {
    _cachedLocation = location;
  }

  /// True if a location is store in the cache.
  bool get isLocationAvailable => _cachedLocation != null;
}
