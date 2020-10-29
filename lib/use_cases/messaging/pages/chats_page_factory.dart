import 'package:location_project/stores/user_store.dart';
import 'package:location_project/use_cases/messaging/firestore_chat_entry.dart';
import 'package:location_project/use_cases/messaging/pages/chats_page_template.dart';
import 'package:location_project/use_cases/messaging/pages/chats_page_type.dart';
import '../../../stores/extensions.dart';

class ChatsPageFactory {
  /// Setup a chat page adapted for deifferent tabs.
  /// Discussions is for chatting, requests for the received
  /// requests to chat and views, the users which viewed
  /// the user's profile.
  ChatsPageTemplate makeDiscussionsPage() {
    List<dynamic> filter(List<dynamic> snapshots) => snapshots
        .where((chat) =>
            chat.data()[ChatField.IsChatEngaged.value] as bool == true)
        .toList();
    return ChatsPageTemplate(filter, ChatsPageType.Discussions);
  }

  /// Sort the requests with first the requests where the user is requested
  /// and then where the user has requests.
  ChatsPageTemplate makeRequestsPage() {
    List<dynamic> filter(List<dynamic> snapshots) => snapshots
        .where((chat) =>
            chat.data()[ChatField.IsChatEngaged.value] as bool == false)
        .toList()
          ..sort((a, b) {
            bool isUserRequested =
                (b.data()[ChatField.RequestedID.value] as String) ==
                    UserStore().user.id;
            return isUserRequested ? 1 : -1;
          });
    return ChatsPageTemplate(filter, ChatsPageType.Requests);
  }

  // TODO
  ChatsPageTemplate makeViewsPage() {
    List<dynamic> filter(List<dynamic> snapshots) => snapshots;
    return ChatsPageTemplate(filter, ChatsPageType.Views);
  }
}
