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

class MapPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  BitmapDescriptor _pinLocationIcon;
  Set<Marker> _markers = {};
  Completer<GoogleMapController> _controller = Completer();

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/counter.txt');
  }

  Future<File> write(int counter) async {
    final file = await _localFile;
    return file.writeAsString('$counter');
  }

  Future<int> read() async {
    try {
      final file = await _localFile;
      String contents = await file.readAsString();
      return int.parse(contents);
    } catch (e) {
      return 0;
    }
  }

  Future uploadFile(File file) async {
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child('photos/test.png');
    StorageUploadTask uploadTask = storageReference.putFile(file);

    await uploadTask.onComplete;
    print('File Uploaded');
    storageReference.getDownloadURL().then((fileURL) async {
      final uploadedFileURL = fileURL.substring(38);

      Uint8List data = (await NetworkAssetBundle(
                  Uri.parse('https://firebasestorage.googleapis.com'))
              .load(uploadedFileURL))
          .buffer
          .asUint8List();
      setState(() {
        _pinLocationIcon = BitmapDescriptor.fromBytes(data);
      });
    });
  }

  _downloadAndStoreImage(String url, String path, String preview) async {
    var buffer = await http.readBytes(url);

    File f = new File(path);
    RandomAccessFile rf = await f.open(mode: FileMode.write);
    await rf.writeFrom(buffer);
    await rf.flush();
    await rf.close();

    image.Image img = image.decodeImage(await new File(path).readAsBytes());
    image.Image thumbnail = image.copyResize(img, height: 100, width: 100);

    new File(preview)
      ..writeAsBytes(image.encodePng(thumbnail)).then((file) async {
        await uploadFile(file);

        f.deleteSync();
      });
  }

  @override
  void initState() {
    super.initState();
    // BitmapDescriptor.fromAssetImage(
    //         ImageConfiguration(
    //           devicePixelRatio: 5.5,
    //         ),
    //         'assets/hihi.jpg')
    //     .then((onValue) {
    //   _pinLocationIcon = onValue;
    // });
    _downloadAndStoreImage(
        'https://firebasestorage.googleapis.com/v0/b/location-abed9.appspot.com/o/user..jpg?alt=media&token=197bbb90-3981-4382-b950-7f230e8a7139',
        '/Users/bilott/test.jpg',
        '/Users/bilott/preview.jpg');
  }

  @override
  Widget build(BuildContext context) {
    LatLng pinPosition = LatLng(37.3797536, -122.1017334);

    CameraPosition initialLocation =
        CameraPosition(zoom: 16, bearing: 30, target: pinPosition);

    return Stack(children: [
      GoogleMap(
          myLocationEnabled: true,
          markers: _markers,
          initialCameraPosition: initialLocation,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
            Future.delayed(Duration(milliseconds: 3000), () {
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
