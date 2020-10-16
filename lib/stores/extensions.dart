import 'package:location_project/repositories/user_repository.dart';
import 'package:location_project/use_cases/start_path/widgets/gender_circle_icon.dart';

extension GenderExtension on Gender {
  String get value {
    return this.toString().substring(this.toString().indexOf('.') + 1);
  }
}

extension UserFireStoreKeyExtension on UserFireStoreKey {
  String get value {
    return this.toString().substring(this.toString().indexOf('.') + 1);
  }
}
