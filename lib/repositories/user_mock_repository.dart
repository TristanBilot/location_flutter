import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location_project/models/firestore_user_entry.dart';
import 'package:location_project/models/gender.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/models/user_settings.dart';
import 'package:location_project/repositories/user_repository.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/view.dart';
import 'image_repository.dart';
import '../stores/store.dart';

class UserMockRepository {
  static const MockAssetPath = 'mock_images/';

  static const int AgeMock = 21;
  static const Gender GenderMock = Gender.Female;

  Geoflutterfire _geo = Geoflutterfire();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  ImageRepository _imageRepo = ImageRepository();

  /// Insert a dataset of users to Firestore with a mock Storage
  /// image stored in asset.
  Future<void> putParisDataset() async {
    GeoFirePoint l0 = _geo.point(latitude: 48.825194, longitude: 2.34742);
    GeoFirePoint l1 = _geo.point(latitude: 48.82471, longitude: 2.348482);
    GeoFirePoint l2 = _geo.point(latitude: 48.8247, longitude: 2.3484);

    _insertUserMock('bilot.tristan@hotmail.fr', 'Tristan', 'Bilot', l0);
    _insertUserMock('damien.duprat@hotmail.fr', 'Damien', 'Duprat', l1);
    _insertUserMock('alexandre.roume@hotmail.fr', 'Alexandre', 'Roume', l2);
  }

  Future<void> putCarrieresDataset() async {
    GeoFirePoint l0 = _geo.point(latitude: 48.9152, longitude: 2.17952);
    GeoFirePoint l1 = _geo.point(latitude: 48.9162, longitude: 2.179672);
    GeoFirePoint l2 = _geo.point(latitude: 48.9163, longitude: 2.179678);

    _insertUserMock(
        'bilot.tristan.carrieres@hotmail.fr', 'Tristan', 'Bilot', l0);
    _insertUserMock(
        'damien.duprat.carrieres@hotmail.fr', 'Damien', 'Duprat', l1);
    _insertUserMock(
        'alexandre.roume.carrieres@hotmail.fr', 'Alexandre', 'Roume', l2);
  }

  /// Insert a mock user in the Firestore, with an image in the storage.
  Future<void> _insertUserMock(
    String id,
    String firstName,
    String lastName,
    GeoFirePoint geoPoint,
  ) async {
    await UserRepository().deleteCollection(id, UserField.BlockedUserIDs);
    await UserRepository().deleteCollection(id, UserField.UserIDsWhoBlockedMe);
    await UserRepository().deleteCollection(id, UserField.ViewedUserIDs);
    await UserRepository().deleteCollection(id, UserField.UserIDsWhoWiewedMe);
    await _firestore.collection(UserRepository.RootKey).doc(id).delete();

    _firestore
        .collection(UserRepository.RootKey)
        .doc(id)
        .set(FirestoreUserEntry(
          firstName,
          lastName,
          GenderMock,
          AgeMock,
          geoPoint,
          UserSettings.DefaultUserSettings,
          [],
        ).toFirestoreObject());
    final ext = Store.defaultProfilePictureExtension;
    final assetImage = await ImageRepository()
        .getImageFileFromAssets('$id$ext', additionalPath: MockAssetPath);
    await _imageRepo.uploadFile(assetImage, '$id$ext');
    print('$id successfully inserted to Firestore.');
    // 'cy1EFZn8dkSeiJS_dubUTi:APA91bGTRcQU8Hpz-qGgIOYAJZVmhw-Tk6s8KuUawX9fNNBADvHbauov9pSjOlY85wjIxTri4V41cGpH64ujNF6EnDE49P4z6JfEkeLpyKQHSt0SwHkhuWe-KF8iwua-EdUZbPVTikqe'
  }
}
