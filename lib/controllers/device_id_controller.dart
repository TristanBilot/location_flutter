import 'package:location_project/storage/shared preferences/local_store.dart';
import 'package:location_project/repositories/user_repository.dart';
import 'package:location_project/use_cases/tab_pages/messaging/notifications/device_id_fetcher.dart';

class DeviceIDController {
  Future storeDeviceID() async {
    if (LocalStore().getCurrentDeviceID() != null) return;
    final deviceID = await DeviceIDFetcher().fetchDeviceToken();
    LocalStore().setCurrentDeviceID(deviceID);
  }

  Future updateDeviceID() async {
    final id = LocalStore().getLoggedUserID();
    final deviceID = await DeviceIDFetcher().fetchDeviceToken();
    LocalStore().setCurrentDeviceID(deviceID);
    UserRepository().addDeviceID(id, deviceID);
  }

  Future forgetDeviceID() async {
    final id = LocalStore().getLoggedUserID();
    final deviceID = LocalStore().getCurrentDeviceID();
    UserRepository().removeDeviceID(id, deviceID);
  }

  @deprecated
  Future removeDuplicateExistingDeviceID() async {
    final deviceID = LocalStore().getCurrentDeviceID();
    UserRepository().removeDuplicateExistingDeviceID(deviceID);
  }
}
