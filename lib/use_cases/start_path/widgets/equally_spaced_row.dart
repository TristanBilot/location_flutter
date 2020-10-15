import 'package:flutter/material.dart';

class EquallySpacedRow extends StatelessWidget {
  final List<Widget> children;

  const EquallySpacedRow(this.children);

  Row _buildRow() {
    List<Widget> list = List();
    children.forEach((w) {
      list.add(Spacer());
      list.add(w);
    });
    list.add(Spacer());
    return Row(children: list);
  }

  @override
  Widget build(BuildContext context) {
    return _buildRow();
  }
}
