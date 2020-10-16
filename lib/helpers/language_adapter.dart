import 'package:location_project/use_cases/account/account_language_page.dart';

class LanguageAdapter {
  Language stringToLanguage(String language) {
    switch (language) {
      case 'French':
        return Language.French;
      case 'English':
        return Language.English;
      default:
        return null;
    }
  }
}
