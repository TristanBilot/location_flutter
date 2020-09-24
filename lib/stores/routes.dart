enum Routes { login, map }

extension RawValue on Routes {
  /*
  * if an enum is `test`, it returns a `/test` string
  */
  String get value {
    return '/' + _toStr(this);
  }

  String _toStr(Routes route) {
    return route.toString().substring(route.toString().indexOf('.') + 1);
  }
}