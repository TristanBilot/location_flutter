import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'interactor/iconPicker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:math';

class Repository {
  final String _firestoreBaseURL = 'https://firebasestorage.googleapis.com';
  final String _fireStoreUserIconPath = 'photos/';
  final String _universalImageExtension = '.png';

  Future<BitmapDescriptor> fetchUserIcon(String name) async {
    final StorageReference ref =
        _getFirestoreImageReference((name ?? '?') + _universalImageExtension);
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
    return uploadFile(pickedIcon, '?.png');
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
    File file = new File('$tempPath' + (rng.nextInt(100)).toString() + '.png');
    http.Response response = await http.get(imageUrl);
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  /* ++++++++++ private methods ++++++++++ */

  StorageReference _getFirestoreImageReference(String element) {
    return FirebaseStorage.instance
        .ref()
        .child(_fireStoreUserIconPath + element);
  }
}
