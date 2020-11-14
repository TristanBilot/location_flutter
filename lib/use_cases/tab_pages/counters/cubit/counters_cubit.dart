import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:location_project/stores/messaging_database.dart';
import 'package:location_project/use_cases/tab_pages/counters/cubit/counter.dart';

part 'counters_state.dart';

class CountersCubit extends Cubit<CountersState> {
  CountersCubit(this._database) : super(CountersInitial(Counter(0, 0, 0)));

  MessagingDatabase _database;

  void initCounters() {
    emit(CounterStoreState(Counter(
      _database.getNbDiscussions(),
      _database.getNbRequests(),
      _database.getNbViews(),
    )));
  }

  void incrementChats(int value) {
    int nbReq = _database.getNbRequests();
    int nbViews = _database.getNbViews();
    int newValue = _database.getNbDiscussions() + value;
    _database.putNbDiscussions(newValue);
    emit(CounterStoreState(Counter(newValue, nbReq, nbViews)));
  }

  void incrementRequests(int value) {
    int nbChats = _database.getNbDiscussions();
    int nbViews = _database.getNbViews();
    int newValue = _database.getNbRequests() + value;
    _database.putNbRequests(newValue);
    emit(CounterStoreState(Counter(nbChats, newValue, nbViews)));
  }

  void incrementViews(int value) {
    int nbChats = _database.getNbDiscussions();
    int nbReq = _database.getNbRequests();
    int newValue = _database.getNbViews() + value;
    _database.putNbViews(newValue);
    emit(CounterStoreState(Counter(nbChats, nbReq, newValue)));
  }
}
