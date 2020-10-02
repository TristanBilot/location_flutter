import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_project/caches/location_cache.dart';
import 'package:location_project/repositories/area_fetching_repository.dart';

import '../stores/conf.dart';
import '../stores/store.dart';
import 'bottom_sheet.dart';

class Map extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MapState();
}

class _MapState extends State<Map> with WidgetsBindingObserver {
  Set<Marker> _markers;
  Set<Circle> _circles;

  Completer<GoogleMapController> _controller;
  AreaFetchingRepository _areaFetcher;

  _MapState() {
    _markers = {};
    _controller = Completer();
    _areaFetcher = AreaFetchingRepository();
  }

  String _darkMapStyle;
  String _lightMapStyle;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadMapStyles().then((_) => _setMapStyle());
    _fetchUsersAroundMe();
    // _drawCircleArea();
  }

  Future _loadMapStyles() async {
    _darkMapStyle = await rootBundle.loadString('assets/map_styles/dark.json');
    _lightMapStyle =
        await rootBundle.loadString('assets/map_styles/light.json');
  }

  Future _setMapStyle() async {
    final controller = await _controller.future;
    final theme = WidgetsBinding.instance.window.platformBrightness;
    if (theme == Brightness.dark)
      controller.setMapStyle(_darkMapStyle);
    else
      controller.setMapStyle(_lightMapStyle);
  }

  void _drawCircleArea() async {
    final lightCircle = Color.fromARGB(30, 33, 155, 243);
    final lightBorder = Color.fromARGB(170, 25, 118, 210);

    _circles = Set.from([
      Circle(
        fillColor: lightCircle,
        strokeColor: lightBorder,
        strokeWidth: 1,
        circleId: CircleId('area'),
        center: LocationCache.location,
        radius: AreaFetchingRepository.radius,
      )
    ]);
  }

  Future _fetchUsersAroundMe() async {
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
  void didChangePlatformBrightness() {
    setState(() {
      _setMapStyle();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    CameraPosition initialLocation = CameraPosition(
        zoom: 18,
        target: Conf.testMode ? Store.parisPosition : LocationCache.location);

    return GoogleMap(
        mapType: MapType.normal,
        myLocationEnabled: true,
        markers: _markers,
        circles: Conf.displayAreaCircle ? _circles : null,
        initialCameraPosition: initialLocation,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        });
  }
}
