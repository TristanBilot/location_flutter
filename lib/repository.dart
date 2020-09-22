import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'iconPicker.dart';

class Repository {
  final String _firestoreBaseURL = 'https://firebasestorage.googleapis.com';
  final String _fireStoreUserIconPath = 'photos/';
  final String _universalImageExtension = '.png';

  Future<BitmapDescriptor> fetchUserIcon(String id) async {
    final StorageReference ref =
        _getFirestoreImageReference('?' + _universalImageExtension);
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
    return _uploadFile(pickedIcon);
  }

  /* ++++++++++ private methods ++++++++++ */

  Future<void> _uploadFile(File file) async {
    final ref = _getFirestoreImageReference('?.png');
    final StorageUploadTask uploadTask = ref.putFile(file);
    await uploadTask.onComplete;
  }

  StorageReference _getFirestoreImageReference(String element) {
    return FirebaseStorage.instance
        .ref()
        .child(_fireStoreUserIconPath + element);
  }
}
