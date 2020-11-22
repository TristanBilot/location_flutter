import 'package:location_project/repositories/user_local_repository.dart';
import 'package:location_project/repositories/user_repository.dart';
import 'package:location_project/use_cases/tab_pages/messaging/notifications/device_id_fetcher.dart';

class DeviceIDController {
  Future storeDeviceID() async {
    if (UserLocalRepository().getCurrentDeviceID() != null) return;
    final deviceID = await DeviceIDFetcher().fetchDeviceToken();
    UserLocalRepository().setCurrentDeviceID(deviceID);
  }

  Future updateDeviceID() async {
    final id = UserLocalRepository().getLoggedUserID();
    final deviceID = await DeviceIDFetcher().fetchDeviceToken();
    UserLocalRepository().setCurrentDeviceID(deviceID);
    UserRepository().addDeviceID(id, deviceID);
  }

  Future forgetDeviceID() async {
    final id = UserLocalRepository().getLoggedUserID();
    final deviceID = UserLocalRepository().getCurrentDeviceID();
    UserRepository().removeDeviceID(id, deviceID);
  }

  Future removeDuplicateExistingDeviceID() async {
    final deviceID = UserLocalRepository().getCurrentDeviceID();
    UserRepository().removeDuplicateExistingDeviceID(deviceID);
  }
}
