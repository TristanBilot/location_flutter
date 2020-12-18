import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:location_project/conf/store.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';
import '../helpers/icon_picker.dart';

class ImageRepository {
  Future<void> deletePictureFromPictureURL(String pictureURL) async {
    final ref = await FirebaseStorage.instance.getReferenceFromUrl(pictureURL);
    ref.delete();
  }

  /// Pick upload and returns the picture url uploaded
  Future<String> pickImageAndUpload(String id) async {
    final File pickedImage = await IconPicker().pickImageFromGalery();
    if (pickedImage == null) return null;
    String fileName = formatUserPictureFileName();
    return uploadFile(id, pickedImage, fileName);
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

  StorageReference _getFirestoreImageReference(String id, String fileName) {
    return FirebaseStorage.instance
        .ref()
        .child('${Store.fireStoreUserIconPath}$id/$fileName');
  }
}
