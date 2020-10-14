import 'package:flutter/material.dart';
import 'package:location_project/helpers/location_controller.dart';
import 'package:location_project/pages/map_page.dart';
import 'package:location_project/use_cases/start_path/widgets/basic_button.dart';
import 'package:location_project/widgets/textSF.dart';

class LocationDisabledPage extends StatefulWidget {
  final MapPageState mapPageState;

  LocationDisabledPage(this.mapPageState, {Key key}) : super(key: key);

  @override
  _LocationDisabledPageState createState() => _LocationDisabledPageState();
}

class _LocationDisabledPageState extends State<LocationDisabledPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      widget.mapPageState.setState(() {});
      print('heyyy');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            Spacer(),
            Text(
              'No location, no matches ☹️',
              textAlign: TextAlign.center,
              style: TextSF.TextSFStyle.copyWith(
                  fontSize: 22, fontWeight: FontWeight.w700),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Text(
                'Enable it to start find people around you!',
                textAlign: TextAlign.center,
                style: TextSF.TextSFStyle.copyWith(
                  fontSize: 22,
                ),
              ),
            ),
            Spacer(),
            Spacer(),
            BasicButton('ENABLE LOCATION',
                onPressed: () =>
                    LocationController.instance.openLocationSettings()),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
