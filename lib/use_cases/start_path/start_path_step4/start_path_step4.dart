import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:location_project/account_creation_controller.dart';
import 'package:location_project/helpers/location_controller.dart';
import 'package:location_project/helpers/notification_controller.dart';
import 'package:location_project/init_controller.dart';
import 'package:location_project/repositories/user_repository.dart';
import 'package:location_project/stores/routes.dart';
import 'package:location_project/stores/start_path_store.dart';
import 'package:location_project/use_cases/start_path/basic_alert.dart';
import 'package:location_project/use_cases/start_path/basic_alert_button.dart';
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
    final user = StartPathStore().user;
    _acountCreationController.createUser(user);
    await InitController().initAfterStartPath(user.id);
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
                  onPressed: () => _requestNotifications()),
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
