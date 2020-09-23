import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:location_project/widgets/bottomSheet.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'dart:async';
import '../interactors/areaFetcher.dart';
import '../stores/store.dart';

class Map extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MapState();
}

class MapState extends State<Map> {
  Set<Marker> _markers = {};

  final Completer<GoogleMapController> _controller = Completer();
  final AreaFetcher _areaFetcher = AreaFetcher();

  @override
  void initState() {
    super.initState();
    _fetchUsersAroundMe();
  }

  void _fetchUsersAroundMe() {
    _areaFetcher.fetch((user) {
      setState(() {
        _markers.add(Marker(
            markerId: MarkerId(user.email),
            icon: user.icon,
            position: user.coord,
            onTap: () {
              showFloatingModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Column(children: [
                      ListTile(
                        leading: Icon(Icons.ac_unit),
                        title: Text('my list'),
                      )
                    ]);
                  });
            }));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    CameraPosition initialLocation =
        CameraPosition(zoom: 16, bearing: 30, target: Store.parisPosition);

    return GoogleMap(
        myLocationEnabled: true,
        markers: _markers,
        initialCameraPosition: initialLocation,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        });
  }
}
