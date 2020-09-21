import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class User {
  String id;
  String name;
  LatLng coord;
  BitmapDescriptor icon;

  User(
      {@required this.id,
      @required this.name,
      @required this.coord,
      @required this.icon});
}
