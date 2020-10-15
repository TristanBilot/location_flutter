import 'package:location_project/use_cases/account/account_language_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserLocalRepository {
  static const LanguageKey = 'language';

  SharedPreferences _prefs;

  UserLocalRepository() {
    _getSharedPreferencesInstance();
  }

  /// Load the local device storage (async).
  Future<void> _getSharedPreferencesInstance() async {
    /* the repo need to be instanciated before usage
    because of the async getInstance */
    _prefs = await SharedPreferences.getInstance();
  }

  bool keyExists(String key) {
    return _prefs.containsKey(key);
  }

  /// Set the language of the app to the shared preferences (async).
  Future<void> setLanguage(Language language) async {
    String languageValue;
    switch (language) {
      case Language.English:
        languageValue = 'English';
        break;
      case Language.French:
        languageValue = 'French';
        break;
    }
    await _prefs.setString(LanguageKey, languageValue);
  }
}
