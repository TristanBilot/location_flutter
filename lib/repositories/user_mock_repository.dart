import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location_project/conf/store.dart';
import 'package:location_project/models/firestore_user_entry.dart';
import 'package:location_project/models/gender.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/models/user_settings.dart';
import 'package:location_project/repositories/user_repository.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/message.dart';
import 'image_repository.dart';

class UserMockRepository {
  static const MockAssetPath = 'mock_images/';

  static const int AgeMock = 21;
  static const Gender GenderMock = Gender.Female;

  Geoflutterfire _geo = Geoflutterfire();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  ImageRepository _imageRepo = ImageRepository();

  final id1 = {
    'id': 'bilot.tristan@hotmail.fr',
    'name': 'Tristan',
    'lastName': 'Bilot'
  };
  final id2 = {
    'id': 'damien.duprat@hotmail.fr',
    'name': 'Damien',
    'lastName': 'Duprat'
  };
  final id3 = {
    'id': 'alexandre.roume@hotmail.fr',
    'name': 'Alexandre',
    'lastName': 'Duprat'
  };
  final id4 = {
    'id': 'bilot.tristan.carrieres@hotmail.fr',
    'name': 'Tristan',
    'lastName': 'Bilot'
  };
  final id5 = {
    'id': 'damien.duprat.carrieres@hotmail.fr',
    'name': 'Damien',
    'lastName': 'Duprat'
  };
  final id6 = {
    'id': 'alexandre.roume.carrieres@hotmail.fr',
    'name': 'Alexandre',
    'lastName': 'Duprat'
  };

  Future<void> putParisDataset() async {
    GeoFirePoint l0 = _geo.point(latitude: 48.825194, longitude: 2.34742);
    GeoFirePoint l1 = _geo.point(latitude: 48.82471, longitude: 2.348482);
    GeoFirePoint l2 = _geo.point(latitude: 48.8247, longitude: 2.3484);

    _insertUserMock(id1, l0);
    _insertUserMock(id2, l1);
    _insertUserMock(id3, l2);
  }

  Future<void> putCarrieresDataset() async {
    GeoFirePoint l0 = _geo.point(latitude: 48.9152, longitude: 2.17952);
    GeoFirePoint l1 = _geo.point(latitude: 48.9162, longitude: 2.179672);
    GeoFirePoint l2 = _geo.point(latitude: 48.9163, longitude: 2.179678);

    _insertUserMock(id4, l0);
    _insertUserMock(id5, l1);
    _insertUserMock(id6, l2);
  }

  /// Insert a mock user in the Firestore, with an image in the storage.
  Future<void> _insertUserMock(
    dynamic user,
    GeoFirePoint geoPoint,
  ) async {
    String id = user['id'];
    await UserRepository().deleteCollection(id, UserField.BlockedUserIDs);
    await UserRepository().deleteCollection(id, UserField.UserIDsWhoBlockedMe);
    await UserRepository().deleteCollection(id, UserField.ViewedUserIDs);
    await UserRepository().deleteCollection(id, UserField.UserIDsWhoWiewedMe);
    await _firestore.collection(UserRepository.RootKey).doc(id).delete();

    _firestore
        .collection(UserRepository.RootKey)
        .doc(id)
        .set(FirestoreUserEntry(
          user['name'],
          user['lastName'],
          GenderMock,
          AgeMock,
          geoPoint,
          UserSettings.DefaultUserSettings,
          [],
          UserSettings.DefaultNotificationSettings,
        ).toFirestoreObject());
    await UserRepository().addLikeField(
        id, UserField.LikedUsers, id == id1['id'] ? id2['id'] : id1['id']);
    await UserRepository().addLikeField(
        id, UserField.UnlikedUsers, id == id2['id'] ? id3['id'] : id2['id']);
    // final ext = Store.defaultProfilePictureExtension;
    // final assetImage = await ImageRepository()
    //     .getImageFileFromAssets('$id$ext', additionalPath: MockAssetPath);
    // await _imageRepo.uploadFile(assetImage, '$id$ext');
    print('$id successfully inserted to Firestore.');
  }
}
