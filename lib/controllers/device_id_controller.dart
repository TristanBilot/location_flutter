import 'package:location_project/repositories/user_local_repository.dart';
import 'package:location_project/repositories/user_repository.dart';
import 'package:location_project/use_cases/tab_pages/messaging/notifications/notif_handler.dart';

class DeviceIDController {
  Future updateDeviceID() async {
    final id = UserLocalRepository().getLoggedUserID();
    final deviceID = await NotifHandler().fetchDeviceToken();
    UserLocalRepository().setCurrentDeviceID(deviceID);
    UserRepository().addDeviceID(id, deviceID);
  }

  Future forgetDeviceID() async {
    final id = UserLocalRepository().getLoggedUserID();
    final deviceID = UserLocalRepository().getCurrentDeviceID();
    UserRepository().removeDeviceID(id, deviceID);
  }
}
