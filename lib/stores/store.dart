import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

class Store {
  static final parisPosition = LatLng(48.825024, 2.347900);

  static final parisGeoPosition = Geoflutterfire().point(
      latitude: Store.parisPosition.latitude,
      longitude: Store.parisPosition.longitude);

  static final defaultProfilePictureExtension = '.png';
  static final fireStoreUserIconPath = 'photos/';
}
