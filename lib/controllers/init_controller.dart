import 'package:location_project/controllers/device_id_controller.dart';
import 'package:location_project/controllers/location_controller.dart';
import 'package:location_project/repositories/image_repository.dart';
import 'package:location_project/storage/shared preferences/local_store.dart';
import 'package:location_project/storage/databases/messaging_database.dart';
import 'package:location_project/storage/distant/user_store.dart';
import 'package:location_project/models/user.dart';

class InitController {
  Future initFromMain() async {
    await LocalStore.initAsynchronously();
    await DeviceIDController().storeDeviceID();
    // await AuthRepository().logOut();
    // LocalStore().forgetLoggedUser();
    // return;
    if (LocalStore().isUserLoggedIn()) {
      await LocationController().handleLocationIfNeeded();
      if (await LocationController().isLocationEnabled()) {
        await UserStore().initAsynchronously();
      }
      await _initDatabases();
      await _initNotFoundImageURL();
    }
    _initAtFirstAppLaunch();
  }

  Future initAfterLogin(String loggedID) async {
    await LocationController().handleLocationIfNeeded();
    await LocalStore().rememberLoggedUser(loggedID);
    await DeviceIDController().updateDeviceID();
    await UserStore().initAsynchronously();
  }

  Future initAfterStartPath(User newUser) async {
    await LocalStore().rememberLoggedUser(newUser.id);
    await UserStore().initAsynchronously(fromUser: newUser);
  }

  Future _initAtFirstAppLaunch() async {
    if (LocalStore().getIsFirstAppLaunch()) {
      DeviceIDController().removeDuplicateExistingDeviceID();
    }
    LocalStore().setIsFirstAppLaunch(false);
  }

  Future _initDatabases() async {
    await MessagingDatabase.initAsynchronously();
  }

  Future _initNotFoundImageURL() async {
    if (LocalStore().getNotFoundImagePictureURL() == null) {
      final url = (await ImageRepository().fetchNotFoundImageURL()) as String;
      await LocalStore().setNotFoundImagePictureURL(url);
    }
  }
}
