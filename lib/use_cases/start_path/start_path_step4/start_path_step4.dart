import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:location_project/controllers/account_creation_controller.dart';
import 'package:location_project/controllers/init_controller.dart';
import 'package:location_project/controllers/location_controller.dart';
import 'package:location_project/controllers/notification_controller.dart';
import 'package:location_project/conf/routes.dart';
import 'package:location_project/storage/memory/start_path_store.dart';
import 'package:location_project/use_cases/start_path/start_path_step1/start_path_step1.dart';
import 'package:location_project/use_cases/start_path/start_path_step3/start_path_step3.dart';
import 'package:location_project/use_cases/start_path/widgets/basic_button.dart';
import 'package:location_project/use_cases/start_path/widgets/breadcrumb.dart';
import 'package:location_project/use_cases/start_path/widgets/secondary_button.dart';
import 'package:location_project/widgets/textSF.dart';

class StartPathStep4 extends StatefulWidget {
  @override
  StartPathStep4State createState() => StartPathStep4State();
}

class StartPathStep4State extends State<StartPathStep4> {
  AcountCreationController _acountCreationController;

  @override
  void initState() {
    super.initState();
    _acountCreationController = AcountCreationController();
  }

  Future _createUser() async {
    if (!StartPathStore().ignoreUserCreation) {
      await StartPathStore().uploadPictures();
      await _acountCreationController.createUser(StartPathStore().user);
    }
    InitController().initAfterStartPath(StartPathStore().user);
  }

  Future _requestNotifications() async {
    NotificationController.instance.enableNotifications().then((_) async {
      print(NotificationController.instance.permissionStatus);
      print(LocationController().permissionStatus);
      await _createUser();
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.of(context).pushReplacementNamed(Routes.map.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
          padding: EdgeInsets.all(StartPathStep1.allPadding),
          child: Column(
            children: [
              Breadcrumb(4),
              Spacer(),
              Container(
                width: MediaQuery.of(context).size.width,
                height: StartPathStep3.flareAnimationSize,
                child: FlareActor("assets/animations/notif.flr",
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
              BasicButton(
                'ALLOW NOTIFICATIONS',
                onPressed: () => _requestNotifications(),
                width: MediaQuery.of(context).size.width,
              ),
              SecondaryButton('LATER', () {
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.of(context).pushReplacementNamed(Routes.map.value);
              }),
              Spacer(),
            ],
          )),
    );
  }
}
