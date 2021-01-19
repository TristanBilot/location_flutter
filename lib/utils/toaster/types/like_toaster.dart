import 'package:flutter/material.dart';
import 'package:location_project/controllers/navigation_controller.dart';
import 'package:location_project/repositories/user_repository.dart';
import 'package:location_project/utils/toaster/toaster_widget.dart';

class LikeToaster extends Toaster {
  final BuildContext context;
  final String fromID;

  LikeToaster(this.context, this.fromID);

  Future show() async {
    final user = await UserRepository().fetchUser(fromID, withInfos: true);

    _onToastTap() {
      NavigationController().navigateToPremiumLikePage();
    }

    final body = '${user.firstName} has liked your profile.';
    ToasterWidget(context, body, user, _onToastTap).show();
  }
}
