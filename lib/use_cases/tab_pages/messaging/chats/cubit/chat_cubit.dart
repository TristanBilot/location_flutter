import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:location_project/stores/user_store.dart';
import 'package:location_project/use_cases/tab_pages/messaging/firestore_chat_entry.dart';
import 'package:location_project/use_cases/tab_pages/messaging/messaging_repository.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final MessagingReposiory _repository;

  ChatCubit(this._repository) : super(ChatInitial());

  Future<void> fetchChats() async {
    try {
      emit(ChatLoading());
      final id = UserStore().user.id;
      _repository.getChats(id).listen((chats) {
        emit(ChatLoaded(chats));
      });
    } on Exception {
      emit(ChatError("Couldn't fetch chats. Is the device online?"));
    }
  }
}
