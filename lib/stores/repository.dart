import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:math';
import 'store.dart';
import '../helpers/iconPicker.dart';

class Repository {
  final String _firestoreBaseURL = 'https://firebasestorage.googleapis.com';

  Future<BitmapDescriptor> fetchUserIcon(String name) async {
    final StorageReference ref = _getFirestoreImageReference(
        (name ?? '?') + Store.defaultProfilePictureExtension);
    final String firestoreURL = await ref.getDownloadURL();
    final String uploadedFileURL =
        firestoreURL.substring(_firestoreBaseURL.length);

    final Uint8List data =
        (await NetworkAssetBundle(Uri.parse(_firestoreBaseURL))
                .load(uploadedFileURL))
            .buffer
            .asUint8List();
    return BitmapDescriptor.fromBytes(data);
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
