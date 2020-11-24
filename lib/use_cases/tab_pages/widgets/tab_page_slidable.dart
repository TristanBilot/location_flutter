import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class TabPageSlidable extends StatefulWidget {
  final String text1; // Right
  final String text2; // Left
  final Function action1;
  final Function action2;
  final Color color1;
  final Color color2;
  final Icon icon1;
  final Icon icon2;
  final bool isOnlyOneAction;
  final Widget child;

  TabPageSlidable({
    this.text1,
    this.action1,
    this.text2,
    this.action2,
    this.color1,
    this.color2,
    this.icon1,
    this.icon2,
    this.isOnlyOneAction = false,
    @required this.child,
  });

  @override
  _TabPageSlidableState createState() => _TabPageSlidableState();
}

class _TabPageSlidableState extends State<TabPageSlidable> {
  Widget get _defaultCloseIcon => IconSlideAction(
        caption: widget.text1 ?? 'Unmatch',
        color: widget.color1 ?? Colors.redAccent,
        icon: widget.icon1 ?? Icons.close,
        onTap: widget.action1 ?? () => {},
      );

  Widget get _defaultBlockIcon => IconSlideAction(
        caption: widget.text2 ?? 'Block',
        color: widget.color2 ?? Colors.indigoAccent,
        icon: widget.icon2 ?? Icons.block,
        onTap: widget.action2 ?? () => {},
      );

  Widget _defaultSlidable(actions) => Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        secondaryActions: actions,
        child: widget.child,
      );

  @override
  Widget build(BuildContext context) {
    if (widget.isOnlyOneAction) return _defaultSlidable([_defaultCloseIcon]);
    return _defaultSlidable([_defaultBlockIcon, _defaultCloseIcon]);
  }
}
