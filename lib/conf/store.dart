import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

class Store {
  static final parisPosition = LatLng(48.825024, 2.347900);
  static final carrieresposition = LatLng(48.915957, 2.179777);
  /* the size should be large, so that we can resize with the firebase 
  function and thus handle images like 400x200px etc */
  static final downloadedFbProfileImageSize = 500; // in pixels

  static final parisGeoPosition = Geoflutterfire().point(
      latitude: Store.parisPosition.latitude,
      longitude: Store.parisPosition.longitude);

  static final defaultProfilePictureExtension = '.png';
  static final defaultProfilePictureName = '?';
  static final fireStoreUserIconPath = 'photos/';

  static final double minAgeRange = 18;
  static final double maxAgeRange = 60;
}
