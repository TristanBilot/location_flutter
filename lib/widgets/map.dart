import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:location_project/conf/conf.dart';
import 'package:location_project/conf/store.dart';
import 'package:location_project/controllers/location_controller.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/repositories/area_fetching_repository.dart';
import 'package:location_project/repositories/user_repository.dart';
import 'package:location_project/storage/distant/user_store.dart';
import 'package:location_project/storage/memory/location_cache.dart';
import 'package:location_project/widgets/user_map_card.dart';

import 'user_marker.dart';

class Map extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MapState();
}

class MapState extends State<Map> with WidgetsBindingObserver {
  Set<UserMarker> _markers;
  Set<Circle> _circles;

  Completer<GoogleMapController> _controller;
  AreaFetchingRepository _areaFetcher;

  MapState() {
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
    LocationController().handleLocationIfNeeded();
    _handleBlockEvents();

    _loadMapStyles().then((_) => _setMapStyle());
  }

  /// Used to handle when a user block the logged user and
  /// then refresh the page to not see the user on the map
  void _handleBlockEvents() {
    UserRepository().listenToUsersWhoBlockMeEvents(
        UserStore().user.id, _fetchUsersAroundMe);
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
        center: LocationCache().location,
        radius: AreaFetchingRepository.radius,
      )
    ]);
  }

  /*
  * mandatory to use in _fetchUsersAroundMe() to avoid retaining.
  */
  void setStateIfMounted(Function f) {
    if (mounted) setState(f);
  }

  _onMarkerTap(context, User user) {
    UserMapCard(context, user, _fetchUsersAroundMe).show();
  }

  Future _fetchUsersAroundMe() async {
    // in the case when the user enable location from settings
    // we need to handle location again
    _areaFetcher.fetch((users) {
      setStateIfMounted(() {
        _markers.clear();
        // may be faster but need 2 times checkinf for unliked
        // users in the code, here for first load and in the build()
        users.forEach((user) {
          _markers.add(UserMarker(
              user: user,
              icon: user.icon,
              position: LatLng(user.coord[0], user.coord[1]),
              onTap: () => _onMarkerTap(context, user)));
        });
      });
    });
  }

  void update(Function completion) {
    setState(() {
      completion();
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

  Future<bool> _waitForBuildMap() async {
    return Future.delayed(Duration(milliseconds: 10), () => true);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _waitForBuildMap(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Column(children: [
            Spacer(),
            Container(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor)),
            ),
            Spacer(),
          ]);
        }
        return Stack(children: [
          GoogleMap(
              mapType: MapType.normal,
              myLocationEnabled: true,
              markers: _markers,
              circles: Conf.displayAreaCircle ? _circles : null,
              initialCameraPosition: CameraPosition(
                zoom: 18,
                target: Conf.testMode
                    ? Store.parisPosition
                    : LocationCache().location,
              ),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                _fetchUsersAroundMe();
              }),
        ]);
      },
    );
  }
}
