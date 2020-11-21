import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:location_project/adapters/stream_adapter.dart';
import 'package:location_project/use_cases/tab_pages/messaging/messaging_repository.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/message.dart';

part 'messages_state.dart';

class MessagesCubit extends Cubit<MessagesState> {
  MessagesCubit() : super(MessagesInitial());

  Future<void> fetchMessages(String chatID) async {
    try {
      MessagingReposiory()
          .getMessages(chatID)
          .transform(StreamAdapter().mapToListOfEntries<Message>())
          .listen((messages) {
        emit(MessagesFetchedState(messages));
      });
    } on Exception {
      emit(MessagesError("Couldn't fetch views. Is the device online?"));
    }
  }
}
