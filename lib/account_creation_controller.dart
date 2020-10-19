import 'package:location_project/models/user.dart';
import 'package:location_project/repositories/user_repository.dart';

class AcountCreationController {
  UserRepository _userRepo;

  AcountCreationController() {
    _userRepo = UserRepository();
  }
  Future createUser(User user) async {
    await _userRepo.insertUserForFirstConnection(user);
    print('${user.id} successfuly created.');
  }
}
