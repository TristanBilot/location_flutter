import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class IconPicker {
  /*
  ^ FUNCTION
  * Opens the gallery picker and wait to the user to crop
  * the photo before selected.
  */
  Future<File> pickImageFromGalery() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 1);
    if (pickedFile == null) return null;
    return _cropCirclePhoto(pickedFile.path);
  }

  /*
  ^ PRIVATE FUNCTION
  * Method used to open the photo cropper.
  * This is where to change the width/height of 
  * a photo picked in the gallery.
  */
  Future<File> _cropCirclePhoto(String imagePath) async {
    return await ImageCropper.cropImage(
        sourcePath: imagePath,
        cropStyle: CropStyle.circle,
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
