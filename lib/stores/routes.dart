enum Routes {
  login,
  map,
  account,
  languages,
  blockedUsers,
  startPathStep1,
  startPathStep2,
  startPathStep3,
  startPathStep4,
  test,
}

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
