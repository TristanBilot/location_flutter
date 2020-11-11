part of 'chat_cubit.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object> get props => [];
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatLoaded extends ChatState {
  final List<Chat> chats;
  const ChatLoaded(this.chats);

  @override
  List<Object> get props => [chats];
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);

  @override
  List<Object> get props => [message];
}
