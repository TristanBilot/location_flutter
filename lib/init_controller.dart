import 'package:location_project/repositories/user_local_repository.dart';
import 'package:location_project/stores/user_store.dart';
import 'helpers/location_controller.dart';

class InitController {
  Future initFromMain() async {
    await UserLocalRepository.initAsynchronously();
    // UserLocalRepository().forgetLoggedUser();
    // return;
    if (UserLocalRepository().isUserLoggedIn()) {
      await LocationController().handleLocationIfNeeded();
      await UserStore().initAsynchronously();
    }
  }

  Future initAfterLogin(String loggedID) async {
    await LocationController().handleLocationIfNeeded();
    await UserLocalRepository().rememberLoggedUser(loggedID);
    await UserStore().initAsynchronously();
  }

  Future initAfterStartPath(String newUserID) async {
    await UserLocalRepository().rememberLoggedUser(newUserID);
    await UserStore().initAsynchronously();
  }
}
