import 'dart:io';

import 'package:location_project/controllers/device_id_controller.dart';
import 'package:location_project/controllers/location_controller.dart';
import 'package:location_project/repositories/auth_repository.dart';
import 'package:location_project/repositories/user_mock_repository.dart';
import 'package:location_project/storage/shared preferences/local_store.dart';
import 'package:location_project/storage/databases/user_database.dart';
import 'package:location_project/storage/databases/messaging_database.dart';
import 'package:location_project/storage/distant/user_store.dart';
import 'package:hive/hive.dart';
import 'package:location_project/models/gender.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/models/user_settings.dart';
import 'package:location_project/use_cases/tab_pages/messaging/messaging_mock_repository.dart';
import 'package:path_provider/path_provider.dart';

class InitController {
  Future initFromMain() async {
    await LocalStore.initAsynchronously();
    await DeviceIDController().storeDeviceID();
    await _initHiveDatabases();
    // await AuthRepository().logOut();
    // LocalStore().forgetLoggedUser();
    // return;
    if (LocalStore().isUserLoggedIn()) {
      await LocationController().handleLocationIfNeeded();
      if (await LocationController().isLocationEnabled())
        await UserStore().initAsynchronously();
    }
    initAtFirstAppLaunch();
    // MessagingMockRepository().insertChatMock();
  }

  Future initAfterLogin(String loggedID) async {
    await _openHiveDatabases();
    await LocationController().handleLocationIfNeeded();
    await LocalStore().rememberLoggedUser(loggedID);
    await DeviceIDController().updateDeviceID();
    await UserStore().initAsynchronously();
  }

  Future initAfterStartPath(User newUser) async {
    await LocalStore().rememberLoggedUser(newUser.id);
    await UserStore().initAsynchronously(fromUser: newUser);
  }

  Future initAtFirstAppLaunch() async {
    if (LocalStore().getIsFirstAppLaunch()) {
      DeviceIDController().removeDuplicateExistingDeviceID();
    }
    LocalStore().setIsFirstAppLaunch(false);
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
    await UserDatabase.initHiveDatabase();
    await MessagingDatabase.initHiveDatabase();
  }
}
