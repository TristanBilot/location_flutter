import 'package:location_project/use_cases/tab_pages/messaging/models/chat.dart';

abstract class ChatFilter {
  List<Chat> filter(List<Chat> chats, String pattern);
}
