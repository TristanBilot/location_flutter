import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:location_project/repositories/user_repository.dart';
import 'package:location_project/storage/distant/user_store.dart';

part 'blocking_state.dart';

class BlockingCubit extends Cubit<BlockingState> {
  BlockingCubit() : super(BlockingInitial());

  void fetchUsersWhoBlockedMe() {
    final stream =
        UserRepository().getUserWhoBlockedMeStream(UserStore().user.id);
    stream.listen((event) {
      if (event.docChanges.isEmpty) return;
      final existingUsers = UserStore().user.userIDsWhoBlockedMe.toSet();
      final changes = event.docChanges.map((e) => e.doc.id).toList();
      for (var change in changes) {
        if (existingUsers.contains(change))
          existingUsers.remove(change);
        else
          existingUsers.add(change);
      }
      UserStore().updateLocalUsersWhoBlockMe(existingUsers.toList());
      emit(BlockingUsersFetchedState());
    });
  }

  void emitNewUserWhoBlockedMe() {
    emit(BlockingUsersFetchedState());
  }
}
