class TimeAdapter {
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
    if (mins > 1) return '${mins}m';
    return 'Now';
  }
}
