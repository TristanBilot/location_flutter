import 'package:location_project/models/user.dart';
import 'package:location_project/stores/map_store.dart';
import '../../widgets/map.dart';

enum SwipeSide { left, right }

class SwipeController {
  final MapStore _mapStore;
  final MapState _mapState;
  final User _swippedUser;

  SwipeController(this._mapStore, this._mapState, this._swippedUser);

  void swipe(SwipeSide swipeSide) {
    switch (swipeSide) {
      case SwipeSide.left:
        _mapState.update(() {
          _mapStore.addUnlikedUser(_swippedUser);
        });
        break;
      case SwipeSide.right:
        break;
    }
  }
}
