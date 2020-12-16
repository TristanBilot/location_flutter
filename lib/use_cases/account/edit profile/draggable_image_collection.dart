import 'package:drag_and_drop_gridview/devdrag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location_project/themes/dark_theme.dart';
import 'package:location_project/widgets/close_button.dart';

class DraggableImageCollection extends StatefulWidget {
  final List<String> imageURLs;
  final int nbMaxImages;
  const DraggableImageCollection(this.imageURLs, this.nbMaxImages);

  @override
  _DraggableImageCollectionState createState() =>
      _DraggableImageCollectionState(this.imageURLs);
}

class _DraggableImageCollectionState extends State<DraggableImageCollection> {
  List<String> imageURLs;
  List<bool> imageDeleteButtonList;

  int pos;
  List<String> tmpList;
  int variableSet = 0;
  ScrollController _scrollController;
  double width;
  double height;

  _DraggableImageCollectionState(this.imageURLs);

  @override
  void initState() {
    tmpList = [...imageURLs];
    _scrollController = ScrollController();
    imageDeleteButtonList = List();
    super.initState();
  }

  _onDeletePictureTap(int index) {
    setState(() {
      imageURLs.removeAt(index);
      tmpList = [...imageURLs];
    });
  }

  Widget _closeButton(int index) => RoundedCloseButton(
        onPressed: () => _onDeletePictureTap(index),
        color: MediaQuery.of(context).platformBrightness == Brightness.dark
            ? DarkTheme.PrimaryDarkColor
            : Theme.of(context).backgroundColor,
        iconColor: MediaQuery.of(context).platformBrightness == Brightness.dark
            ? Colors.white
            : Theme.of(context).primaryColor,
      );

  @override
  Widget build(BuildContext context) {
    return DragAndDropGridView(
      controller: _scrollController,
      itemCount: imageURLs.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 3 / 4.5,
      ),
      padding: EdgeInsets.all(10),
      itemBuilder: (context, index) {
        imageDeleteButtonList.add(true);
        return Opacity(
          opacity: pos != null
              ? pos == index
                  ? 0.6
                  : 1
              : 1,
          child: Stack(alignment: Alignment.bottomRight, children: [
            Padding(
              padding: EdgeInsets.all(5),
              child: Card(
                elevation: 4,
                child: LayoutBuilder(builder: (context, constraints) {
                  if (variableSet == 0) {
                    height = constraints.maxHeight;
                    width = constraints.maxWidth;
                    variableSet++;
                  }
                  return GridTile(
                    child: Image.network(
                      imageURLs[index],
                      fit: BoxFit.cover,
                      height: height,
                      width: width,
                    ),
                  );
                }),
              ),
            ),
            if (imageDeleteButtonList[index]) _closeButton(index)
          ]),
        );
      },
      onWillAccept: (oldIndex, newIndex) {
        HapticFeedback.lightImpact();
        setState(() {
          imageDeleteButtonList[oldIndex] = false;
        });

        imageURLs = [...tmpList];
        int indexOfFirstItem = imageURLs.indexOf(imageURLs[oldIndex]);
        int indexOfSecondItem = imageURLs.indexOf(imageURLs[newIndex]);

        if (indexOfFirstItem > indexOfSecondItem) {
          for (int i = imageURLs.indexOf(imageURLs[oldIndex]);
              i > imageURLs.indexOf(imageURLs[newIndex]);
              i--) {
            var tmp = imageURLs[i - 1];
            imageURLs[i - 1] = imageURLs[i];
            imageURLs[i] = tmp;
          }
        } else {
          for (int i = imageURLs.indexOf(imageURLs[oldIndex]);
              i < imageURLs.indexOf(imageURLs[newIndex]);
              i++) {
            var tmp = imageURLs[i + 1];
            imageURLs[i + 1] = imageURLs[i];
            imageURLs[i] = tmp;
          }
        }

        setState(
          () {
            pos = newIndex;
          },
        );
        return true;
      },
      onReorder: (oldIndex, newIndex) {
        setState(() {
          imageDeleteButtonList[oldIndex] = true;
        });
        imageURLs = [...tmpList];
        int indexOfFirstItem = imageURLs.indexOf(imageURLs[oldIndex]);
        int indexOfSecondItem = imageURLs.indexOf(imageURLs[newIndex]);

        if (indexOfFirstItem > indexOfSecondItem) {
          for (int i = imageURLs.indexOf(imageURLs[oldIndex]);
              i > imageURLs.indexOf(imageURLs[newIndex]);
              i--) {
            var tmp = imageURLs[i - 1];
            imageURLs[i - 1] = imageURLs[i];
            imageURLs[i] = tmp;
          }
        } else {
          for (int i = imageURLs.indexOf(imageURLs[oldIndex]);
              i < imageURLs.indexOf(imageURLs[newIndex]);
              i++) {
            var tmp = imageURLs[i + 1];
            imageURLs[i + 1] = imageURLs[i];
            imageURLs[i] = tmp;
          }
        }
        tmpList = [...imageURLs];
        setState(
          () {
            pos = null;
          },
        );
      },
    );
  }
}
