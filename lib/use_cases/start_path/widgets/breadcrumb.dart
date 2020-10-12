import 'package:flutter/material.dart';
import 'package:location_project/use_cases/start_path/start_path_step1/start_path_step1.dart';
import 'package:location_project/widgets/textSF.dart';

class Breadcrumb extends StatefulWidget {
  final int index;

  Breadcrumb(this.index);

  @override
  BreadcrumbState createState() => BreadcrumbState();
}

class BreadcrumbState extends State<Breadcrumb> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = Theme.of(context).primaryColor;
    final unselectedColor = Theme.of(context).primaryColorLight.withAlpha(100);

    return Row(
      children: List.generate(StartPathStep1.nbOfSections, (i) => i)
          .map((i) => Text(
                '.',
                style: TextSF.TextSFTitleStyle.copyWith(
                    fontSize: 45,
                    color: i == (widget.index - 1)
                        ? selectedColor
                        : unselectedColor),
              ))
          .toList(),
    );
  }
}
