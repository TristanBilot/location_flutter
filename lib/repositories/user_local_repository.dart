import 'package:location_project/helpers/language_adapter.dart';
import 'package:location_project/use_cases/account/account_language_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../stores/extensions.dart';

class UserLocalRepository {
  static const LanguageKey = 'language';
  static const ConnectedIDKey = 'connectedId';

  SharedPreferences _prefs;

  static UserLocalRepository _instance;
  static UserLocalRepository get instance => _instance;

  static Future<UserLocalRepository> get startingInstance async {
    if (_instance != null) return _instance;
    _instance = UserLocalRepository();
    await _instance.getSharedPreferencesInstance();
    return _instance;
  }

  /// Load the local device storage (async).
  Future<void> getSharedPreferencesInstance() async {
    /* the repo need to be instanciated before usage
    because of the async getInstance */
    _prefs = await SharedPreferences.getInstance();
  }

  bool keyExists(String key) {
    return _prefs.containsKey(key);
  }

  /// Set the language of the app to the shared preferences (async).
  Future<void> setLanguage(Language language) async {
    await _prefs.setString(LanguageKey, language.value);
  }

  /// When the user log in, store its id in shared preferences
  /// to remember that it is connected.
  /// When nobody is connected yet, `ConnectedIDKey` is set to ''
  Future<void> rememberLoggedUser(String id) async {
    await _prefs.setString(ConnectedIDKey, id);
  }

  /// When the user log out, clear the `ConnectedIDKey` to ''
  Future<void> forgetLoggedUser() async {
    await _prefs.clear();
  }

  /// Return whether a user is logged in the app or not.
  /// Basically, a user is logged if an id is set in `ConnectedIDKey`
  bool isUserLoggedIn() {
    return _prefs.containsKey(ConnectedIDKey);
  }

  /// Return the ID of the logged user if it exists, or null.
  String getLoggedUserID() {
    if (!isUserLoggedIn()) return null;
    return _prefs.getString(ConnectedIDKey);
  }

  /// Return the current app language.
  Language getAppLanguage() {
    if (!_prefs.containsKey(LanguageKey)) return null;
    return LanguageAdapter().stringToLanguage(_prefs.getString(LanguageKey));
  }
}
