import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/use_cases/map/repositories/area_fetching_repository.dart';

part 'area_state.dart';

class AreaCubit extends Cubit<AreaState> {
  AreaCubit(this._areaFetcher) : super(AreaInitial());
  final AreaFetchingRepository _areaFetcher;

  void fetchArea(Function completion) {
    final stream = _areaFetcher.fetch();
    _areaFetcher.listenAreaStream(stream, completion);
  }
}
