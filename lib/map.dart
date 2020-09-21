import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as image;
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'user.dart';
import 'areaFetcher.dart';

class MapPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  BitmapDescriptor _pinLocationIcon;
  Set<Marker> _markers = {};
  Completer<GoogleMapController> _controller = Completer();
  AreaFetcher _areaFetcher = AreaFetcher();

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

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

  Future _uploadFile(File file) async {
    final String firebasePhotoPath = 'photos/';
    final String userFirebaseId = '?.png';
    final String firebaseURI = 'https://firebasestorage.googleapis.com';

    final StorageReference ref = FirebaseStorage.instance
        .ref()
        .child(firebasePhotoPath + userFirebaseId);
    final StorageUploadTask uploadTask = ref.putFile(file);

    await uploadTask.onComplete;
    print('File Uploaded');
    ref.getDownloadURL().then((fileURL) async {
      final String uploadedFileURL = fileURL.substring(firebaseURI.length);
      final Uint8List data = (await NetworkAssetBundle(Uri.parse(firebaseURI))
              .load(uploadedFileURL))
          .buffer
          .asUint8List();
      setState(() {
        _pinLocationIcon = BitmapDescriptor.fromBytes(data);
      });
    });
  }

  void _downloadAndStoreImage() async {
    /* image picking and croping */
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    final File tmpFile = await _cropCirclePhoto(pickedFile.path);
    await _uploadFile(tmpFile);
  }

  void old(String url) async {
    final Uint8List buffer = await http.readBytes(url);
    final String systemPath = await _localPath;
    final String tmpPathStr = systemPath + 'tmp.png';
    final String outputPathStr = systemPath + 'output.png';
    final newHeight = 200, newWidth = 200;

    /* image picking and croping */
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    final File tmpFile = await _cropCirclePhoto(pickedFile.path);

    // RandomAccessFile rf = await tmpFile.open(mode: FileMode.write);
    // await rf.writeFrom(buffer);
    // await rf.flush();
    // await rf.close();

    /* open the tmp file which will be resized and then create a copy */
    final image.Image resizedImg =
        image.decodeImage(await new File(tmpPathStr).readAsBytes());
    /* resizing */
    final image.Image resizedResult =
        image.copyResize(resizedImg, height: newHeight, width: newWidth);

    /* write the resized image to the disk and delete both 2 created files */
    new File(outputPathStr)
      ..writeAsBytes(image.encodePng(resizedResult)).then((outputFile) async {
        /* after resizing the image, upload it to Firebase */
        await _uploadFile(outputFile);
        /* clear useless files created for resizing */
        tmpFile.deleteSync();
        outputFile.deleteSync();
      });
  }

  @override
  void initState() {
    super.initState();

    Set<Marker> updatedmarkers = {};
    _areaFetcher.fetch((user) {
      setState(() {
        _markers.add(Marker(
            markerId: MarkerId(user.id),
            icon: user.icon,
            position: user.coord));
      });
    });

    // _downloadAndStoreImage();
  }

  @override
  Widget build(BuildContext context) {
    LatLng pinPosition = LatLng(48.825024, 2.347900);

    CameraPosition initialLocation =
        CameraPosition(zoom: 16, bearing: 30, target: pinPosition);

    // _markers.add(Marker(
    //     markerId: MarkerId('<MARKER_ID>'),
    //     position: pinPosition,
    //     icon: _pinLocationIcon));

    return Stack(children: [
      GoogleMap(
          myLocationEnabled: true,
          markers: _markers,
          initialCameraPosition: initialLocation,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
            Future.delayed(Duration(milliseconds: 10000), () {
              setState(() {
                _markers.add(Marker(
                    markerId: MarkerId('<MARKER_ID>'),
                    position: pinPosition,
                    icon: _pinLocationIcon));
              });
            });
          })
    ]);
  }
}
