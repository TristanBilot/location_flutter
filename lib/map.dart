import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:location_project/iconPicker.dart';
import 'dart:async';
import 'areaFetcher.dart';
import 'store.dart';

class MapPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  BitmapDescriptor _pinLocationIcon;
  Set<Marker> _markers = {};

  final Completer<GoogleMapController> _controller = Completer();
  final AreaFetcher _areaFetcher = AreaFetcher();
  final IconPicker _iconPicker = IconPicker();

  @override
  void initState() {
    super.initState();
    // _iconPicker.pickImageFromGalery();

    _areaFetcher.fetch((user) {
      setState(() {
        _markers.add(Marker(
            markerId: MarkerId(user.id),
            icon: user.icon,
            position: user.coord));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    CameraPosition initialLocation =
        CameraPosition(zoom: 18, bearing: 30, target: Store.parisPosition);

    return GoogleMap(
        myLocationEnabled: true,
        markers: _markers,
        initialCameraPosition: initialLocation,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          setState(() {
            _markers.add(Marker(
                markerId: MarkerId('0'),
                position: Store.parisPosition,
                icon: _pinLocationIcon));
          });
        });
  }
}
