import 'package:flutter/material.dart';
import 'package:location_project/caches/location_cache.dart';
import 'package:location_project/caches/user_cache.dart';
import 'package:location_project/controllers/location_controller.dart';
import 'package:location_project/pages/location_disabled_page.dart';
import 'package:location_project/widgets/map.dart';

class MapPage extends StatefulWidget {
  MapPage({Key key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  void initState() {
    _init();
    super.initState();
  }

  void _init() {
    UserCache().setDisplayToastValues(true, true, true, true, '');
  }

  Future<bool> _displayMapIfLocationEnabled() async {
    await LocationController().handleLocationIfNeeded();
    return LocationCache().isLocationAvailable &&
        await LocationController().isLocationEnabled();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _displayMapIfLocationEnabled(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          bool shouldDisplayMap = snapshot.data;
          return shouldDisplayMap ? Map() : LocationDisabledPage();
        } else {
          return CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          );
        }
      },
    );
  }
}
