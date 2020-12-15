import 'package:flutter/material.dart';
import 'package:location_project/repositories/user_repository.dart';
import 'package:location_project/utils/toaster/toaster_widget.dart';

class ViewToaster extends Toaster {
  final BuildContext context;
  final String fromID;

  ViewToaster(this.context, this.fromID);

  Future show() async {
    final user = await UserRepository().fetchUser(fromID, withInfos: true);

    // _onToastTap() {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(builder: (context) => TabPageViewsPage()),
    //   );
    // }

    _onToastTap() => {};

    final body = '${user.firstName} has viewed your profile.';
    ToasterWidget(context, body, user, _onToastTap).show();
  }
}
