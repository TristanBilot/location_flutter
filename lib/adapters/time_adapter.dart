class TimeAdapter {
  /// 22m, 3h, 6d, 2w, Now
  String adapt(int timeSinceEpochInMicroseconds) {
    var compared =
        DateTime.fromMicrosecondsSinceEpoch(timeSinceEpochInMicroseconds);
    var now = DateTime.now();
    var diff = now.difference(compared);

    var hours = diff.inHours;
    var mins = diff.inMinutes;
    var days = diff.inDays;

    if (days > 365) return '${(days / 365).round()}y';
    if (days > 7) return '${(days / 7).round()}w';
    if (days > 0) return '${days}d'; // OU J EN FRANCAIS
    if (hours > 0) return '${hours}h';
    if (mins >= 1) return '${mins}m';
    return 'Now';
  }

  /// 21/12/2020 at 17:24
  String adaptToDate(int timeSinceEpochInMicroseconds) {
    DateTime time =
        DateTime.fromMicrosecondsSinceEpoch(timeSinceEpochInMicroseconds)
            .toLocal();
    var day = time.day.toString().padLeft(2, '0');
    var month = time.month.toString().padLeft(2, '0');
    var year = time.year;
    var hour = time.hour;
    var min = time.minute.toString().padLeft(2, '0');
    return '$day/$month/$year at $hour:$min';
  }

  /// [0] => Today/Yesterday
  /// [1] => hour:min
  List<String> adaptToIntervalSinceNow(
    int timeSinceEpochInMicroseconds,
    int diffWithPrevMsgTime,
  ) {
    int microSec = timeSinceEpochInMicroseconds;
    DateTime time = DateTime.fromMicrosecondsSinceEpoch(microSec);
    int diffBetweenMsgAndNow =
        DateTime.now().subtract(Duration(microseconds: microSec)).day - 1;

    String day = time.day.toString().padLeft(2, '0');
    String month = time.month.toString().padLeft(2, '0');
    String dayStr;

    if (diffBetweenMsgAndNow == 0)
      dayStr = 'Today ';
    else if (diffBetweenMsgAndNow == 1)
      dayStr = 'Yesterday ';
    else
      dayStr = '$day/$month - '; // inverse order in English

    String hour = time.hour.toString().padLeft(2, '0');
    String min = time.minute.toString().padLeft(2, '0');
    String hourMinStr = '$hour:$min';
    return List.from([dayStr, hourMinStr]);
  }
}
