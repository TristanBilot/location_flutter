import 'dart:io';

import 'package:location_project/controllers/location_controller.dart';
import 'package:location_project/repositories/user_local_repository.dart';
import 'package:location_project/repositories/user_repository.dart';
import 'package:location_project/stores/database.dart';
import 'package:location_project/stores/messaging_database.dart';
import 'package:location_project/stores/user_store.dart';
import 'package:hive/hive.dart';
import 'package:location_project/models/gender.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/models/user_settings.dart';
import 'package:location_project/use_cases/tab_pages/filters/chats_filter.dart';
import 'package:location_project/use_cases/tab_pages/filters/request_filter.dart';
import 'package:location_project/use_cases/tab_pages/messaging/messaging_repository.dart';
import 'package:path_provider/path_provider.dart';

class InitController {
  Future initFromMain() async {
    await UserLocalRepository.initAsynchronously();
    await _initHiveDatabases();
    // UserLocalRepository().forgetLoggedUser();
    // return;
    if (UserLocalRepository().isUserLoggedIn()) {
      await LocationController().handleLocationIfNeeded();
      if (await LocationController().isLocationEnabled())
        await UserStore().initAsynchronously();

      await _initMessagingCounts();
    }
  }

  Future initAfterLogin(String loggedID) async {
    await _openHiveDatabases();
    await LocationController().handleLocationIfNeeded();
    await UserLocalRepository().rememberLoggedUser(loggedID);
    await UserStore().initAsynchronously();
    await _initMessagingCounts();
  }

  Future initAfterStartPath(String newUserID) async {
    await UserLocalRepository().rememberLoggedUser(newUserID);
    await UserStore().initAsynchronously();
  }

  Future _initHiveDatabases() async {
    Directory dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    Hive.registerAdapter(GenderAdapter());
    Hive.registerAdapter(UserSettingsAdapter());
    Hive.registerAdapter(UserAdapter());

    await _openHiveDatabases();
  }

  Future _openHiveDatabases() async {
    await Database.initHiveDatabase();
    await MessagingDatabase.initHiveDatabase();
  }

  Future _initMessagingCounts() async {
    final id = UserStore().user.id;
    final chatsStream = MessagingReposiory().getChats(id);
    final viewsStream = UserRepository()
        .getCollectionListOfIDs(id, UserField.UserIDsWhoWiewedMe);

    final chatsSub = chatsStream.listen((chats) {
      int nbChats = ChatsFilter().filter(chats, '').length;
      int nbRequests = RequestFilter().filter(chats, '').length;
      print('nbChats: $nbChats');
      print('nbRequests: $nbRequests');
      MessagingDatabase().putNbDiscussions(nbChats);
      MessagingDatabase().putNbRequests(nbRequests);
    });

    final viewsSub = viewsStream.listen((views) {
      int nbViews = views.length;
      print('nbViews: $nbViews');
      MessagingDatabase().putNbViews(nbViews);
    });
    Future.delayed(Duration(seconds: 1), () {
      chatsSub.cancel();
      viewsSub.cancel();
    });
  }
}
