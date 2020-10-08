import 'package:google_maps_flutter/google_maps_flutter.dart';

class User {
  String email;
  String firstName;
  String lastName;
  LatLng coord;
  BitmapDescriptor icon;
  String pictureURL;
  int distance;

  User(String email, String firstName, String lastName, LatLng coord,
      BitmapDescriptor icon, String pictureURL, int distance) {
    this.lastName = lastName;
    this.firstName = firstName;
    this.email = email;
    this.coord = coord;
    this.icon = icon;
    this.pictureURL = pictureURL;
    this.distance = distance;
  }
}
