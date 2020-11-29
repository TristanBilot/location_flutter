import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:location_project/conf/conf.dart';
import 'package:location_project/conf/store.dart';
import 'package:location_project/controllers/location_controller.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/use_cases/blocking/cubit/blocking_cubit.dart';
import 'package:location_project/use_cases/map/cubit/area_cubit.dart';
import 'package:location_project/use_cases/map/repositories/area_fetching_repository.dart';
import 'package:location_project/repositories/user_repository.dart';
import 'package:location_project/storage/distant/user_store.dart';
import 'package:location_project/storage/memory/location_cache.dart';
import 'package:location_project/widgets/user_map_card.dart';

import '../../widgets/user_marker.dart';

class Map extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MapState();
}

class MapState extends State<Map> with WidgetsBindingObserver {
  Set<UserMarker> _markers;
  Set<Circle> _circles;
  List<User> _users;

  Completer<GoogleMapController> _controller;

  MapState() {
    _markers = {};
    _controller = Completer();
    _users = List();
  }

  String _darkMapStyle;
  String _lightMapStyle;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    LocationController().handleLocationIfNeeded();

    _loadMapStyles().then((_) => _setMapStyle());
  }

  _updateUserMarkers() {
    context.read<AreaCubit>().fetchArea((users) {
      setStateIfMounted(() {
        _markers.clear();
        users.forEach((user) {
          if (!UserStore().user.userIDsWhoBlockedMe.contains(user.id))
            _markers.add(UserMarker(
                user: user,
                icon: user.icon,
                position: LatLng(user.coord[0], user.coord[1]),
                onTap: () => _onMarkerTap(context, user)));
        });
      });
    });
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

  _onMarkerTap(BuildContext context, User user) {
    UserMapCard(context, user).show();
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
    return Future.delayed(Duration(milliseconds: 300), () => true);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _waitForBuildMap(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return BlocListener<AreaCubit, AreaState>(
              listener: (context, state) {
                if (state is AreaFetchedState) {
                  _users = state.users;
                  _updateUserMarkers();
                }
              },
              child: GoogleMap(
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
                    _updateUserMarkers();
                  }),
            );
          }
          return Text('null');
        });

    // BlocListener<BlockingCubit, BlockingState>(
    //     listener: (context, state) {
    //   _updateUserMarkers(_users);
    // }),
  }
}
