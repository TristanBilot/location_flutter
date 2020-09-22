import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class IconPicker {
  Future<File> pickImageFromGalery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    return await _cropCirclePhoto(pickedFile.path);
  }

  /* ++++++++++ private methods ++++++++++ */

  Future<File> _cropCirclePhoto(String imagePath) async {
    return await ImageCropper.cropImage(
        sourcePath: imagePath,
        cropStyle: CropStyle.circle,
        maxWidth: 150,
        maxHeight: 150,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ));
  }
}
