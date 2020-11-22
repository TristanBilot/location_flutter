import 'package:location_project/models/user.dart';
import 'package:location_project/use_cases/account/account_language_page.dart';
import 'package:location_project/models/gender.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/chat.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/message.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/reaction.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/view.dart';
import 'package:location_project/use_cases/tab_pages/messaging/notifications/notif.dart';
import 'package:location_project/use_cases/tab_pages/tab_page_type.dart';

extension GenderExtension on Gender {
  String get value =>
      this.toString().substring(this.toString().indexOf('.') + 1);
}

extension UserFireStoreKeyExtension on UserField {
  String get value =>
      this.toString().substring(this.toString().indexOf('.') + 1);
}

extension LanguageExtension on Language {
  String get value =>
      this.toString().substring(this.toString().indexOf('.') + 1);
}

extension ChatFieldExtension on ChatField {
  String get value =>
      this.toString().substring(this.toString().indexOf('.') + 1);
}

extension MessageFieldExtension on MessageField {
  String get value =>
      this.toString().substring(this.toString().indexOf('.') + 1);
}

extension ChatsPageTypeExtension on TabPageType {
  String get value =>
      this.toString().substring(this.toString().indexOf('.') + 1);
}

extension ViewFieldExtension on ViewField {
  String get value =>
      this.toString().substring(this.toString().indexOf('.') + 1);
}

extension ReactionExtension2 on Reaction {
  String get value =>
      this.toString().substring(this.toString().indexOf('.') + 1);
}

extension NotifFieldExtension on NotifField {
  String get value =>
      this.toString().substring(this.toString().indexOf('.') + 1);
}

extension NotifTypeExtension2 on NotifType {
  String get value =>
      this.toString().substring(this.toString().indexOf('.') + 1);
}
