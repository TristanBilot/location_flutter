import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:math';
import '../stores/store.dart';
import '../helpers/icon_picker.dart';

class ImageRepository {
  final String _firestoreBaseURL = 'https://firebasestorage.googleapis.com';

  Future<BitmapDescriptor> fetchUserIcon(String id) async {
    final String firestoreURL = await getPictureDownloadURL(id);
    final String uploadedFileURL =
        firestoreURL.substring(_firestoreBaseURL.length);

    final Uint8List data =
        (await NetworkAssetBundle(Uri.parse(_firestoreBaseURL))
                .load(uploadedFileURL))
            .buffer
            .asUint8List();

    return BitmapDescriptor.fromBytes(data);
  }

  Future<dynamic> getPictureDownloadURL(String id) async {
    return new Future.sync(() {
      StorageReference ref = _getFirestoreImageReference(
          (id ?? Store.defaultProfilePictureName) +
              Store.defaultProfilePictureExtension);

      return ref.getDownloadURL().then((url) => url).catchError((_) {
        ref = _getFirestoreImageReference(Store.defaultProfilePictureName +
            Store.defaultProfilePictureExtension);
        return ref.getDownloadURL().then((url) => url).catchError((error) {
          print(
              '++++ Error: the user does not have an image and the default image is not found in Firestore.');
        });
      });

      /* if the picture is not found, set the default user image in FireStore */
    });
  }

  Future<void> pickImageAndUpload() async {
    final File pickedIcon = await IconPicker().pickImageFromGalery();
    return uploadFile(pickedIcon, '?' + Store.defaultProfilePictureExtension);
  }

  Future<void> uploadFile(File file, String name) async {
    final ref = _getFirestoreImageReference(name);
    final StorageUploadTask uploadTask = ref.putFile(file);
    await uploadTask.onComplete;
  }

  Future<File> urlToFile(String imageUrl) async {
    var rng = new Random();
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    File file = new File('$tempPath' +
        (rng.nextInt(100)).toString() +
        Store.defaultProfilePictureExtension);
    http.Response response = await http.get(imageUrl);
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  /* ++++++++++ private methods ++++++++++ */

  StorageReference _getFirestoreImageReference(String element) {
    return FirebaseStorage.instance
        .ref()
        .child(Store.fireStoreUserIconPath + element);
  }
}
