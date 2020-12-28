import 'dart:collection';

import 'package:drag_and_drop_gridview/devdrag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location_project/repositories/image_repository.dart';
import 'package:location_project/storage/distant/user_store.dart';
import 'package:location_project/themes/theme_utils.dart';
import 'package:location_project/widgets/cached_image.dart';
import 'package:location_project/widgets/close_button.dart';

class DraggableImageCollection extends StatefulWidget {
  static const AddButtonKey = 'addBtn';
  final List<String> imageURLs;
  final int nbMaxImages;
  const DraggableImageCollection(this.imageURLs, this.nbMaxImages);

  static List<String> StateImageURLs;

  @override
  _DraggableImageCollectionState createState() =>
      _DraggableImageCollectionState(this.imageURLs);
}

class _DraggableImageCollectionState extends State<DraggableImageCollection> {
  static const int OnLongPressAnimationDuration = 500;
  static const double ImageBorderRadius = 10;

  List<String> imageURLs;
  List<bool> _imageDeleteButtonList;
  HashMap<int, double> _imageAnimationWidthsMap;
  HashMap<int, double> _imageAnimationHeightsMap;

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
    _imageDeleteButtonList = List();
    _imageAnimationWidthsMap = HashMap();
    _imageAnimationHeightsMap = HashMap();

    DraggableImageCollection.StateImageURLs = [...tmpList];
    super.initState();
  }

  _resetAnimationSizes(int index) {
    _imageAnimationWidthsMap[index] = width;
    _imageAnimationHeightsMap[index] = height;
  }

  bool _isAddButton(String imageURL) {
    return imageURL == DraggableImageCollection.AddButtonKey;
  }

  Widget _pictureView(int index) {
    _resetAnimationSizes(index);
    return Stack(alignment: Alignment.bottomRight, children: [
      Padding(
        padding: EdgeInsets.all(0),
        child: LayoutBuilder(builder: (context, constraints) {
          if (variableSet == 0) {
            height = constraints.maxHeight;
            width = constraints.maxWidth;
            variableSet++;
            _resetAnimationSizes(index);
          }

          return GridTile(
              child: AnimatedContainer(
            duration: Duration(milliseconds: OnLongPressAnimationDuration),
            width: _imageAnimationWidthsMap[index],
            height: _imageAnimationHeightsMap[
                index], // _imageAnimationWidthsMap[index], for square size

            child: Padding(
              padding: EdgeInsets.all(10),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black38)],
                ),
                child: _isAddButton(imageURLs[index])
                    ? _addButton
                    : CachedImage(imageURLs[index],
                        fit: BoxFit.cover, borderRadius: ImageBorderRadius),
              ),
            ),
          ));
        }),
      ),
      if (_imageDeleteButtonList[index] && !_isAddButton(imageURLs[index]))
        _deleteButton(index)
    ]);
  }

  Widget _deleteButton(int index) => RoundedCloseButton(
        onPressed: () => _onDeleteButtonTap(index),
        color: ThemeUtils.getPrimaryDarkOrLightGrey(context),
        iconColor: _buttonIconColor,
        iconSize: 18,
      );

  Widget get _addButton => GestureDetector(
        onTap: _onAddButtonTap,
        child: Container(
          decoration: BoxDecoration(
            color: ThemeUtils.getPrimaryDarkOrLightGrey(context),
            borderRadius: BorderRadius.circular(ImageBorderRadius),
          ),
          child: Icon(Icons.add, size: 38, color: _buttonIconColor),
        ),
      );

  _onAddButtonTap() async {
    final id = UserStore().user.id;
    String pictureURL = await ImageRepository().pickImageAndUpload(id);
    if (pictureURL != null) {
      setState(() {
        imageURLs.insert(imageURLs.length - 1, pictureURL);
        UserStore().updatePictureURLs([...imageURLs]..removeLast());
      });
    }
  }

  _onDeleteButtonTap(int index) async {
    ImageRepository().deletePictureFromPictureURL(imageURLs[index]);
    setState(() {
      imageURLs.removeAt(index);
      tmpList = [...imageURLs];
    });
    UserStore().updatePictureURLs([...imageURLs]..removeLast());
  }

  Color get _buttonIconColor =>
      MediaQuery.of(context).platformBrightness == Brightness.dark
          ? Colors.white
          : Theme.of(context).primaryColor;

  Future<void> _animateOnLongPress(int index) async {
    setState(() {
      _imageAnimationWidthsMap[index] += 20;
      _imageAnimationHeightsMap[index] += 20;
    });
    await Future.delayed(Duration(milliseconds: OnLongPressAnimationDuration));
    HapticFeedback.lightImpact();
    setState(() {
      _imageAnimationWidthsMap[index] -= 20;
      _imageAnimationHeightsMap[index] -= 20;
    });
    await Future.delayed(Duration(milliseconds: OnLongPressAnimationDuration));
  }

  @override
  Widget build(BuildContext context) {
    DraggableImageCollection.StateImageURLs = [...tmpList]..removeLast();

    return DragAndDropGridView(
      controller: _scrollController,
      itemCount: imageURLs.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        // childAspectRatio: 3 / 4.5,
      ),
      padding: EdgeInsets.all(10),
      itemBuilder: (context, index) {
        _imageDeleteButtonList.add(true);
        return Opacity(
          opacity: pos != null
              ? pos == index
                  ? 0.6
                  : 1
              : 1,
          child: _pictureView(index),
        );
      },
      onWillAccept: (oldIndex, newIndex) {
        imageURLs = [...tmpList];

        setState(() {
          _imageDeleteButtonList[oldIndex] = false;
          _animateOnLongPress(oldIndex);
        });

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
        imageURLs = [...tmpList];

        /* reset all the delete buttons to displayed = true */
        setState(() {
          for (int i = 0; i < _imageDeleteButtonList.length; i++)
            _imageDeleteButtonList[i] = true;
        });

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
