import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:location_project/widgets/bottom_sheet.dart';
import 'dart:async';
import '../interactors/area_fetcher.dart';
import '../stores/store.dart';
import '../stores/conf.dart';
import '../helpers/location_controller.dart';

class Map extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MapState();
}

class MapState extends State<Map> {
  Set<Marker> _markers = {};
  Set<Circle> _circles;

  final Completer<GoogleMapController> _controller = Completer();
  final AreaFetcher _areaFetcher = AreaFetcher();

  var _location;

  @override
  void initState() {
    super.initState();
    _fetchUsersAroundMe();
  }

  void _drawCircleArea() async {
    _location = await LocationController.getLocation();
    _circles = Set.from([
      Circle(
        fillColor: Color.fromARGB(30, 0, 0, 0),
        strokeWidth: 1,
        circleId: CircleId('area'),
        center: LatLng(_location.latitude, _location.longitude),
        radius: AreaFetcher.radius,
      )
    ]);
  }

  void _fetchUsersAroundMe() async {
    _location = await LocationController.getLocation();
    _areaFetcher.fetch((user) {
      setState(() {
        _markers.add(Marker(
            markerId: MarkerId(user.email),
            icon: user.icon,
            position: user.coord,
            onTap: () {
              showFloatingModalBottomSheet(user: user, context: context);
            }));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    CameraPosition initialLocation = CameraPosition(
        zoom: 18,
        target: Conf.testMode
            ? Store.parisPosition
            : LatLng(_location.latitude, _location.longitude));

    return GoogleMap(
        mapType: MapType.normal,
        myLocationEnabled: true,
        markers: _markers,
        circles: Conf.displayAreaCircle ? _circles : null,
        initialCameraPosition: initialLocation,
        onCameraMove: null,
        /* TODO */
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          _drawCircleArea();
        });
  }
}
