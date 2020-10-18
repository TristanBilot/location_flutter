import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/user.dart';

class UserMarker extends Marker {
  final User user;
  final BitmapDescriptor icon;
  final LatLng position;
  final VoidCallback onTap;

  UserMarker({
    @required this.user,
    this.icon = BitmapDescriptor.defaultMarker,
    this.position = const LatLng(0.0, 0.0),
    this.onTap,
  }) : super(markerId: MarkerId(user.id));
}
