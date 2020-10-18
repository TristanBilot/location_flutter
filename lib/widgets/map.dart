import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:location_project/caches/location_cache.dart';
import 'package:location_project/helpers/location_controller.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/repositories/area_fetching_repository.dart';
import 'package:location_project/stores/map_store.dart';
import 'package:location_project/widgets/user_card.dart';

import '../stores/conf.dart';
import '../stores/store.dart';
import 'user_marker.dart';

class Map extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MapState();
}

class MapState extends State<Map> with WidgetsBindingObserver {
  Set<UserMarker> _markers;
  Set<Circle> _circles;
  MapStore _store;

  Completer<GoogleMapController> _controller;
  AreaFetchingRepository _areaFetcher;

  final barrierColorBaseShade = 150;
  Color barrierColor;
  bool isModalDisplayed;

  MapState() {
    _markers = {};
    _controller = Completer();
    _areaFetcher = AreaFetchingRepository();
    _store = MapStore();
  }

  String _darkMapStyle;
  String _lightMapStyle;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    LocationController().handleLocationIfNeeded();

    _loadMapStyles().then((_) => _setMapStyle());
    // _fetchUsersAroundMe();

    isModalDisplayed = false;
    _restBarrierColor();
    // _drawCircleArea();
  }

  void _restBarrierColor() {
    barrierColor = Color.fromARGB(barrierColorBaseShade, 0, 0, 0);
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

  /*
  * mandatory to use in _fetchUsersAroundMe() to avoid retaining.
  */
  void setStateIfMounted(Function f) {
    if (mounted) setState(f);
  }

  Future _fetchUsersAroundMe() async {
    // in the case when the user enable location from settings
    // we need to handle location again
    _areaFetcher.fetch((users) {
      setStateIfMounted(() {
        _markers.clear();
        // may be faster but need 2 times checkinf for unliked
        // users in the code, here for first load and in the build()
        // if (!_store.isUserUnliked(user.id)) {
        users.forEach((user) {
          _markers.add(UserMarker(
              user: user,
              icon: user.icon,
              position: user.coord,
              onTap: () {
                setState(() {
                  isModalDisplayed = true;
                  _restBarrierColor();
                  _showUserCard(context, user, this, _store);
                });
              }));
        });
        // }
      });
    });
  }

  void _showUserCard(
      BuildContext context, User user, MapState state, MapStore store) {
    showGeneralDialog(
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
              opacity: a1.value,
              child: UserCard(store, state, user),
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 200),
        barrierColor:
            Colors.white.withAlpha(0), // Colors.black.withOpacity(0.5)
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {});
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
    return Future.delayed(Duration(milliseconds: 500), () => true);
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
              markers: _markers
                ..removeWhere((m) => _store.isUserUnliked(m.user.id)),
              circles: Conf.displayAreaCircle ? _circles : null,
              initialCameraPosition: CameraPosition(
                zoom: 18,
                target: Conf.testMode
                    ? Store.parisPosition
                    : LocationCache.location,
              ),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                _fetchUsersAroundMe();
              }),
          // barrier background dark container used when user card displayed
          isModalDisplayed
              ? Container(
                  color: barrierColor,
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: GestureDetector(onTap: () {
                    setState(() {
                      isModalDisplayed = false;
                      barrierColor = Colors.red;
                    });
                    Navigator.of(context, rootNavigator: true).pop(true);
                  }),
                )
              : Container()
        ]);
      },
    );
  }
}
