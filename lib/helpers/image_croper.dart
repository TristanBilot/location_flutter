import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_project/repositories/image_repository.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:image/image.dart' as img;

class ImageCroper {
  static const PictureIconSize = 200;

  final String pictureURL;
  final Function(BitmapDescriptor) callback;

  ui.Image image;

  ImageCroper(this.pictureURL, this.callback) {
    _init();
  }

  Future<Null> _init() async {
    File imageFile = await ImageRepository().urlToFile(pictureURL);
    Uint8List byteData = imageFile.readAsBytesSync();

    this.image = await _resizeAndConvertImage(
      byteData,
      PictureIconSize,
      PictureIconSize,
    );
    _saveCanvas(Size.zero);
  }

  Future<ui.Image> _resizeAndConvertImage(
    Uint8List data,
    int height,
    int width,
  ) async {
    img.Image baseSizeImage = img.decodeImage(data);
    img.Image resizeImage =
        img.copyResize(baseSizeImage, height: height, width: width);
    ui.Codec codec = await ui.instantiateImageCodec(img.encodePng(resizeImage));
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  Canvas _drawCanvas(Size size, Canvas canvas) {
    final center = Offset(150, 50);
    final radius = math.min(size.width, size.height) / 8;

    // The circle should be paint before or it will be hidden by the path
    Paint paintCircle = Paint()..color = Colors.black;
    Paint paintBorder = Paint()
      ..color = Colors.white
      ..strokeWidth = size.width / 36
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, paintCircle);
    canvas.drawCircle(center, radius, paintBorder);

    // resize
    // canvas.scale(0.22);

    double drawImageWidth = 0;
    var drawImageHeight = -size.height * 0.8;

    Path path = Path()
      ..addOval(Rect.fromLTWH(drawImageWidth, drawImageHeight,
          image.width.toDouble(), image.height.toDouble()));

    canvas.clipPath(path);

    canvas.drawImage(image, Offset(drawImageWidth, drawImageHeight), Paint());
    return canvas;
  }

  _saveCanvas(Size size) async {
    var pictureRecorder = ui.PictureRecorder();
    var canvas = Canvas(pictureRecorder);
    var paint = Paint();
    paint.isAntiAlias = true;

    _drawCanvas(size, canvas);

    var pic = pictureRecorder.endRecording();
    ui.Image img = await pic.toImage(image.width, image.height);
    var byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    var buffer = byteData.buffer.asUint8List();

    // var response = await get(imgUrl);
    var documentDirectory = await getApplicationDocumentsDirectory();
    File file = File(join(documentDirectory.path,
        '${DateTime.now().toUtc().toIso8601String()}.png'));
    file.writeAsBytesSync(buffer);

    BitmapDescriptor icon = BitmapDescriptor.fromBytes(buffer);
    callback(icon);

    print(file.path);
  }
}
