import 'package:flutter/material.dart';

class BottomWaveContainer extends StatelessWidget {
  final bool withAnimation;
  final Widget child;

  BottomWaveContainer(this.withAnimation, this.child);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      child: child,
      curve: Curves.elasticOut,
      tween: Tween(begin: withAnimation ? -20.0 : 0.0, end: 0.0),
      duration: Duration(seconds: 2),
      builder: (context, value, child) {
        return ClipPath(
          child: child,
          clipper: BottomWaveClipper(value: value),
        );
      },
    );
  }
}

class BottomWaveClipper extends CustomClipper<Path> {
  var value;

  BottomWaveClipper({this.value}) : super();

  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height);

    var firstControlPoint = Offset(size.width / 6, size.height - 40 - value);
    var firstEndPoint = Offset(size.width / 2, size.height - 20);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint =
        Offset(size.width - size.width / 6, size.height + value);
    var secondEndPoint = Offset(size.width, size.height - 30);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) =>
      oldClipper is BottomWaveClipper && value != oldClipper.value;
}
