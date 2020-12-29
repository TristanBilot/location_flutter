import 'package:location_project/models/user.dart';
import 'package:location_project/repositories/user_repository.dart';
import 'package:location_project/storage/memory/memory_store.dart';

class UsersFromIDsFetcher {
  Future<List<User>> fetch(
    List<String> ids, {
    bool useMemoryCache = true,
  }) async {
    Future<User> getAsync(String id) async => MemoryStore().getUser(id);
    List<Future<User>> fetchedUsers = [];
    for (var id in ids) {
      if (useMemoryCache && MemoryStore().containsUser(id))
        fetchedUsers.add(getAsync(id));
      else
        fetchedUsers.add(UserRepository().fetchUser(id, withInfos: true));
    }
    return Future.wait(fetchedUsers);
  }
}
