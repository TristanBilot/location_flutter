import 'package:location_project/use_cases/messaging/pages/builders/tab_page_chat_request_stream_builder.dart';
import 'package:location_project/use_cases/messaging/pages/tab_page_template.dart';
import 'package:location_project/use_cases/messaging/pages/tab_page_type.dart';
import 'package:location_project/use_cases/messaging/pages/data/tab_page_stream_builder_chat_data.dart';
import 'package:location_project/use_cases/messaging/pages/data/tab_page_stream_builder_request_data.dart';

class TabPageFactory {
  /// Setup a chat page adapted for different tabs.
  /// Discussions is for chatting, requests for the received
  /// requests to chat and views, the users which viewed
  /// the user's profile.
  TabPageTemplate makeDiscussionsPage() {
    final data = TabPageStreamBuilderChatData();
    final builder = TabPageChatRequestStreamBuilder(data);
    final type = TabPageType.Chats;

    return TabPageTemplate(builder, type);
  }

  TabPageTemplate makeRequestsPage() {
    final data = TabPageStreamBuilderRequestData();
    final builder = TabPageChatRequestStreamBuilder(data);
    final type = TabPageType.Requests;

    return TabPageTemplate(builder, type);
  }

  TabPageTemplate makeViewsPage() {
    final data = TabPageStreamBuilderRequestData();
    final builder = TabPageChatRequestStreamBuilder(data);
    final type = TabPageType.Requests;

    return TabPageTemplate(builder, type);
  }
}
