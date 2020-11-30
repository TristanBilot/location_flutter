import 'package:location_project/models/user.dart';

class SwipeCardsStore {
  SwipeCardsStore._internal();
  static final SwipeCardsStore _instance = SwipeCardsStore._internal();
  factory SwipeCardsStore() => _instance;

  int totalCardsCount = 0;
  int swappedCardCount = 0;
  List<User> users = List();

  User get currentlyDisplayedUser => users[swappedCardCount];
}
