import 'package:location_project/use_cases/messaging/firestore_chat_entry.dart';
import 'package:location_project/use_cases/messaging/pages/chats_page_template.dart';
import '../../../stores/extensions.dart';

class ChatsPageFactory {
  ChatsPageTemplate makeChatsPage() {
    List<dynamic> filter(List<dynamic> snapshots) => snapshots
        .where((chat) =>
            chat.data()[ChatField.IsChatEngaged.value] as bool == true)
        .toList();
    return ChatsPageTemplate(filter);
  }

  ChatsPageTemplate makeRequestsPage() {
    List<dynamic> filter(List<dynamic> snapshots) => snapshots
        .where((chat) =>
            chat.data()[ChatField.IsChatEngaged.value] as bool == false)
        .toList();
    return ChatsPageTemplate(filter);
  }
}
