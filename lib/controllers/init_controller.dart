import 'dart:io';

import 'package:location_project/controllers/device_id_controller.dart';
import 'package:location_project/controllers/location_controller.dart';
import 'package:location_project/repositories/user_local_repository.dart';
import 'package:location_project/stores/database.dart';
import 'package:location_project/stores/messaging_database.dart';
import 'package:location_project/stores/user_store.dart';
import 'package:hive/hive.dart';
import 'package:location_project/models/gender.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/models/user_settings.dart';
import 'package:path_provider/path_provider.dart';

class InitController {
  Future initFromMain() async {
    await UserLocalRepository.initAsynchronously();
    await DeviceIDController().storeDeviceID();
    await _initHiveDatabases();
    // UserLocalRepository().forgetLoggedUser();
    // return;
    if (UserLocalRepository().isUserLoggedIn()) {
      await LocationController().handleLocationIfNeeded();
      if (await LocationController().isLocationEnabled())
        await UserStore().initAsynchronously();
    }
    initAtFirstAppLaunch();
  }

  Future initAfterLogin(String loggedID) async {
    await _openHiveDatabases();
    await LocationController().handleLocationIfNeeded();
    await UserLocalRepository().rememberLoggedUser(loggedID);
    await DeviceIDController().updateDeviceID();
    await UserStore().initAsynchronously();
  }

  Future initAfterStartPath(String newUserID) async {
    await UserLocalRepository().rememberLoggedUser(newUserID);
    await UserStore().initAsynchronously();
  }

  Future initAtFirstAppLaunch() async {
    if (UserLocalRepository().getIsFirstAppLaunch()) {
      DeviceIDController().removeDuplicateExistingDeviceID();
    }
    UserLocalRepository().setIsFirstAppLaunch(false);
  }

  Future _initHiveDatabases() async {
    Directory dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    Hive.registerAdapter(GenderAdapter());
    Hive.registerAdapter(UserSettingsAdapter());
    Hive.registerAdapter(UserAdapter());

    await _openHiveDatabases();
  }

  Future _openHiveDatabases() async {
    await Database.initHiveDatabase();
    await MessagingDatabase.initHiveDatabase();
  }
}
