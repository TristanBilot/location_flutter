import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:location_project/controllers/location_controller.dart';
import 'package:location_project/stores/routes.dart';
import 'package:location_project/use_cases/start_path/basic_alert_button.dart';
import 'package:location_project/use_cases/start_path/basic_alert.dart';
import 'package:location_project/use_cases/start_path/start_path_step1/start_path_step1.dart';
import 'package:location_project/use_cases/start_path/widgets/basic_button.dart';
import 'package:location_project/use_cases/start_path/widgets/breadcrumb.dart';
import 'package:location_project/use_cases/start_path/widgets/secondary_button.dart';
import 'package:location_project/widgets/textSF.dart';

class StartPathStep3 extends StatefulWidget {
  static final flareAnimationSize = 250.0;
  @override
  StartPathStep3State createState() => StartPathStep3State();
}

class StartPathStep3State extends State<StartPathStep3> {
  @override
  void initState() {
    super.initState();
  }

  Future _requestLocation() async {
    LocationController().enableLocation().then((_) async {
      LocationController().handleLocationIfNeeded();
      Navigator.of(context).pushNamed(Routes.startPathStep4.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
          padding: EdgeInsets.all(StartPathStep1.allPadding),
          child: Column(
            children: [
              Breadcrumb(3),
              Spacer(),
              Container(
                width: StartPathStep3.flareAnimationSize,
                height: StartPathStep3.flareAnimationSize,
                child: FlareActor("assets/earth.flr",
                    alignment: Alignment.center,
                    fit: BoxFit.contain,
                    animation: "animation"),
              ),
              Spacer(),
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text: 'We need to know your ',
                    style: TextSF.TextSFTitleStyle.copyWith(
                        color: Theme.of(context).textTheme.bodyText2.color),
                  ),
                  TextSpan(
                    text: 'location',
                    style: TextSF.TextSFTitleStyle.copyWith(
                        color: Theme.of(context).primaryColor),
                  ),
                  TextSpan(
                    text: ' to find people ',
                    style: TextSF.TextSFTitleStyle.copyWith(
                        color: Theme.of(context).textTheme.bodyText2.color),
                  ),
                  TextSpan(
                      text: 'around you',
                      style: TextSF.TextSFTitleStyle.copyWith(
                          color: Theme.of(context).primaryColor)),
                  TextSpan(
                    text: ' !',
                    style: TextSF.TextSFTitleStyle.copyWith(
                        color: Theme.of(context).textTheme.bodyText2.color),
                  ),
                ]),
              ),
              Spacer(),
              BasicButton('ENABLE LOCATION',
                  enabled: true, onPressed: () => _requestLocation()),
              SecondaryButton(
                  'LATER',
                  () => showDialog(
                        context: context,
                        builder: (context) => BasicAlert(
                            "Are you sure? ☹️",
                            "Without your location, you will not be allowed to use the app!",
                            [
                              BasicAlertButton(
                                  'LATER',
                                  () => Navigator.of(context)
                                      .pushNamed(Routes.startPathStep4.value)),
                              BasicAlertButton(
                                  'ENABLE', () => _requestLocation()),
                            ]),
                      )),
              Spacer(),
            ],
          )),
    );
  }
}
