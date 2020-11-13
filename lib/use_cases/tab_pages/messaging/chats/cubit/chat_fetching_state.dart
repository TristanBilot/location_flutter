part of 'chat_cubit.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object> get props => [];
}

class ChatInitialState extends ChatState {
  const ChatInitialState();
  @override
  List<Object> get props => [];
}

class ChatFetchingState extends ChatState {
  const ChatFetchingState();
  @override
  List<Object> get props => [];
}

class ChatFetchedState extends ChatState {
  final List<Chat> chats;
  const ChatFetchedState(this.chats);

  @override
  List<Object> get props => [chats];
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);

  @override
  List<Object> get props => [message];
}
