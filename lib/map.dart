import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'areaFetcher.dart';

class MapPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  BitmapDescriptor _pinLocationIcon;
  Set<Marker> _markers = {};
  Completer<GoogleMapController> _controller = Completer();
  AreaFetcher _areaFetcher = AreaFetcher();

  @override
  void initState() {
    super.initState();

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
    LatLng pinPosition = LatLng(48.825024, 2.347900);

    CameraPosition initialLocation =
        CameraPosition(zoom: 16, bearing: 30, target: pinPosition);

    return Stack(children: [
      GoogleMap(
          myLocationEnabled: true,
          markers: _markers,
          initialCameraPosition: initialLocation,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
            Future.delayed(Duration(milliseconds: 10000), () {
              setState(() {
                _markers.add(Marker(
                    markerId: MarkerId('<MARKER_ID>'),
                    position: pinPosition,
                    icon: _pinLocationIcon));
              });
            });
          })
    ]);
  }
}
