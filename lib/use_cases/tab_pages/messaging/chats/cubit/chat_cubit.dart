import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:location_project/stores/database.dart';
import 'package:location_project/stores/user_store.dart';
import 'package:location_project/use_cases/tab_pages/messaging/chats/cubit/chat_deleting_state.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/chat.dart';
import 'package:location_project/use_cases/tab_pages/messaging/messaging_repository.dart';

part 'chat_fetching_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final MessagingReposiory _msgRepository;

  ChatCubit(this._msgRepository) : super(ChatInitialState());

  Future<void> fetchChats() async {
    try {
      emit(ChatFetchingState());
      final id = UserStore().user.id;
      _msgRepository.getChats(id).listen((chats) {
        emit(ChatFetchedState(chats));
      });
    } on Exception {
      emit(ChatError("Couldn't fetch chats. Is the device online?"));
    }
  }

  Future<void> deleteChat(Chat chat) async {
    try {
      emit(ChatDeletingState());
      _msgRepository.deleteMessages(chat.chatID);
      _msgRepository.deleteChat(chat.chatID);
      await Database().deleteUser(chat.requesterID);
      emit(ChatDeletedState());
    } on Exception {
      emit(ChatError("Couldn't delete chats. Is the device online?"));
    }
  }
}
