import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class User {
  String email;
  String firstName;
  String lastName;
  LatLng coord;
  BitmapDescriptor icon;

  User(
      {@required this.email,
      @required this.firstName,
      @required this.lastName,
      @required this.coord,
      @required this.icon});
}
