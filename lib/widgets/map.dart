import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

import '../helpers/location_controller.dart';
import '../interactors/area_fetcher.dart';
import '../stores/conf.dart';
import '../stores/store.dart';
import '../theme_notifier.dart';
import 'bottom_sheet.dart';

class Map extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MapState();
}

class MapState extends State<Map> with WidgetsBindingObserver {
  Set<Marker> _markers = {};
  Set<Circle> _circles;

  final Completer<GoogleMapController> _controller = Completer();
  final AreaFetcher _areaFetcher = AreaFetcher();

  LocationData _location;
  String _darkMapStyle;
  String _lightMapStyle;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadMapStyles();
    _fetchUsersAroundMe();
  }

  Future _loadMapStyles() async {
    _darkMapStyle = await rootBundle.loadString('assets/map_styles/dark.json');
    _lightMapStyle =
        await rootBundle.loadString('assets/map_styles/light.json');
  }

  void _drawCircleArea() async {
    final lightCircle = Color.fromARGB(30, 33, 155, 243);
    final lightBorder = Color.fromARGB(170, 25, 118, 210);

    _location = await LocationController.getLocation();
    _circles = Set.from([
      Circle(
        fillColor: lightCircle,
        strokeColor: lightBorder,
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
  void didChangePlatformBrightness() {
    final brightness = WidgetsBinding.instance.window.platformBrightness;
    setState(() {
      Provider.of<ThemeNotifier>(context, listen: false).setTheme(brightness);
      _manageMap();
      _drawCircleArea();
    });
  }

  Future _manageMap() async {
    final controller = await _controller.future;
    Provider.of<ThemeNotifier>(context, listen: false).doStuff(
        () => controller.setMapStyle(_lightMapStyle),
        () => controller.setMapStyle(_darkMapStyle));
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
          _manageMap();
        });
  }
}
