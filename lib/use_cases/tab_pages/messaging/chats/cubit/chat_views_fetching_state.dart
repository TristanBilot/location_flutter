import 'package:location_project/use_cases/tab_pages/messaging/chats/cubit/chat_cubit.dart';

class ChatViewsFetchingState extends ChatState {
  @override
  List<Object> get props => [];
}

class ChatViewsFetchedState extends ChatState {
  final List<String> viewerIDs;

  ChatViewsFetchedState(this.viewerIDs);

  @override
  List<Object> get props => [viewerIDs];
}
