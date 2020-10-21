import 'package:location_project/models/user.dart';
import 'package:location_project/use_cases/account/account_language_page.dart';
import 'package:location_project/use_cases/messaging/firestore_chat_entry.dart';
import 'package:location_project/use_cases/messaging/firestore_message_entry.dart';
import 'package:location_project/use_cases/start_path/widgets/gender_circle_icon.dart';

extension GenderExtension on Gender {
  String get value {
    return this.toString().substring(this.toString().indexOf('.') + 1);
  }
}

extension UserFireStoreKeyExtension on UserField {
  String get value {
    return this.toString().substring(this.toString().indexOf('.') + 1);
  }
}

extension LanguageExtension on Language {
  String get value {
    return this.toString().substring(this.toString().indexOf('.') + 1);
  }
}

extension ChatFieldExtension on ChatField {
  String get value {
    return this.toString().substring(this.toString().indexOf('.') + 1);
  }
}

extension MessageFieldExtension on MessageField {
  String get value {
    return this.toString().substring(this.toString().indexOf('.') + 1);
  }
}
