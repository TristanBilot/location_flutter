import 'package:location_project/models/user.dart';
import 'package:location_project/repositories/user_repository.dart';

class UsersFromIDsFetcher {
  Future<List<User>> fetch(
    List<String> ids, {
    bool useMemoryCache = true,
  }) async {
    List<Future<User>> fetchedUsers = [];
    for (var id in ids) {
      fetchedUsers.add(UserRepository()
          .fetchUser(id, withInfos: true, useCache: useMemoryCache));
    }
    return Future.wait(fetchedUsers);
  }
}
