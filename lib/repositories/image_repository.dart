import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:location_project/conf/store.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';
import '../helpers/icon_picker.dart';

class ImageRepository {
  static const String FirestoreBaseURL =
      'https://firebasestorage.googleapis.com';
  static const String OutputFilePrefix = 'circle_';

  /// Return the bitmap of the user's image used in the map.
  Future<BitmapDescriptor> fetchUserIcon(String id) async {
    final String firestoreURL =
        await getPictureDownloadURL(id, withCircleImage: true);
    final String uploadedFileURL =
        firestoreURL.substring(FirestoreBaseURL.length);

    final Uint8List data =
        (await NetworkAssetBundle(Uri.parse(FirestoreBaseURL))
                .load(uploadedFileURL))
            .buffer
            .asUint8List();

    return BitmapDescriptor.fromBytes(data);
  }

  /// Return the string url to download the Firestorage user image.
  /// `withCircleImage` used to determine if we should fetch an original
  /// image or a resized+circled image.
  Future<dynamic> getPictureDownloadURL(
    String id, {
    bool withCircleImage = false,
  }) async {
    return Future.sync(() {
      /* prefix used to determine if we should fetch a circular resized image */
      final prefix = withCircleImage ? ImageRepository.OutputFilePrefix : '';
      final ext = Store.defaultProfilePictureExtension;
      final defaultName = Store.defaultProfilePictureName;

      final picturePath = '$prefix$id$ext';
      final defaultPath = '$prefix$defaultName$ext';
      StorageReference ref = _getFirestoreImageReference(id, picturePath);

      return ref.getDownloadURL().then((url) => url).catchError((_) {
        /* if the picture is not found, set the default user image in FireStore */
        ref = _getFirestoreImageReference(id, defaultPath);
        return ref.getDownloadURL().then((url) => url).catchError((error) {
          print(
              '++++ Error: the user does not have an image and the default image is not found in Firestore.');
        });
      });
    });
  }

  Future<void> addOrUpdateMainUserPicture() async {}

  Future<void> deletePictureFromPictureURL(String pictureURL) async {
    final ref = await FirebaseStorage.instance.getReferenceFromUrl(pictureURL);
    ref.delete();
  }

  /// Pick upload and returns the picture url uploaded
  Future<String> pickImageAndUpload(String id) async {
    final File pickedImage = await IconPicker().pickImageFromGalery();
    if (pickedImage == null) return null;
    return _uploadNthUserPicture(id, pickedImage);
  }

  Future<List<String>> uploadAllUserPictures(
      String id, List<File> pictures) async {
    List<String> pictureURLs = List();
    await Future.forEach(pictures,
        (p) async => pictureURLs.add(await _uploadNthUserPicture(id, p)));
    return pictureURLs;
  }

  Future<String> _uploadNthUserPicture(String id, File picture) async {
    String fileName = formatUserPictureFileName();
    return uploadFile(id, picture, fileName);
  }

  /// Upload and returns the picture url uploaded
  Future<String> uploadFile(String id, File file, String fileName) async {
    final ref = _getFirestoreImageReference(id, fileName);
    final StorageUploadTask uploadTask = ref.putFile(file);
    final snapshot = await uploadTask.onComplete;
    return await snapshot.ref.getDownloadURL();
  }

  Future<File> urlToFile(String imageUrl) async {
    var rng = Random();
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    File file = File('$tempPath' +
        (rng.nextInt(100)).toString() +
        Store.defaultProfilePictureExtension);
    http.Response response = await http.get(imageUrl);
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  Future<File> getImageFileFromAssets(String path,
      {String additionalPath}) async {
    final byteData =
        await rootBundle.load('assets/${additionalPath ?? ''}$path');

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  String formatUserPictureFileName() {
    return Uuid().v4() + Store.defaultProfilePictureExtension; // random string
  }

  /* ++++++++++ private methods ++++++++++ */

  StorageReference _getFirestoreImageReference(String id, String fileName) {
    return FirebaseStorage.instance
        .ref()
        .child('${Store.fireStoreUserIconPath}$id/$fileName');
  }
}
