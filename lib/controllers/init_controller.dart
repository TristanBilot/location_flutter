import 'package:location_project/controllers/location_controller.dart';
import 'package:location_project/repositories/user_local_repository.dart';
import 'package:location_project/stores/database.dart';
import 'package:location_project/stores/user_store.dart';

class InitController {
  Future initFromMain() async {
    await UserLocalRepository.initAsynchronously();
    // UserLocalRepository().forgetLoggedUser();
    // return;
    if (UserLocalRepository().isUserLoggedIn()) {
      await LocationController().handleLocationIfNeeded();
      if (await LocationController().isLocationEnabled())
        await UserStore().initAsynchronously();
    }
    await Database.initHiveDatabase();
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
