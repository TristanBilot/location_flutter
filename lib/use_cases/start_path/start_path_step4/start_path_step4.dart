import 'dart:collection';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:location_project/stores/routes.dart';
import 'package:location_project/use_cases/start_path/start_path_step1/start_path_step1.dart';
import 'package:location_project/use_cases/start_path/start_path_step3/start_path_step3.dart';
import 'package:location_project/use_cases/start_path/widgets/basic_button.dart';
import 'package:location_project/widgets/textSF.dart';

class StartPathStep4 extends StatefulWidget {
  @override
  StartPathStep4State createState() => StartPathStep4State();
}

class StartPathStep4State extends State<StartPathStep4> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
          padding: EdgeInsets.all(StartPathStep1.allPadding),
          child: Column(
            children: [
              Spacer(),
              Container(
                width: MediaQuery.of(context).size.width,
                height: StartPathStep3.flareAnimationSize,
                child: FlareActor("assets/notif.flr",
                    alignment: Alignment.center,
                    fit: BoxFit.contain,
                    animation: "animation"),
              ),
              Spacer(),
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text: 'Know when ',
                    style: TextSF.TextSFTitleStyle.copyWith(
                        color: Theme.of(context).textTheme.bodyText2.color),
                  ),
                  TextSpan(
                    text: 'someone send you a message',
                    style: TextSF.TextSFTitleStyle.copyWith(
                        color: Theme.of(context).primaryColor),
                  ),
                  TextSpan(
                      text: ', we\'ll notify you 🔔',
                      style: TextSF.TextSFTitleStyle.copyWith(
                          color: Theme.of(context).textTheme.bodyText2.color))
                ]),
              ),
              Spacer(),
              BasicButton('ALLOW NOTIFICATIONS',
                  enabled: true,
                  onPressed: () => Navigator.of(context)
                      .pushNamed(Routes.startPathStep3.value)),
              Spacer(),
            ],
          )),
    );
  }
}
