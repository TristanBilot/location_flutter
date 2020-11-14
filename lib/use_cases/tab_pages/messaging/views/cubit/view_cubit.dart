import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/repositories/user_repository.dart';
import 'package:location_project/stores/user_store.dart';

part 'view_fetching_state.dart';

class ViewCubit extends Cubit<ViewState> {
  final UserRepository _userRepository;

  ViewCubit(this._userRepository) : super(ViewInitial());

  Future<void> fetchViews() async {
    try {
      emit(ViewFetchingState());
      final id = UserStore().user.id;
      _userRepository
          .getStream(id, UserField.UserIDsWhoWiewedMe)
          .listen((snapshot) {
        List views =
            List<String>.from(snapshot.docs.map((doc) => doc.id).toList());
        emit(ViewFetchedState(views));
      });
    } on Exception {
      emit(ViewError("Couldn't fetch views. Is the device online?"));
    }
  }
}
